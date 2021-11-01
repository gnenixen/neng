module engine.core.variant;

import std.meta;
import std.traits;
import std.stdio;

import engine.core.memory;
import engine.core.ref_count;

//From now we have dynamic typed D! :D
alias var = SVariant;

protected {
    enum EOperation : int {
        TYPE,
        WRITE,
        READ,
        CLEAR,
        POINTER,
        DESTRUCT,
        COPY,
    }

    enum EScalarType : int {
        BOOL,
        BYTE, UBYTE,
        SHORT, USHORT,
        INT, UINT,
        LONG, ULONG,
        FLOAT,
        DOUBLE,
        REAL,
        CHAR, WCHAR, DCHAR,
    }

    alias ScalarTypes =
    AliasSeq!(
        bool,
        byte, ubyte,
        short, ushort,
        int, uint,
        long, ulong,
        float, 
        double,
        real,
        char, wchar, dchar,
    );

    template isSupportedScalarType( T ) {
        enum isSupportedScalarType = staticIndexOf!( T, ScalarTypes ) >= 0;
    }

    template isSupportedType( T ) {
        enum isSupportedType =
            is( T == typeof( null ) ) ||
            is( T == class ) ||
            is( T == interface ) ||
            is( T == struct ) ||
            is( T == enum ) ||
            isSupportedScalarType!T ||
            isArray!T ||
            isPointer!T ||
            is( T == function ) ||
            is( T == delegate );
    }

    enum StorageSize = Largest!( typeof( null ), Object, void*, void[], void delegate(), long, real, float[4] ).sizeof;

    union Storage {
        ubyte[StorageSize] buffer = void;
        void*[StorageSize / ( void* ).sizeof] ptrs;
    }
}

struct SVariantData {
    Storage lstore;
    bool function( Storage* store, uint opAndFlags, void* param, TypeInfo ti ) lfptr;
}

struct SVariant {
    mixin( TRefCountable!( "SVariantData" ) );
public:
    this( T )( auto ref T value ) {
        opAssign( value );
    }

    auto lfptr( Storage* store, uint opAndFlags, void* param, TypeInfo ti ) { return data.lfptr( store, opAndFlags, param, ti ); }

    void free() {
        if ( !isEmpty() ) {
            lfptr( &data.lstore, EOperation.DESTRUCT, null, null );
            data.lfptr = &fun!void;
        }
    }

    void opAssign( T )( auto ref T value ) {
        if ( !isEmpty() ) {
            lfptr( &data.lstore, EOperation.DESTRUCT, null, null );
        }

        static if ( is ( Unqual!T == SVariant ) ) {
            data.lfptr = value.lfptr;
            lfptr( &data.lstore, EOperation.COPY, &value.data.lstore, null );
        } else {
            alias U = UnqualR!T;
            data.lfptr = &fun!U;
            lfptr( &data.lstore, EOperation.WRITE, &value, null );
        }
    }

    T opCast( T )()
    if ( isSupportedType!T ) {
        static if ( is( T == class ) || is( T == interface ) ) {
            Object obj;
            if ( lfptr( cast( Storage* )&data.lstore, EOperation.READ, &obj, typeid( Object ) ) ) {
                static if ( !is( T == Object ) ) {
                    if ( obj is null ) {
                        return null;
                    }

                    if ( T ret = cast(T)obj ) {
                        return ret;
                    }
                } else {
                    return obj;
                }
            }
        } else static if( isArray!T ) {
            void[] arr;
            if ( lfptr( cast( Storage* )&data.lstore, EOperation.READ, &arr, typeid( void[] ) ) ) {
                return cast( T )arr;
            }
        } else static if( isPointer!T ) {
            void* ptr;
            if ( lfptr( cast( Storage* )&data.lstore, EOperation.READ, &ptr, typeid( void* ) ) ) {
                return cast( T )ptr;
            }
        } else static if ( isSupportedScalarType!T ) {
            alias U = UnqualR!T;
            int opAndFlags = EOperation.READ | ( staticIndexOf!( U, ScalarTypes ) << 16 );

            U ret;
            if ( lfptr( cast( Storage* )&data.lstore, opAndFlags, &ret, typeid( U ) ) ) {
                return ret;
            }
        } else static if ( is( T == SVariant ) ) { // Sometimes need to receive variant as argument
            return this;
        } else {
            alias U = UnqualR!T;

            U ret;
            if ( lfptr( cast( Storage* )&data.lstore, EOperation.READ, &ret, typeid( U ) ) ) {
                return ret;
            }
        }

        assert( 0, "Cannot cast from '" ~ ( isEmpty() ? "<empty>" : type.toString() ) ~ "' to '" ~ T.stringof ~ "'" );
    }

