module engine.os.linux.os;

version( linux ):
import core.runtime;
import core.sys.linux.time;
import core.sys.linux.execinfo;
import core.sys.linux.sys.sysinfo;
import core.sys.posix.sys.time;
import core.sys.posix.dlfcn;
import core.sys.posix.pthread;
import core.sys.posix.semaphore;
import core.stdc.errno;
import core.stdc.stdio;
import core.stdc.stdlib;

import std.file : readLink;
import std.path : dirName, baseName;

import engine.thirdparty.x11.X;
import engine.thirdparty.x11.Xlib;
import engine.thirdparty.x11.Xutil;
import engine.thirdparty.x11.Xtos;

import engine.core.os;
import engine.core : log, GEngine, Array, String, CString;

import engine.os.linux.file_system;

extern extern( C ) {
    void* gc_getProxy();
    void gc_setProxy( void* );
    void gc_clrProxy();

    alias setProxyFT = void function( void* );
    alias clrProxyFT = void function();
}

class CPosixMutex : AMutexImpl {
    mixin( TRegisterClass!CPosixMutex );
private:
    pthread_mutexattr_t attr;
    pthread_mutex_t mutex;

public:
    ~this() {
        pthread_mutex_destroy( &mutex );
    }

protected:
override:
    void setup( bool bRecursive ) {
        pthread_mutexattr_init( &attr );
        if ( bRecursive ) {
            pthread_mutexattr_settype( &attr, PTHREAD_MUTEX_RECURSIVE );
        }
        pthread_mutex_init( &mutex, &attr );
    }

    void llock() {
        pthread_mutex_lock( &mutex );
    }

    void lunlock() {
        pthread_mutex_unlock( &mutex );
    }
}

class CPosixThread : AThreadImpl {
    mixin( TRegisterClass!CPosixThread );
public:
    bool bDelegate = false;
    void* args = null;
    
private:
    pthread_t pthread;
    pthread_attr_t attr;
    ThreadFunction func;
    ThreadDelegate del;

public:
    ~this() {
        if ( pthread != 0 ) {
            pthread_join( pthread, null );
        }
    }

override:
    void setup( ThreadFunction ifunc, void* iargs ) {
        func = ifunc;
        args = iargs;
    
        pthread_attr_init( &attr );
        pthread_attr_setdetachstate( &attr, PTHREAD_CREATE_JOINABLE );
        pthread_attr_setstacksize( &attr, 256 * 1024 );
    }

    void setup( ThreadDelegate idel, void* iargs ) {
        bDelegate = true;
        del = idel;
        args = iargs;

        pthread_attr_init( &attr );
        pthread_attr_setdetachstate( &attr, PTHREAD_CREATE_JOINABLE );
        pthread_attr_setstacksize( &attr, 256 * 1024 );
    }

    void start() {
        pthread_create( &pthread, &attr, &threadProcess, cast( void* )this );
    }

    void join() {
        pthread_join( pthread, null );
        pthread = 0;
    }
}

extern( C ) void* threadProcess( void* data ) {
    CPosixThread thr = Cast!CPosixThread( data );
    if ( !thr ) {
        return null;
    }

    if ( !thr.bDelegate ) {
        thr.func( thr.args );
    } else {
        thr.del( thr.args );
    }
    
    return null;
}

class CPosixSemaphore : ASempahoreImpl {
    mixin( TRegisterClass!CPosixSemaphore );
private:
    sem_t sem;

public:
    this() {
        if ( sem_init( &sem, 0, 0 ) != 0 ) {
            perror( "sem waiting" );
        }
    }

    ~this() {
        sem_destroy( &sem );
    }

    override bool wait() {
        while ( sem_wait( &sem ) ) {
            if ( errno == EINTR ) {
                errno = 0;
                continue;
            } else {
                perror( "sem waiting" );
                return false;
            }
        }

        return true;
    }

    override bool post() {
        return sem_post( &sem ) == 0;
    }

    override int get() {
        int val;
        sem_getvalue( &sem, &val );
        return val;
    }
}

class COSLinux : AOS {
    mixin( TRegisterClass!COSLinux );
private:
    ENV lenv;
    string execPath;
    string execFileName;

public:
    this() {
        string procSelfExe = readLink( "/proc/self/exe" );
        execPath = procSelfExe.dirName();
        execFileName = procSelfExe.baseName();

        lenv.set( "exec/path", execPath );
        lenv.set( "exec/file_name", execFileName );

        lenv.set( "system/cores_count", get_nprocs_conf() );
    }

    ~this() {
        signal( SIGSEGV, SIG_DFL );
        signal( SIGFPE, SIG_DFL );
        signal( SIGILL, SIG_DFL );
    }

override:
    long time_get() {
        timespec tvNow;
        clock_gettime( CLOCK_REALTIME, &tvNow );

        return tvNow.tv_sec * 1_000_000_000 + tvNow.tv_nsec;

        /*timeval tvNow;
        gettimeofday( &tvNow, null );
        return tvNow.tv_sec * 1000 + tvNow.tv_usec / 1000;*/
    }

    void time_delay( long usec ) const {
        import core.stdc.config;
        
        timespec rem = timespec( cast( time_t )( usec / 1_000_000 ), cast( c_long )( ( usec % 1_000_000 ) * 1000 ) );
        while ( nanosleep( &rem, &rem ) == EINTR ) {}
    }

    void time_fdelay( double secs ) {
        import core.stdc.config;

        const c_long sec = cast( c_long )secs;
        const c_long nsec = cast( c_long )((secs - cast( double )sec) * 1e9);

        timespec req;

        if ( sec < 0L ) return;
        if ( sec == 0L && nsec <= 0 ) return;

        req.tv_sec = sec;
        if ( nsec <= 0L ) {
            req.tv_nsec = 0L;
        } else {
            if ( nsec <= 999999999L ) {
                req.tv_nsec = nsec;
            } else {
                req.tv_nsec = 999999999L;
            }
        }

        while ( nanosleep( &req, &req ) == EINTR ) {}
    }

    AFSBackend fs_get( String path ) {
        return newObject!CLinuxFSBackend( path );
    }

    ENV env() {
        return lenv;
    }

    void panic() {
        import core.stdc.stdio : getchar;
        import core.sys.posix.stdlib : abort;

        abort();
    }
}
