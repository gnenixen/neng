module engine.core.os.mutex;

import engine.core.os.os : OS;
import engine.core.object;

abstract class AMutexImpl : CObject {
    mixin( TRegisterClass!AMutexImpl );
public:
    void lock() {
        llock();
    }

    void unlock() {
        lunlock();
    }

protected:
abstract:
    void setup( bool bRecursive );

    void llock();
    void lunlock();
}

class CMutex : CObject, Object.Monitor {
    mixin( TRegisterClass!CMutex );
public:
    static CRSClass backend;

protected:
    AMutexImpl impl;

    bool bRecursive;

public:
    this( bool ibRecursive = true ) {
        assert( backend );
        bRecursive = ibRecursive;

        impl = newObjectR!AMutexImpl( backend );
        assert( impl !is null );

        impl.setup( bRecursive );
    }

    ~this() {
        DestroyObject( impl );
    }

    void lock() {
        debug assert( impl );

        impl.lock();
    }

    void unlock() {
        debug assert( impl );

        impl.unlock();
    }
}

alias Mutex = CMutex;
