module engine.core.containers.cow;

import engine.core.memory;
import engine.core.math;

alias CopyOnWrite = SCopyOnWrite;
alias COW = SCopyOnWrite;

struct SCopyOnWrite( T ) {
//private:
    T* ldata = null;
    size_t llength = 0;

public:
    @disable this( this );

    this( ref return scope typeof( this ) rcow ) {
        lref( rcow );
    }

    ~this() {
        lunref( ldata );
    }

    T* ptrw() {
        cow();
        return ldata;
    }

    const( T )* ptr() const {
        return ldata;
    }

    void resize( size_t size ) {
        size_t currSize = length;
        size_t prevElemsCount = length;
        
        if ( size == currSize ) {
            return;
        }

        // Clear data
        if ( size == 0 ) {
            lunref( ldata );
            ldata = null;
            return;
        }

        // Possibly changing size
        cow();

        size_t needAllocSize = getAllocSize( size );
        size_t currentAllocSize = getAllocSize( currSize );

        if ( size > currSize ) {
            if ( needAllocSize != currentAllocSize ) {
                if ( currSize == 0 ) {
                    ldata = allocate!( T[] )( needAllocSize ).ptr;
                } else {
                    T* narray = allocate!( T[] )( needAllocSize ).ptr;
                    Memory.memcpy( cast( void* )narray, cast( void* )ldata, needAllocSize * T.sizeof );
                    deallocate( ldata );
                    ldata = narray;
                }
            }

            foreach ( i; prevElemsCount..size ) {
                ldata[i] = T.init;
            }

            llength = size;

        } else if ( size < currSize ) {
            if ( currentAllocSize != needAllocSize ) {
                T* narray = allocate!( T[] )( needAllocSize ).ptr;
                Memory.memcpy( cast( void* )narray, cast( void* )ldata, needAllocSize * T.sizeof );
                deallocate( ldata );
                ldata = narray;
            }

            llength = size;
        }
    }

    size_t length() {
        return llength;
    }

    void lref( ref SCopyOnWrite!T from ) {
        if ( ldata == from.ldata ) {
            return;
        }

        lunref( ldata );
        ldata = null;

        if ( !from.ldata ) {
            return;
        }

        if ( from.ldata ) {
            Memory.refcount( cast( void* )from.ldata )++;
            ldata = from.ldata;
            llength = from.llength;
        }
    }

    void lunref( ref T* idata ) {
        if ( !idata ) {
            return;
        }

        size_t val = --Memory.refcount( cast( void* )ldata );
        if ( val > 0 ) {
            return;
        }

        deallocate( idata );
        idata = null;
    }

    void cow() {
        if ( !ldata ) {
            return;
        }

        if ( Memory.refcount( cast( void* )ldata ) > 1 ) {
            T* narray = allocate!( T[] )( llength ).ptr;
            Memory.memcpy( narray, ldata, llength * T.sizeof );

            lunref( ldata );
            ldata = narray;
        }
    }

    size_t getAllocSize( size_t elems ) {
        return cast( size_t )Math.nextPow2( cast( int )( elems ) );
    }

    auto opAssign( ref SCopyOnWrite!T from ) {
        lref( from );
    }
}
