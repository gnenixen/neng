module engine.os.win.os_win;

version( Windows ):

private {
    import core.runtime;

    import core.sys.windows.windows;
    import core.sys.windows.winnt;
}

import std.string : toStringz;
import std.conv : to;
import std.utf;
import std.path : dirName, baseName;

import engine.core.log;
import engine.core.os;
import engine.core.gengine;
import engine.core.string;

import engine.os.win.file_system;

pragma( lib, "Winmm.lib" );
pragma( lib, "user32.lib" );

extern( Windows )
@system
LONG UEF( EXCEPTION_POINTERS* exceptionInfo ) {
    import core.runtime;

    GEngine.PANIC_HANDLER( String( "Low level engine exception!\n\n", defaultTraceHandler().toString() ) );
    return EXCEPTION_EXECUTE_HANDLER;
}

class CWinMutex : AMutexImpl {
    mixin( TRegisterClass!CWinMutex );
protected:
    HANDLE mutex;

public:
    ~this() {
        CloseHandle( mutex );
    }

protected:
    override void setup( bool bRecursive ) {
        mutex = CreateMutex( null, FALSE, null );
    }

    override void llock() {
        WaitForSingleObject( mutex, INFINITE );
    }

    override void lunlock() {
        ReleaseMutex( mutex );
    }
}

class CWinThread : AThreadImpl {
    mixin( TRegisterClass!CWinThread );
public:
    bool bDelegate = false;
    void* args;

private:
    ThreadFunction func;
    ThreadDelegate del;

    HANDLE thread;

public:
override:
    void setup( ThreadFunction ifunc, void* iargs ) {
        func = ifunc;
        args = iargs;
    }

    void setup( ThreadDelegate idel, void* iargs ) {
        del = idel;
        args = iargs;

        bDelegate = true;
    }

    void start() {
        thread = CreateThread( NULL, 0, &ThreadProc, cast( void* )this, 0, NULL );
    }

    void join() {
        //Ok, just wait...
        WaitForSingleObject( thread, INFINITE );
    }
}

extern( Windows )
DWORD ThreadProc( LPVOID lpParam ) {
    CWinThread thread = cast( CWinThread )lpParam;
    assert( thread );

    if ( !thread.bDelegate ) {
        thread.func( thread.args );
    } else {
        thread.del( thread.args );
    }

    return 0;
}

class CWinSemaphore : ASempahoreImpl {
    mixin( TRegisterClass!CWinSemaphore );
protected:
    enum MAX_SEM_COUNT = 10;

    HANDLE semaphore;

public:
    this() {
        semaphore = CreateSemaphore( null, MAX_SEM_COUNT, MAX_SEM_COUNT, null );
    }

    ~this() {
        CloseHandle( semaphore );
    }

    override bool wait() {
        return !!WaitForSingleObject( semaphore, 1 );
    }

    override bool post() {
        return !!ReleaseSemaphore( semaphore, 1, null );
    }

    override int get() {
        return -1;
    }
}

class COSWin : AOS {
    mixin( TRegisterClass!COSWin );
protected:
    ENV lenv;

    long ticksPerSecond;
    long ticksStart;

public:
    this() {
        SetUnhandledExceptionFilter( &UEF );

        if ( !QueryPerformanceFrequency( cast(LARGE_INTEGER*)&ticksPerSecond) ) {
            ticksPerSecond = 1000;
        }

        ticksStart = time_get();

        timeBeginPeriod( 1 );

        HINSTANCE mod = GetModuleHandleA( NULL );
        WCHAR[MAX_PATH] path;
        GetModuleFileNameW( mod, path.ptr, MAX_PATH );
        wstring procSelfExe = to!wstring( path );

        SYSTEM_INFO sysinfo;
        GetSystemInfo( &sysinfo );

        lenv.set( "exec/path", procSelfExe.dirName );
        lenv.set( "exec/file_name", procSelfExe.baseName );

        lenv.set( "system/cores_count", sysinfo.dwNumberOfProcessors );
    }

override:
    long time_get() {
        UINT64 ticks;

        if ( !QueryPerformanceCounter( cast(LARGE_INTEGER*)&ticks ) ) {
            ticks = cast(UINT64)timeGetTime();
        }

        UINT64 seconds = ticks / ticksPerSecond;
        UINT64 leftover = ticks % ticksPerSecond;

        UINT64 time = (leftover * 1_000_000_000L) / ticksPerSecond;
        time += seconds * 1_000_000_000L;
        time -= ticksStart;

        return time;
    }

    void time_delay( long usec ) {
        if ( usec < 1000 ) {
            Sleep( 1 );
        } else {
            Sleep( cast( uint )usec / 1000 );
        }
    }

    void time_fdelay( double secs ) {
        time_delay( cast( long )secs / 1_000_000 );
    }

    ENV env() { return lenv; }
	
	AFSBackend fs_get( String path ) {
        return newObject!CWindowsFSBackend( path );
    }

    void panic() {
        import core.stdc.stdio : getchar;
        import core.stdc.stdlib : abort;

        getchar();
        abort();
    }
}
