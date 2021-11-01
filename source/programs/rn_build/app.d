module source.programs.rn_build.app;

import std.conv;
import std.stdio;
import std.process;
import std.getopt;
import std.string : toStringz;

import core.stdc.stdlib : system;
import core.sys.posix.unistd;

enum EState {
    NONE,
    BUILD,
    REBUILD,
    UTIL,
    HELP,
}

EState state = EState.NONE;
bool bDebug = true;
bool bRebuild = false;
int jobsCount = 4;
string utilName = "";

private {
    File devNull;
}

struct SUtil {
static:
    void printDmdVersion() {
        exec( ["dmd", "--version"] );
    }

    void clearCaches() {
        execLogless( ["scons", "--clean"] );
        execLogless( ["rm", "-rf", "./build_cache"] );
    }

    void rawBuild() {
        assert( jobsCount > 0 );
        exec( ["scons", "-j" ~ to!string( jobsCount )] );
    }

    void runUtil() {
        writeln( "Currently unimplemented" );
    }

    void safeSetState( EState istate ) {
        assert( state == EState.NONE );
        state = istate;
    }

    void execLogless( string[] cmds ) {
        execute( cmds );
    }

    void exec( string[] cmds ) {
        wait( spawnProcess( cmds ) );
    }
}

void main( string[] args ) {
    /**
        Check for root priviliges
    */
    if ( getuid() != 0 ) {
        system( toStringz( "sudo " ~ args[0] ) );
        return;
    }

    /**
        Specify /dev/null for null output in "execLogless"
    */
    version( Posix ) {
        devNull = File( "/dev/null", "w" );
    } else version( Windows ) {
        devNull = File( "NUL", "w" );
    } else {
        static assert( false, "Unimplemented null file" );
    }

    scope( exit ) {
        devNull.close();
    }

	auto helpInformation = getopt(
        args,
        "debug", "Build in debug mode", &bDebug,
        "rebuild|r", "Clear cache and build from scratch", &bRebuild,
        "jobs|j", "Set jobs count for build system( SCons currently )", &jobsCount
    );

    // Regular information about compiler version
    SUtil.printDmdVersion();

    // Set program state
    if ( helpInformation.helpWanted ) {
        SUtil.safeSetState( EState.HELP );
    }

    if ( utilName != "" ) {
        SUtil.safeSetState( EState.UTIL );
    }

    if ( bRebuild ) {
        SUtil.safeSetState( EState.REBUILD );
    }

    // If nothing is setted just regular build engine
    if ( state == EState.NONE ) {
        state = EState.BUILD;
    }

    switch ( state ) {
    case EState.HELP:
        defaultGetoptPrinter( "rn_neng simple buiding util:/\n Writed by _Nex", helpInformation.options );
        break;
    
    case EState.BUILD:
        SUtil.rawBuild();
        break;
    
    case EState.REBUILD:
        SUtil.clearCaches();
        SUtil.rawBuild();
        break;
    
    case EState.UTIL:
        SUtil.runUtil();
        break;
    
    default:
        assert( false );
    }
}
