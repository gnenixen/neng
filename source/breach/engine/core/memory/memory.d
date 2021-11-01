module engine.core.memory.memory;

import std.conv;
import std.traits;
import std.format;

import engine.core.memory.allocator;
import engine.core.memory.utils;

alias Memory = SMemory;

static __gshared struct SMemory {
static __gshared:
    enum PREF_SIZE = 8; // Prefix, handle object size
    enum POST_SIZE = 8; // Postfix, handle ref count

    enum ADD_SIZE = PREF_SIZE + POST_SIZE;

public static __gshared:
    bool bProfileEnabled = true;

    size_t allocatedMemory = 0;
    size_t allocationsCount = 0;

    SAllocator gallocator;

private static __gshared:
    SRawDList!( void* ) loneFrame;

public static __gshared:
    alias refcount = postfix;

    void initialize( SAllocator allocator ) {
        assert( !isInitialized(), "Memory already initialized!" );
        gallocator = allocator;
        assert( isInitialized(), "Invalid allocator!" );
    }

    void deinitialize() {}

    void update() {
        assert( isInitialized() );

        foreach ( id, data; loneFrame ) {
            deallocate( data );
        }

        loneFrame.clear();
    }

    void* allocate( size_t size ) {
        void* ptr = gallocator.allocate( size + ADD_SIZE );
        memset( ptr, 0, size + ADD_SIZE );

        prefix( ptr + PREF_SIZE ) = size;
        postfix( ptr + PREF_SIZE ) = 1;

        allocatedMemory += size;
        allocationsCount++;

        return blkdata( ptr );
    }

    void deallocate( void* block ) {
        assert( isInitialized() );
        assert( block );

        size_t size = prefix( block );

        allocatedMemory -= size;
        allocationsCount--;

        gallocator.deallocate( block - PREF_SIZE );
    }

    /**
        Reallocate block with new size
        If size is same - do nothing
        Overwrite debug info with new size
    */
    void* reallocate( void* block, size_t nsize ) {
        assert( isInitialized() );
        assert( block );
        assert( nsize > 0 );

        nsize += ADD_SIZE;
        size_t psize = prefix( block );

        if ( psize == nsize ) {
            return block;
        }

        block = gallocator.reallocate( block - PREF_SIZE, nsize );

        allocatedMemory += nsize - psize;

        prefix( block + PREF_SIZE ) = nsize;

        return blkdata( block );
    }

    ref size_t prefix( void* data ) {
        void* begin = data - PREF_SIZE;
        void[] pref = cast( void[] )( begin )[0..PREF_SIZE];
        return *cast( size_t* )( pref.ptr );
    }

    ref size_t postfix( void* data ) {
        size_t size = prefix( data );
        void[] post = cast( void[] )( data )[size..size + POST_SIZE];
        return *cast( size_t* )( post.ptr );
    }

    void* blkdata( void* data ) {
        return data + PREF_SIZE;
    }

    /**
        Given memory will be freed at the end of frame
    */
    void markOneFrame( void* ptr ) {
        assert( ptr );
        loneFrame.insertBack( ptr );
    }

    pragma( inline, true )
    bool isValid( void* ptr ) {
        return ptr !is null;
    }

    pragma( inline, true )
    void* memcpy( void* dst, const void* src, size_t size ) {
        import core.stdc.string : _c_memcpy = memcpy;
        import core.memory : GC;
        void* ret;

        //GC.disable();
            ret = _c_memcpy( dst, src, size );
        //GC.enable();

        return ret;
    }

    pragma( inline, true )
    void* memset( return void* src, int val, size_t num ) {
        import core.stdc.string : _c_memset = memset;
        import core.memory : GC;
        void* ret;

        //GC.disable();
            ret = _c_memset( src, val, num );
        //GC.enable();

        return ret;
    }

    void* memzero( return void* src, size_t num ) {
        return memset( src, 0, num );
    }

    /*   HELP FUNCTIONS   */
    bool isValid( Object obj ) {
        return isValid( cast( void* )obj );
    }

    bool isInitialized() {
        return 
            gallocator.allocate !is null &&
            gallocator.deallocate !is null &&
            gallocator.reallocate !is null;
    }
}



void* allocate( size_t size ) {
    assert( Memory.isInitialized() );

    return Memory.allocate( size );
}

T allocate( T, Args... )( Args args )
if ( is( T == class ) ) {
    assert( Memory.isInitialized() );

    //enum size = __traits( classInstanceSize, T );
    ClassInfo ci = T.classinfo;
    size_t size = ci.initializer.length;

    void* ptr = Memory.allocate( size );

    return _emplace!( T, Args )( ptr[0..size], args );
}

T* allocate( T, Args... )( Args args )
if ( is( T == struct ) ) {
    assert( Memory.isInitialized() );

    enum size = T.sizeof;

    void* ptr = Memory.allocate( size);

    return emplace!( T, Args )( ptr[0..size], args );
}

