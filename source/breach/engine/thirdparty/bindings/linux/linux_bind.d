module bindings.linux.linux_bind;

version( linux ):

import core.sys.posix.signal;

import std.format;
import std.string;

import engine.core.memory;
import engine.core.utils.msg_const;

private {
    static __gshared bool bAlreadyEnterCrashHandler = false;
    string memlogRes = "";
            
    /*void memlogWalkBlocks( SMemoryBlockDebugInfo di ) {
        import std.format;

        memlogRes ~= format( "0x%5$x %3$s:%4$s - %1$s (%2$s)\n", di.type, di.size, di.file, di.line, cast( void* )di.addr );
    }*/
}

extern extern( C ) {
    /*   Helper export functions   */

    /*
        The real signal handler exec stack is:
            linux_handleCrash
            _c_linux_handleCrash
            _c_linux_realHandleCrash

        Because we need @nogc attrib, that impossible
        with 'defaultTraceHandler', 'format' and 'writeln'
    */
    void _c_linux_realCrashHandler( int sig, string addCrashInfo = "NO" ) {
        //import core.runtime : defaultTraceHandler;
        import core.sys.posix.stdlib : abort;

        /*import std.stdio : writeln;
        import std.datetime;
        import std.file;
        import std.path;
        import std.conv;
        import std.string;

        import engine.core.config;

        // Something get wrong even on this level:)
        if ( bAlreadyEnterCrashHandler ) {
            abort();
        }

        bAlreadyEnterCrashHandler = true;

        string res = Clock.currTime().toSimpleString() ~ "\n\n" ~ SMSGConst.ENGINE_CRASH_HEADER ~ '\n';

        res ~= format( SMSGConst.ENGINE_INFO_FTM, "1.0.0", "debug" ) ~ "\n\n";
        res ~= format( SMSGConst.HARDWARE_INFO_FMT, "Linux", "", "", Memory.allocatedMemory ) ~ "\n\n";
        res ~= format( SMSGConst.RECEIVED_SIGNAL_WITH_STACK_FMT, sig, addCrashInfo, defaultTraceHandler( null ).toString() );

        string crashStackFilePath = dirName( readLink( "/proc/self/exe" ) ) ~ "/crash_info.log";
        
        write( crashStackFilePath, res );

        writeln( res );*/

        /*if ( true ) {
            string memFilePath = dirName( readLink( "/proc/self/exe" ) ) ~ "/crash_mem.log";

            Memory.dbgWalkBlocks( &memlogWalkBlocks );

            write( memFilePath, memlogRes );
        }*/

        abort();
    }

    /*   crash_handle.c   */
    @nogc
    void _c_linux_handleCrash( int sig ) nothrow;
}

pragma( inline, true ):

/*   crash_handle.c   */
@nogc
@system
extern( C )
static void linux_handleCrash( int sig ) nothrow {
    _c_linux_handleCrash( sig );
}