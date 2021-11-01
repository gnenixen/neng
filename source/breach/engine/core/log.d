module engine.core.log;

import std.conv;
import std.string;

import engine.core.memory : deallocate;
import engine.core.string;
import engine.core.containers.array;

enum ELogType {
    INFO,
    WARN,
    ERROR,
}

abstract class ALogger {
public:
    abstract void logImpl( ELogType type, String text );
}

class CLogger {
private:
    static __gshared CLogger _logger;

    Array!ALogger loggers;

public:
    this() {
        assert( !_logger );
        _logger = this;
    }

    ~this() {
        foreach ( lg; loggers ) {
            deallocate( lg );
        }

        loggers.free();
    }

    static __gshared CLogger sig() {
        return _logger;
    }

    void addLogger( ALogger logger ) {
        loggers ~= logger;
    }

    void info( Args... )( Args args, string file = __FILE__, int line = __LINE__, string func = __FUNCTION__ ) {
        String res = String( "[INFO] ", file, ":", line, ":", func.split( "." )[$-1], " " );
        foreach ( arg; args ) {
            res ~= arg;
        }

        printLog( ELogType.INFO, res );
    }

    void error( Args... )( Args args, string file = __FILE__, int line = __LINE__, string func = __FUNCTION__ ) {
        String res = String( "[ERROR] ", file, ":", line, ":", func.split( "." )[$-1], " " );
        foreach ( arg; args ) {
            res ~= arg;
        }

        printLog( ELogType.ERROR, res );
    }

    void warning( Args... )( Args args, string file = __FILE__, int line = __LINE__, string func = __FUNCTION__ ) {
        String res = String( "[WARN] ", file, ":", line, ":", func.split( "." )[$-1], " " );
        foreach ( arg; args ) {
            res ~= arg;
        }

        printLog( ELogType.WARN, res );
    }

private:
    void printLog( ELogType type, String text ) {
        foreach ( lg; loggers ) {
            lg.logImpl( type, text );
        }
    }
}

pragma( inline, true )
CLogger log() {
    return CLogger.sig;
}