    @property TypeInfo type() {
        assert( !isEmpty(), "SVariant cannot be empty" );
        TypeInfo ti;
        lfptr( cast( Storage* )&data.lstore, EOperation.TYPE, &ti, null );
        return ti;
    }

    @property void* ptr() {
        assert( !isEmpty(), "SVariant cannot be empty" );
        void* ptr;
        lfptr( cast( Storage* )&data.lstore, EOperation.POINTER, &ptr, null );
        return cast( void* )ptr;
    }

    void clear() {
        lfptr( cast( Storage* )&data.lstore, EOperation.CLEAR, null, null );
        data.lfptr = &fun!void;
    }

    @property bool isEmpty() {
        return data.lfptr == &fun!void || data.lfptr is null;
    }

    T as( T )() {
        static if ( is( T == bool ) ) {
            return cast( bool )opCast!int();
        } else static if ( is( T == SVariant ) ){
            return this;
        } else {
            return opCast!T();
        }
    }

    void writeAsRawData( void* idata ) {
        assert( !isEmpty(), "SVariant cannot be empty" );
        lfptr( cast( Storage* )&data.lstore, EOperation.WRITE, &idata, null  );
    }

private:
    static bool fun( T : void )( Storage* store, uint opAndFlags, void* param, TypeInfo ti ) {
        return false;
    }

