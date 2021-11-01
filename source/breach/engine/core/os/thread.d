module engine.core.os.thread;

import engine.core.os.os : OS;
import engine.core.object;

alias ThreadFunction = void function( void* );
alias ThreadDelegate = void delegate( void* );

abstract class AThreadImpl : CObject {
    mixin( TRegisterClass!AThreadImpl );
public:
abstract:
    void setup( ThreadFunction func, void* args );
    void setup( ThreadDelegate del, void* args );
    
    void start();
    void join();
}

class CThread : CObject {
    mixin( TRegisterClass!CThread );
public:
    static CRSClass backend;

private:
    AThreadImpl impl;

public:
    this( ThreadFunction func, void* args = null ) {
        assert( backend );

        impl = newObjectR!AThreadImpl( backend );
        assert( impl !is null );

        impl.setup( func, args );
    }

    this( ThreadDelegate del, void* args = null ) {
        assert( backend );

        impl = newObjectR!AThreadImpl( backend );
        assert( impl !is null );
        
        impl.setup( del, args );
    }

    ~this() {
        impl.join();
        DestroyObject( impl );
    }

    void start() {
        impl.start();
    }

    void join() {
        impl.join();
    }

    static void sleep( long usec ) {
        OS.time_delay( usec );
    }
}

alias Thread = CThread;
