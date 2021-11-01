module engine.core.containers.array;

import engine.core.memory;
import engine.core.ref_count;

alias Array = SArray;

/**
    Data can be use by multiple arrays
*/
struct SArrayData {
    // For full size check only
    size_t chsize = 0;
    TypeInfo typeinfo = null;
    
    void* array;
    size_t pos = 0;
    size_t chunks = 0;

    size_t refcount = 0;
}

/**
    Policity of some array operations
*/
struct SArrayPolicity( T ) {
    alias FreeHandler = void function( T elem );
    alias ReallocateHandler = T* function( T* array, size_t expectSize, size_t pos );
    alias DtorHandler = void function( T* array , size_t pos );

    /**
        Called for each element in SArray.free
    */
    FreeHandler onFree;

    /**
        Called when need to allocate space
        for more elements
    */
    ReallocateHandler onReallocate;

    DtorHandler onDestruct;

    /**
        Check if array use refcount memory
        managment model
    */
    bool bIsRefcountable = true;

    bool bMemsetNullOnFree = true;
}

/**
    Regular, chunk alocatable array.
    Reference-count based.
*/
struct SArray( T, size_t CHSIZE = 32 ) {
    mixin( TRefCountable!( "ArrayData" ) );
public:
    alias TYPE = T;
    alias CHUNK_SIZE = CHSIZE;

    alias ArrayData = SArrayData;
    alias ArrayPolicity = SArrayPolicity!T;

protected:
    ArrayPolicity lpolicity;

public:
    alias append = insertBack;
    alias opDollar = length;
    alias insertAt = insertIndex;
    alias removeAt = removeIndex;

    this( Args... )( Args args ) {
        foreach ( arg; args ) {
            append( arg );
        }
    }

    /**
        May be used for checking in reflection
    */
    void tIsArrayContainer() {}

    /**
        Write array (means correct
        writable array)

        The name can be confusing,
        but it is just an array, which
        to the user looks like regual
        D array of 'real' size
    */
    T[] rawdata() {
        return ptr[0..data.pos];
    }

    T* ptr() {
        return cast( T* )data.array;
    }

    size_t length() {
        return data.pos;
    }

    /**
        Return given idx element by reference
    */
    ref T rget( size_t idx ) {
        return rawdata[idx];
    }

    /**
        Return given idx element by pointer
    */
    T* pget( size_t idx ) {
        return &rawdata[idx];
    }

    /**
        Iterate over elements of array and
        execute FREE func, that has view
        like:
            array.free( ( elem ) {
                deallocate( elem );
            } );
        
        If nothing is passed, then use onFree
        from policity
        
        then zero allocated memory and set
        pos to 0
    */
    void free( void delegate( T elem ) FREE = null ) {
        if ( FREE !is null ) {
            foreach ( elem; rawdata ) { FREE( elem ); }
        } else {
            foreach ( elem; rawdata ) { policity.onFree( elem ); }
        }

        if ( data.chunks != 0 && policity.bMemsetNullOnFree ) {
            Memory.memset( data.array, 0, datasize * T.sizeof );
        }
        
        data.pos = 0;
    }

    Array!( T, CHSIZE ) copy() {
        Array!( T, CHSIZE ) ret;
        ret.reserve( length );

        foreach ( item; this ) {
            ret ~= item;
        }

        return ret;
    }

    /**
        Reserve additional space in array
        Params:
            size - amount of added elements, if
            it number is not a multimple of chunk
            size, then number of chunks will be
            rounded to up value

            appendMode -
            If true, append additionaly size,
            if false, calculate
            (exists size - additiaonly size)
    */
    void reserve( size_t size, bool appendMode = false ) {
        // Size must be greater then 1 to add...
        // something._.
        // If not in appendMode, then size
        // must be greater then current array size
        if ( size < 1 || (!appendMode && size <= datasize) ) {
            return;
        }

        // Number of full chunk to allocate
        size_t base = size / CHUNK_SIZE;

        // If the number of elements is not
        // a multiple of the chunk size,
        // then we add one additional element
        // to store this non-integer number
        // of elements
        size_t fract = ( size % CHUNK_SIZE > 0 ? 1 : 0 );

        // Result add chunks number, in append
        // mode just substract already exists
        // chunks number
        size_t chunks = appendMode ?
            base + fract :
            base + fract - data.chunks;


        if ( chunks != 0 ) {
            addChunks( chunks );
        }
    }

