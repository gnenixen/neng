module engine.core.utils.console_logger;

import std.stdio;

import engine.core.log;
import engine.core.string;

enum Color : string {
    Clear  = "\033c",       // clear console
    Normal = "\033[0m",     // reset color
    Black  = "\033[1;30m",
    Red    = "\033[1;31m",
    Green  = "\033[1;32m",
    Yellow = "\033[1;33m",
    Blue   = "\033[1;34m",
    Purple = "\033[1;35m",
    Cyan   = "\033[1;36m",
    White  = "\033[1;37m"
}

class CConsoleLogger : ALogger {
    override void logImpl( ELogType type, String text ) {
        String res;
        
        switch ( type ) {
        case ELogType.INFO:
            res ~= "\033[1;32m"; //Color.Green;
            break;
        case ELogType.WARN:
            res ~= "\033[1;33m"; //Color.Yellow;
            break;
        case ELogType.ERROR:
            res ~= "\033[1;31m"; //Color.Red;
            break;
        default:
            break;
        }

        res ~= text;
        res ~= "\033[0m";

        writeln( res );
    }
}