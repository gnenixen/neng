module engine.core.reference;

import engine.core.memory;
import engine.core.object : CObject, NewObject, DestroyObject;
public import engine.core.ref_count;

alias Ref = SReference;

struct SReference( T ) {
    T obj;
    alias obj this;

    this( this ) {
        incRef();
    }

    this( T iobj ) {
        obj = iobj;
        incRef();
    }

pragma( inline, true ):
    auto instance( Args... )( Args args ) {
        static if ( !__traits( isAbstractClass, T ) ) {
            
            static if ( is( T : CObject ) ) {
                obj = NewObject!T( args );
            } else {
                obj = allocate!T( args );
            }

            incRef();

        } else {
            assert( false, "Cannot instance abstract class: " ~ T.stringof );
        }
    }

    size_t incRef() {
        if ( obj is null ) {
            return 0;
        }
        
        return RC.incRef( obj );
    }

    size_t decRef() {
        if ( obj is null ) {
            return 0;
        }

        size_t refCnt = RC.decRef( obj );

        if ( refCnt == 0 ) {
            static if ( is( T : CObject ) ) {
                DestroyObject( obj );
            } else {
                deallocate( obj );
            }
        }

        return refCnt;
    }

    size_t refCount() const {
        if ( obj is null ) {
            return 0;
        }

        return RC.refCount( obj );
    }

    void opAssign( X = typeof( this ) )( auto ref SReference!T r ) {
        decRef();
        obj = r.obj;
        incRef();
    }

    void opAssign( X = typeof( this ) )( auto ref T r ) {
        decRef();
        obj = r;
        incRef();
    }

    bool isValid() {
        static if ( is( T == class ) || is( T == interface ) ) {
            return obj !is null;
        } else {
            return true;
        }
    }

    alias reference = incRef;
    alias unreference = decRef;
}

struct SRCHandler {
private:
    void* lhandler;

public:
    void* initialize() {
        if ( !lhandler ) {
            lhandler = allocate( 1 );
            RC.incRef( lhandler );
        }

        return lhandler;
    }

    void deinitialize() {
        deallocate( lhandler );
    }

    size_t incRef() {
        return RC.incRef( handler );
    }

    size_t decRef() {
        return RC.decRef( handler );
    }

    size_t refCount() {
        return RC.refCount( handler );
    }

private:
    alias handler = initialize;
}