    /**
        Resize array, move pos handler
        to size position:
        Params:
            size - new array size
    */
    void resize( size_t size ) {
        if ( size > datasize ) {
            reserve( size );
        }

        data.pos = size;
    }

    void insertBack( X )( X elem ) {
        if ( data.pos == datasize ) {
            addChunks( 1 );
        }

        ptr[data.pos].opAssign( elem );
        data.pos++;
    }

    void insertBack( T elem ) {
        if ( data.pos == datasize ) {
            addChunks( 1 );
        }

        ptr[data.pos] = elem;
        data.pos++;
    }

    size_t removeBack( size_t n ) {
        if ( data.pos == n ) {
            data.pos = 0;
            return n;
        } else if ( data.pos >= n ) {
            data.pos -= n;
        } else {
            n = data.pos;
            data.pos = 0;
        }

        return n;
    }

    void insertIndex( size_t idx, T elem ) {
        if ( idx < length ) {
            T* arr = cast( T* )data.array;
            
            insertBack( T.init );

            for ( size_t i = length - 1; i > idx; i-- ) {
                arr[i] = arr[i-1];
            }

            arr[idx] = elem;
        } else {
            append( elem );
        }
    }

    void removeIndex( size_t index ) {
        if ( index < length ) {
            T* arr = cast( T* )data.array;

            for ( size_t i = index + 1; i < length; i++ ) {
                arr[i-1] = arr[i];
            }

            data.pos--;
        }
    }

    /**
        Search for some element by passed
        string as mixin
        Params:
            a - element to search
    */
    int find( string expr = "a is b", U )( U a ) {
        if ( length == 0 ) {
            return -1;
        }

        foreach ( i, b; rawdata ) {
            if ( mixin( expr ) ) {
                return cast( int )i;
            }
        }

        return -1;
    }

    /**
        Search for some element by func
        Params:
            a - element to search
    */
    int find( alias expr = ( a, b ) => a == b, U )( U a ) {
        if ( length == 0 ) {
            return -1;
        }

        foreach ( i, b; rawdata ) {
            if ( expr( a, b ) ) {
                return cast( int )i;
            }
        }

        return -1;
    }

    Array!U casted( U )() {
        Array!U arr;
        arr.reserve( length );

        foreach ( el; rawdata ) {
            arr ~= cast( U )el;
        }

        return arr;
    }

    /* Helpers around regular functions */

    bool has( string expr = "a == b", U )( U elem ) {
        return find!expr( elem ) != -1;
    }

    bool has( alias expr, U )( U elem ) {
        return find!expr( elem ) != -1;
    }
    
    /**
        Append element ot array only if
        it's unique
    */
    bool appendUnique( T elem ) {
        if ( has( elem ) ) {
            return false;
        }

        insertBack( elem );
        return true;
    }

    void swapIdx( int idx1, int idx2 ) {
        if ( idx1 > length || idx2 > length || idx1 < 0 || idx2 < 0 ) {
            return;
        }

        T t = rawdata[idx1];
        rawdata[idx1] = rawdata[idx2];
        rawdata[idx2] = t;
    }

    void swap( T elem1, T elem2 ) {
        int idx1 = find( elem1 );
        int idx2 = find( elem2 );

        if ( idx1 && idx2 && idx1 != idx2 ) {
            swapIdx( idx1, idx2 );
        }
    }

    bool remove( T elem ) {
        size_t idx = find( elem );
        
        if ( idx != -1 ) {
            removeIndex( idx );
        }

        return idx != -1;
    }

    bool removeAll( T elem ) {
        size_t idx = -2;

        while ( (idx = find( elem )) != -1 ) {
            removeIndex( idx );
        }

        return idx != -2;
    }

    /*      D's operator overloading
        (all of this operatins work around rawdata,
        not whole allocated array)
    */

    ref T opIndex( size_t index ) {
        return rawdata[index];
    }

    Array!T opSlice( size_t start, size_t end ) {
        assert( start < end );
        assert( end <= length );

        Array!T ret;
        ret.reserve( end - start );
        foreach ( i; start..end ) {
            ret ~= this[i];
        }
        
        return ret;
    }

    T opIndexAssign( T elem, size_t index ) {
        rawdata[index] = elem;
        return elem;
    }

    /**
        Try to assign element by it's own assign realization,
        usefull for Reference's and other template types
    */
    T opIndexAssign( X )( X elem, size_t index ) {
        rawdata[index].opAssign( elem );
        return rawdata[index];
    }

