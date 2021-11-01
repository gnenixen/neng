module engine.core.ref_count;

import engine.core.memory;

alias RC = SRC;

static struct SRC {
static __gshared:
    ref size_t refCount( T )( T obj ) {
        return Memory.refcount( cast( void* )obj );
    }

    size_t incRef( T )( auto ref T obj ) {
        assert( obj !is null, "Passed null object" );

        refCount( obj )++;
        return refCount( obj );
    }

    size_t decRef( T )( T obj ) {
        assert( obj !is null, "Passed null object" );

        if ( refCount( obj ) > 0 ) {
            refCount( obj )--;
        }

        return refCount( obj );
    }
}

template TRefCountable( string T ) {
    import std.string : format;

    enum TRefCountable = format( q{
        protected {
            import engine.core.memory : allocate, deallocate;
        }

        public {
            alias RCData = %1$s;

            enum __rc = true;

            @disable this( this );

            RCData* ldata = null;

            this( ref return scope typeof( this ) from ) {
                RCData* ldt = cast( RCData* )from.ldata;

                if ( !ldt ) return;
                if ( ldt == ldata ) return;

                RC.incRef( ldt );
                lunref();

                ldata = ldt;
            }

            ~this() {
                lunref();
            }

            void opAssign( typeof( this ) from ) {
                RCData* ldt = from.data;

                if ( !ldt ) return;
                if ( ldt == ldata ) return;

                RC.incRef( ldt );
                lunref();

                ldata = ldt;
            }

            size_t refCount() {
                return RC.refCount( ldata );
            }
        }

        protected {
            bool isRCDataInitialized() { return ldata !is null; }

            void lref() {
                if ( !ldata ) return;

                RC.incRef( ldata );
            }

            void lunref() {
                if ( !ldata ) return;

                assert( RC.refCount( ldata ) != 0, "Invalid ref count data!" );

                if ( RC.decRef( ldata ) == 0 ) {
                    _dataDestruct( ldata );
                    deallocate( ldata );
                }
            }

            pragma( inline, true )
            RCData* data() {
                if ( ldata is null ) {
                    ldata = allocate!RCData();
                    _dataInitialize( ldata );

                    RC.refCount( ldata ) = 1;
                }

                return ldata;
            }
        }
    },
    T
    );
}