T allocate( T )( size_t len )
if ( isArray!T ) {
    import std.range.primitives : ElementType;

    assert( Memory.isInitialized() );

    alias AT = ElementType!T;
     
    size_t size = len * AT.sizeof;
    auto mem = Memory.allocate( size );

    AT defVal = AT.init;
    T arr = cast( T )( mem[0..size] );

    foreach ( i, ref v; arr ) {
        // Initialize struct by raw memory set
        static if ( is( AT == struct ) ) {
            size_t pos = i * AT.sizeof;
            Memory.memcpy( mem + pos, cast( void* )&defVal, AT.sizeof );
        } else {
            v = v.init;
        }
    }

    return arr;
}

void deallocate( T )( T obj )
if ( is( T == class ) || is( T == interface ) ) {
    assert( Memory.isInitialized() );

    if ( obj is null ) {
        return;
    }

    Object o = cast( Object )obj;
    void* ptr = cast( void* )o;

    destroy( o );
    Memory.deallocate( ptr );

    obj = null;
}

void deallocate( T )( T* obj ) {
    assert( Memory.isInitialized() );

    if ( obj is null ) {
        return;
    }

    void* ptr = cast( void* )obj;

    destroy( obj );
    Memory.deallocate( ptr );
}

void deallocate( T )( T obj )
if ( isArray!T ) {
    assert( Memory.isInitialized() );

    if ( obj is null ) {
        return;
    }

    void* p = cast( void* )obj.ptr;
    Memory.deallocate( p );
}

void deallocate( void* ptr ) {
    assert( Memory.isInitialized() );

    if ( ptr is null ) {
        return;
    }

    Memory.deallocate( ptr );
}

/*   */

// For correct info pass
T allocateEx( T, Args... )( string file, int line, Args args )
if ( is( T == class ) ) {
    assert( Memory.isInitialized() );

    enum size = __traits( classInstanceSize, T );
    
    void* ptr = Memory.allocate( size );

    return emplace!( T, Args )( ptr[0..size], args );
}

T* allocateEx( T, Args... )( string file, int line, Args args )
if ( is( T == struct ) ) {
    assert( Memory.isInitialized() );

    enum size = T.sizeof;

    void* ptr = Memory.allocate( size );

    return emplace!( T, Args )( ptr[0..size], args );
}

void* reallocate( void* data, size_t size ) {
    assert( Memory.isInitialized() );

    // ANSI C behaviour, when realloc( NULL, size ) is equivalent to malloc( size )
    if ( !data ) {
        return allocate( size );
    }

    return Memory.reallocate( data, size );
}

template forward(args...)
{
    import core.internal.traits : AliasSeq;

    static if (args.length)
    {
        alias arg = args[0];
        // by ref || lazy || const/immutable
        static if (__traits(isRef,  arg) ||
                   __traits(isOut,  arg) ||
                   __traits(isLazy, arg) ||
                   !is(typeof(move(arg))))
            alias fwd = arg;
        // (r)value
        else
            @property auto fwd(){ return move(arg); }

        static if (args.length == 1)
            alias forward = fwd;
        else
            alias forward = AliasSeq!(fwd, forward!(args[1..$]));
    }
    else
        alias forward = AliasSeq!();
}

T _emplace(T, Args...)(void[] chunk, auto ref Args args)
    if (is(T == class))
{
    import core.internal.traits : maxAlignment;

    //enum classSize = __traits(classInstanceSize, T);
    size_t classSize = T.classinfo.initializer.length;
    assert(chunk.length >= classSize, "chunk size too small.");

    enum alignment = maxAlignment!(void*, typeof(T.tupleof));
    assert((cast(size_t) chunk.ptr) % alignment == 0, "chunk is not aligned.");

    return _emplace!T(cast(T)(chunk.ptr), forward!args);
}

T _emplace( T, Args... )( T chunk, auto ref Args args )
if ( is( T == class ) ) {
    import core.internal.traits : isInnerClass;

    static assert( !__traits( isAbstractClass, T ) );

    size_t classsize = T.classinfo.initializer.length;
    (cast(void*)chunk)[0..classsize] = T.classinfo.initializer[];

    static if (isInnerClass!T)
    {
        static assert(Args.length > 0,
            "Initializing an inner class requires a pointer to the outer class");
        static assert(is(Args[0] : typeof(T.outer)),
            "The first argument must be a pointer to the outer class");

        chunk.outer = args[0];
        alias args1 = args[1..$];
    }
    else alias args1 = args;

    // Call the ctor if any
    static if (is(typeof(chunk.__ctor(forward!args1))))
    {
        // T defines a genuine constructor accepting args
        // Go the classic route: write .init first, then call ctor
        chunk.__ctor(forward!args1);
    }
    else
    {
        static assert(args1.length == 0 && !is(typeof(&T.__ctor)),
            "Don't know how to initialize an object of type "
            ~ T.stringof ~ " with arguments " ~ typeof(args1).stringof);
    }
    return chunk;
}