    auto opOpAssign( string op, X )( X elem )
    if ( op == "~" ) {
        insertBack( elem );
    }

    auto opOpAssign( string op )( T elem )
    if ( op == "~" ) {
        insertBack( elem );
    }

    auto opOpAssign( string op )( const( T )[] elem )
    if ( op == "~" ) {
        insertBack( elem );
    }

    auto opOpAssign( string op )( T[] elem )
    if ( op == "~" ) {
        insertBack( elem );
    }

    auto opOpAssign( string op )( Array!T elem )
    if ( op == "~" ) {
        foreach ( el; elem ) {
            insertBack( el );
        }
    }

    int opApply( scope int delegate( ref T ) dg ) {
        int res = 0;

        foreach ( ref elem; rawdata ) {
            res = dg( elem );
            if ( res ) {
                break;
            }
        }

        return res;
    }

    int opApply( scope int delegate( size_t i, ref T ) dg ) {
        int res = 0;

        foreach ( i, ref elem; rawdata ) {
            res = dg( i, elem );
            if ( res ) {
                break;
            }
        }

        return res;
    }

    int opApplyReverse( scope int delegate( size_t i, ref T ) dg ) {
        int res = 0;

        for ( size_t i = length; i-- > 0; ) {
            res = dg( i, rawdata[i] );
            if ( res ) {
                break;
            }
        }

        return res;
    }

    /**
        Return invalidate policity
    */
    pragma( inline, true )
    ArrayPolicity* policity() {
        if ( lpolicity.onFree is null ) {
            lpolicity.onFree = &def_onFree;
        }

        if ( lpolicity.onReallocate is null ) {
            lpolicity.onReallocate = &def_onReallocate;
        }

        if ( lpolicity.onDestruct is null ) {
            lpolicity.onDestruct = &def_onDestruct;
        }

        return &lpolicity;
    }

    import engine.core._reflection;
    import engine.core._variant;
    void reflect( CReflectionBuilder builder ) {
        builder.type!( typeof( this ) ).method!varray;
    }

    
    
    Array!_SVariant varray() {
        Array!_SVariant ret;
        ret.reserve( length );

        foreach ( elem; rawdata ) {
            ret ~= _SVariant( elem );
        }

        return ret;
    }

protected:
    /**
        Allocate new chunk for array using
        policity.onReallocate method
        Params:
            num - number of chunks,
            must be > 0
    */
    void addChunks( size_t num ) {
        assert( num > 0 );
        
        T* newArray = policity.onReallocate( ptr, (data.chunks + num) * CHSIZE, data.pos );
        assert( newArray !is null, "Invalid onReallocate impl!" );
        
        deallocate( data.array );
        
        data.array = cast( void* )newArray;
        data.chunks += num;
    }

    /**
        Size of array in elements count
    */
    size_t datasize() {
        return data.chunks * data.chsize;
    }

public:
static:
    void _dataInitialize( ArrayData* idata ) {
        idata.chsize = CHSIZE;
        idata.typeinfo = typeid( T );
        idata.array = allocate( CHSIZE * T.sizeof );
        idata.pos = 0;
        idata.chunks = 1;
    }

    void _dataDestruct( ArrayData* idata ) {
        def_onDestruct( cast( T* )idata.array, idata.pos );

        deallocate( idata.array );
    }

    /* Policity standart methods */
    void def_onFree( T elem ) {}
    
    T* def_onReallocate( T* array, size_t expectSize, size_t pos ) {
        T* newArray = cast( T* )allocate( expectSize * T.sizeof );
        Memory.memcpy( cast( void* )newArray, cast( void* )array, pos * T.sizeof );

        return newArray;
    }

    void def_onDestruct( T* elems, size_t pos ) {
        import std.traits;

        // Struct must be called with destructor
        static if ( is( T == struct ) ) {
            foreach ( i; 0..pos ) {
                static if ( hasElaborateDestructor!T ) {
                    typeid( T ).destroy( elems + i );
                }
            }
        }
    }
}

Array!T toArray( T )( T[] arr ) {
    Array!T array;
    array.reserve( arr.length );

    foreach ( el; arr ) {
        array ~= el;
    }

    return array;
}

Array!T toArray( T )( T elem ) {
    Array!T array;
    array ~= elem;
    return array;
}
