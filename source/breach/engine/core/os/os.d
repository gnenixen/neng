module engine.core.os.os;

public:
import engine.core.object;
import engine.core.signal;
import engine.core.typedefs;
import engine.core.containers;
import engine.core.fs.backend;

import engine.core.os.mutex;
import engine.core.os.thread;
import engine.core.os.semaphore;

alias DynamicLibH = void*;
alias ENV = Dict!( String, String );

abstract class AOS : CObject {
    mixin( TRegisterClass!( AOS, SingletonBackendable ) );
public:
    final String env_get( String key ) {
        return env.get( key, rs!"invalid" );
    }

abstract:
    /**
        Returns system time in msecs
    */
    long time_get();

    /**
        Delay system for some time
    */
    void time_delay( long usecs );
    void time_fdelay( double secs );

    /**
        Returns system enviroment,
        must contains:
            exec/path
            exec/file_name

            system/cores_count
    */
    ENV env();

    /**
        Returns some file system structure by
        given path, returns null if path is invalid
    */
    AFSBackend fs_get( String path );

    void panic();
}

pragma( inline, true )
AOS OS() {
    return AOS.sig;
}
