module engine.core.containers.dictionary;

import engine.core.containers.array;
import engine.core.utils.ustruct;
import engine.core.ref_count;

alias Dictionary = SDictionary;
alias Dict = SDictionary;

struct SDictionaryElement( T, K ) {
    mixin( TRegisterStruct!( SDictionaryElement!( T, K ) ) );
public:
    T data;
    K key;
}

struct SDictionary( T, K ) {
    mixin( TRefCountable!( "Array!Element" ) );
public:
    alias Element = SDictionaryElement!( T, K );

public:
    void free( void function( T, K ) FREE = null ) {
        if ( FREE !is null ) {
            foreach ( elem; *data ) {
                FREE( elem.data, elem.key );
            }
        }

        data.free();
    }

    size_t length() { return data.length; }

    Array!T values() {
        Array!T ret;
        ret.reserve( length );

        foreach ( elem; *data ) {
            ret ~= elem.data;
        }

        return ret;
    }

    Array!K keys() {
        Array!K ret;
        ret.reserve( length );

        foreach ( elem; *data ) {
            ret ~= elem.key;
        }

        return ret;
    }

    void set( K key, T value ) {
        size_t idx = find( key );
        
        if ( idx != -1 ) {
            (*data)[idx].data = value;
        } else {
            Element elem;
            elem.key = key;
            elem.data = value;

            *data ~= elem;
        }
    }

    T get( K key, T defaultValue = T.init ) {
        size_t idx = find( key );

        if ( idx != -1 ) {
            return (*data)[idx].data;
        }

        return defaultValue;
    }

    void remove( K key ) {
        size_t idx = find( key );

        if ( idx != -1 ) {
            data.removeAt( idx );
        }
    }

    bool has( K key ) {
        return find( key ) != -1;
    }

    size_t find( K key ) {
        foreach ( i, elem; *data ) {
            if ( elem.key == key ) {
                return i;
            }
        }

        return -1;
    }

    void set( U, V )( U key, V value ) {
        static if ( __traits( compiles, { set( K( key ), T( value ) ); } ) ) {
            set( K( key ), T( value ) );
        } else {
            static assert( 0, "Invalid params" );
        }
    }

    T get( U )( U key, T defaultValue = T.init ) {
        static if ( __traits( compiles, { get( K( key ) ); } ) ) {
            return get( K( key ), defaultValue );
        } else {
            static assert( 0, "Invalid params" );
        }
    }

    int opApply( scope int delegate( K, ref T ) dg ) {
        int result = 0;

        foreach ( elem; *data ) {
            result = dg( elem.key, elem.data );

            if ( result ) {
                break;
            }
        }

        return result;
    }

    T* opIndex( K key ) {
        size_t idx = find( key );

        static if ( is( K == string ) ) {
            debug assert( idx != -1, "Invalid dictionary index " ~ '"' ~ key ~ '"' );
        } else {
            debug assert( idx != -1, "Invalid dictionary index " ~ key.stringof );
        }

        return &( data.rawdata[idx].data );
    }

    T opIndexAssign( T value, K key ) {
        set( key, value );
        return value;
    }

    T opIndexAssign( U, L )( U value, L key ) {
        static if ( __traits( compiles, { set( K( key ), T( value ) ); } ) ) {
            set( K( key ), T( value ) );
            return T( value );
        }
        else {
            static assert( false, "Invalid params!" );
        }
    }
static:
    void _dataInitialize( Array!Element* idata ) {
        idata.ldata = allocate!( Array!Element.ArrayData )();
        Array!Element._dataInitialize( idata.ldata );
    }

    void _dataDestruct( Array!Element* idata ) {
        if ( idata.ldata ) {
            Array!Element._dataDestruct( idata.ldata );
            deallocate( idata.ldata );
        }
    }
}
