module engine.core.spin_lock;

import core.atomic;

struct SSpinLock {
    bool bLocked;

    void lock() {
        while ( cas!( MemoryOrder.acq, MemoryOrder.rel )( &bLocked, false, true ) ) {}
    }

    void unlock() {
        atomicStore!( MemoryOrder.rel )( bLocked, false );
    }
}