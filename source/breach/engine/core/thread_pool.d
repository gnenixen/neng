/*
    And if I don't have a heart
    Then what is broken?
    Bonds of time they come apart
    We've been awoken at the end
    And if I don't have a heart
    Then why keep hoping?
    We were blinded from the start
    Forever frozen my friend

    Machine hearts
    (C) Miracle of sound
*/
module engine.core.thread_pool;

import std.traits;

import engine.core.memory;
import engine.core.object;
import engine.core.os;
import engine.core.log;
import engine.core.containers;
import engine.core.typedefs;

interface ITask {
    void exec();
}

class CTask( T ) : ITask {
    alias Params = Parameters!T;

    T func;
    VArray args;

    ~this() {
        args.free();
    }

    void exec() {
        Params args;
        fillArgs!0( args );
        func( args );
    }

private:
    void fillArgs( int index )( ref Params params ) {
        static if ( Params.length > 0 ) {
            alias U = typeof( params[index] );
            params[index] = args[index].as!U;
        }

        static if ( index + 1 < Params.length ) {
            fillArgs!( index + 1 )( params );
        }
    }
}

private class CTPThreadInfo {
    bool bTerminated = false;
    
    Thread thread;
    Mutex mutex;

    Queue!ITask tasks;

    this( ThreadDelegate del ) {
        thread = NewObject!Thread( del, cast( void* )this );
        mutex = NewObject!Mutex();

        thread.start();
    }

    ~this() {
        synchronized ( mutex ) {
            bTerminated = true;
        }

        thread.join();

        DestroyObject( thread );
        DestroyObject( mutex );
    }
}

class CThreadPool : CObject {
    mixin( TRegisterClass!( CThreadPool, Singleton ) );
private:
    Array!CTPThreadInfo lthreads;

public:
    void initialize( uint threadNum ) {
        assert( lthreads.length == 0 );

        if ( threadNum == 0 ) {
            log.warning( "Used 0 threads, all tasks will be executed on main thread" );
            return;
        }

        while ( threadNum > 0 ) {
            lthreads ~= allocate!CTPThreadInfo( &threadProcess );

            threadNum--;
        }
    }

    void deinitialize() {
        foreach ( thread; lthreads ) {
            deallocate( thread );
        }
    }
    
    void add( FUNC, Args... )( FUNC func, Args args ) {
        CTask!FUNC task = allocate!( CTask!FUNC )();
        task.func = func;

        task.args.reserve( Args.length );
        
        static foreach ( i, arg; Args ) {
            task.args ~= var( args[i] );
        }

        if ( lthreads.length ) {
            CTPThreadInfo info = getLessLoadThread();

            synchronized ( info.mutex ) {
                info.tasks.push( task );
            }
        } else {
            task.exec();
        }
    }

private:
    void threadProcess( void* args ) {
        CTPThreadInfo info = cast( CTPThreadInfo )args;
        if ( !Memory.isValid( args ) || !info ) {
            return;
        }

        bool bWork = true;

        while ( bWork ) {
            ulong length = 0;
            synchronized ( info.mutex ) {
                length = info.tasks.length();
            }

            if ( !length ) {
                Thread.sleep( 100 );

                synchronized ( info.mutex ) {
                    bWork = !info.bTerminated;
                }

                continue;
            }

            ITask task;

            synchronized ( info.mutex ) {
                task = info.tasks.pop;
            }

            if ( !Memory.isValid( cast( void* )task ) ) {
                continue;
            }

            task.exec();

            deallocate( task );
        }
    }

    CTPThreadInfo getLessLoadThread() {
        if ( !lthreads.length ) return null;

        CTPThreadInfo llt;

        llt = lthreads[0];
        
        foreach ( thread; lthreads ) {
            synchronized ( thread.mutex ) {
                if ( thread.tasks.length < llt.tasks.length ) {
                    llt = thread;
                }
            }
        }

        return llt;
    }
}

pragma( inline, true )
CThreadPool GThreadPool() {
    return CThreadPool.sig;
}