    static bool fun( T )( Storage* store, uint opAndFlags, void* param, TypeInfo ti ) {
        EOperation op = cast( EOperation )( opAndFlags & 0xFFFFu );

        final switch( op ) {
            case EOperation.WRITE:
                static if( T.sizeof <= StorageSize ) {
                    store.buffer[0..T.sizeof] = ( cast( ubyte* )param )[0..T.sizeof];
                    store.buffer[T.sizeof..$] = 0;

                    static if ( hasElaborateAssign!T ) {
                        T.init.opAssign( *cast( T* )store.buffer.ptr );
                    } else static if ( hasElaborateCopyConstructor!T ) {
                        typeid( T ).postblit( cast( T* )store.buffer.ptr );
                    }

                    return true;
                } else {
                    T* cpy = cast( T* )allocate( T.sizeof );
                    Memory.memcpy( cpy, param, T.sizeof );

                    static if ( hasElaborateAssign!T ) {
                        T.init.opAssign( *cpy );
                    } else static if ( hasElaborateCopyConstructor!T ) {
                        typeid( T ).postblit( cpy );
                    }

                    *cast( T** )store.buffer.ptr = cpy;
                    store.buffer[( T* ).sizeof..$] = 0;
                    return true;
                }
            case EOperation.READ:
                static if ( is ( T == class ) || is( T == interface ) ) {
                    if ( ti == typeid( Object ) ) {
                        T obj = *cast( T* )store.buffer.ptr;
                        *cast( Object* )param = cast( Object )obj;
                        return true;
                    }
                } else static if ( isArray!T ) {
                    if ( ti == typeid( void[] ) ) {
                        T ary = *cast( T* )store.buffer.ptr;
                        *cast( void[]* )param = cast( void[] )ary;
                        return true;
                    }
                } else static if ( isPointer!T ) {
                    if ( ti == typeid( void* ) ) {
                        T ptr = *cast( T* )store.buffer.ptr;
                        *cast( void** )param = cast( void* )ptr;
                        return true;
                    }
                } else static if ( isSupportedScalarType!T ) {
                    EScalarType sc = cast( EScalarType )( opAndFlags >> 16 );
                    if ( sc != 0 ) {
                        T val = *cast( T* )store.buffer.ptr;

                        final switch( sc ) {
                            case EScalarType.BOOL:   *cast(bool*)param   = cast(bool)val; break;
                            case EScalarType.BYTE:   *cast(byte*)param   = cast(byte)val; break;
                            case EScalarType.UBYTE:  *cast(ubyte*)param  = cast(ubyte)val; break;
                            case EScalarType.SHORT:  *cast(short*)param  = cast(short)val; break;
                            case EScalarType.USHORT: *cast(ushort*)param = cast(ushort)val; break;
                            case EScalarType.INT:    *cast(int*)param    = cast(int)val; break;
                            case EScalarType.UINT:   *cast(uint*)param   = cast(uint)val; break;
                            case EScalarType.LONG:   *cast(long*)param   = cast(long)val; break;
                            case EScalarType.ULONG:  *cast(ulong*)param  = cast(ulong)val; break;
                            case EScalarType.FLOAT:  *cast(float*)param  = cast(float)val; break;
                            case EScalarType.DOUBLE: *cast(double*)param = cast(double)val; break;
                            case EScalarType.REAL:   *cast(real*)param   = cast(real)val; break;
                            case EScalarType.CHAR:   *cast(char*)param   = cast(char)val; break;
                            case EScalarType.WCHAR:  *cast(wchar*)param  = cast(wchar)val; break;
                            case EScalarType.DCHAR:  *cast(dchar*)param  = cast(dchar)val; break;
                        }

                        return true;
                    }
                } else {
                    static if ( T.sizeof <= StorageSize ) {
                        if ( ti == typeid( T ) ) {
                            *cast( T* )param = *cast( T* )store.buffer.ptr;
                            return true;
                        }
                    } else {
                        if ( ti == typeid( T ) ) {
                            *cast( T* )param = **cast( T** )store.buffer.ptr;
                            return true;
                        }
                    }
                }
                break;

            case EOperation.CLEAR:
                store.buffer[0..$] = 0;
                break;

            case EOperation.TYPE:
                static if ( is( T == class ) || is( T == interface ) ) {
                    *cast( TypeInfo* )param = typeid( *cast( T* )store.buffer.ptr );
                } else {
                    *cast( TypeInfo* )param = typeid( T );
                }
                break;

            case EOperation.POINTER:
                static if ( T.sizeof <= StorageSize ) {
                    *cast( void** )param = cast( void* )store.buffer.ptr;
                    return true;
                } else {
                    *cast( void** )param = *cast( void** )store.buffer.ptr;
                    return true;
                }

            case EOperation.DESTRUCT:
                static if ( T.sizeof > StorageSize ) {
                    T* p = *cast( T** )store.buffer.ptr;
                    store.buffer[0..( T* ).sizeof] = 0;

                    static if ( hasElaborateDestructor!T ) {
                        typeid( T ).destroy( p );
                    }

                    deallocate( p );
                } else {
                    static if ( hasElaborateDestructor!T ) {
                        typeid( T ).destroy( cast( T* )store.buffer.ptr );
                    }
                }
                break;

            case EOperation.COPY:
                Storage* from = cast( Storage* )param;
                T* p = null;

                static if ( T.sizeof > StorageSize ) {
                    p = cast( T* )allocate( T.sizeof );
                    Memory.memcpy( p, *cast( T** )from.buffer.ptr, T.sizeof );
                    
                    *cast( T** )store.buffer.ptr = p;
                    store.buffer[(T*).sizeof..$] = 0;
                } else {
                    p = cast( T* )store.buffer.ptr;
                    if ( store != from ) {
                        Memory.memcpy( p, cast( T* )from.buffer.ptr, T.sizeof );
                    }
                }

                static if ( hasElaborateCopyConstructor!T ) {
                    typeid( T ).postblit( p );
                }

                break;
        }

        return false;
    }

static:
    void _dataInitialize( SVariantData* idata ) {
        idata.lfptr = &fun!void;
    }

    void _dataDestruct( SVariantData* idata ) {
        if ( idata.lfptr != &fun!void && idata.lfptr !is null ) {
            idata.lfptr( &idata.lstore, EOperation.DESTRUCT, null, null );
            idata.lfptr = &fun!void;
        }
    }
}

template UnqualR(T)
{
    template Next(S)
    {
        import std.traits : PointerTarget;

        template ArrayElementType(T : T[]) {
            alias ArrayElementType = T;
        }

        static if(isArray!S)
            alias Next = UnqualR!(ArrayElementType!S)[];
        else static if(isPointer!S)
            alias Next = UnqualR!(PointerTarget!S)*;
        else
            alias Next = S;
    }

    static if      (is(T U ==          immutable U)) alias UnqualR = Next!U;
    else static if (is(T U == shared inout const U)) alias UnqualR = Next!U;
    else static if (is(T U == shared inout       U)) alias UnqualR = Next!U;
    else static if (is(T U == shared       const U)) alias UnqualR = Next!U;
    else static if (is(T U == shared             U)) alias UnqualR = Next!U;
    else static if (is(T U ==        inout const U)) alias UnqualR = Next!U;
    else static if (is(T U ==        inout       U)) alias UnqualR = Next!U;
    else static if (is(T U ==              const U)) alias UnqualR = Next!U;
    else                                             alias UnqualR = Next!T;
}
