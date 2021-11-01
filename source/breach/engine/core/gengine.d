module engine.core.gengine;

public:
import engine.core.utils.msg_const : SMSGConst;
import engine.core.memory : allocate, deallocate, Memory;
import engine.core.os;
import engine.core.math;
import engine.core.object;
import engine.core.log;
import engine.core.resource;
import engine.core.config;
import engine.core.symboldb;
import engine.core.string;
import engine.core.variant;
import engine.core.fs;
import engine.core.thread_pool;

alias PanicHandler = void function( String msg );

struct SGEngineConfig {
    /*
        If true all tasks for thread pool will be 
        executed on main thread immidiatle when
        called GThreadPool.addTask
    */
    bool bDisableThreadPool = false;
}

/**
    Contains some global objects
*/
static __gshared struct GEngine {
public static __gshared:
    PanicHandler PANIC_HANDLER = null;
    Mutex OBJ_POOL_MUTEX;
    Mutex FILE_SYSTEM_MUTEX;

    void preInititialize() {
        CSymbolDB.sig = allocate!CSymbolDB;

        allocate!CLogger();

        GObjectPool.initialize();
    }

    void initialize( SGEngineConfig cfg = SGEngineConfig() ) {
        if ( !PANIC_HANDLER ) {
            PANIC_HANDLER = ( String msg ) {
                import std.stdio : writeln;
                writeln( msg );
            };
        }

        OBJ_POOL_MUTEX = NewObject!Mutex;
        FILE_SYSTEM_MUTEX = NewObject!Mutex;

        GObjectPool.synchronization = SObjectPoolSynchronization(
            () { OBJ_POOL_MUTEX.lock(); },
            () { OBJ_POOL_MUTEX.unlock(); }
        );

        if ( cfg.bDisableThreadPool ) {
            GThreadPool.initialize( 0 );
        } else {
            GThreadPool.initialize( 4 );
        }

        GFileSystem.mutex = SFileSystemSynchronization(
            () { FILE_SYSTEM_MUTEX.lock(); },
            () { FILE_SYSTEM_MUTEX.unlock(); }
        );
    }

    void destruct() {
        GThreadPool.deinitialize();
        GObjectPool.deinitialize();
    }

    void update() {
        GFileSystem.update();
        GResourceManager.update();
    }
 
    void panic( String msg ) {
        log.error( msg );
        PANIC_HANDLER( msg );
        OS.panic();
    }

    void panic( string msg ) { panic( String( msg ) ); }
}

extern( C ) {
    void _d_assertp( immutable(char)* file, uint line ) {
        GEngine.panic( String( cast( const( char )* )file, ":", line ) );
    }

    void _d_assert( string file, uint line ) {
        GEngine.panic( String( file, ":", line ) );
    }

    void _d_assert_msg( string msg, string file, uint line ) {
        GEngine.panic( String( file, ":", line, "\n", msg ) );
    }
}

