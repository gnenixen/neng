module engine.core._variant;

import std.meta;
import std.traits;

import engine.core.memory;
import engine.core.ref_count;

protected {
    enum EOperation : int {
        READ,
        WRITE,
        //COPY,
        DESTRUCT,
        POINTER,
        TYPE,
        //CLEAR,
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

    interface IVariantData {
        bool operator( uint opAndFlags, void* param, TypeInfo ti );
    }

    final class CVariantData( T ) : IVariantData {
    private:
        T ldata;

    public:
        bool operator( uint opAndFlags, void* param, TypeInfo ti ) {
            EOperation op = cast( EOperation )( opAndFlags & 0xFFFFu );

            final switch ( op ) {
                case EOperation.WRITE:
                    ldata = *cast( T* )param;
                    return true;

                case EOperation.READ:
                    *cast( T* )param = cast( T )ldata;
                    return true;

                //case EOperation.COPY:
                    //break;

                case EOperation.DESTRUCT:
                    static if ( is( T : Object ) || isPointer!T ) {
                        deallocate( ldata );
                    }
                    return true;

                case EOperation.POINTER:
                    *cast( void** )param = cast( void* )&ldata;
                    return true;

                case EOperation.TYPE:
                    *cast( TypeInfo* )param = typeid( T );
                    return true;

                //case EOperation.CLEAR:
                    //break;
            }

            //return false;
        }
    }

    struct SVariantRefDataHandler {
        IVariantData data = null;
    }
}

struct _SVariant {
    mixin( TRefCountable!( "SVariantRefDataHandler" ) );
public:
    this( T )( auto ref T value ) {
        opAssign( value );
    }

    void opAssign( T )( auto ref T value ) {
        if ( !isEmpty() ) {
            handler!T.operator( EOperation.DESTRUCT, null, null );
        }

        static if ( is( Unqual!T == _SVariant ) ) {
            if ( value.data ) {
                void* p;
                value.handler.operator( EOperation.POINTER, &p, null );

                if ( p ) {
                    handler!T.operator( EOperation.WRITE, p, null );
                }
            }
        } else {
            handler!T.operator( EOperation.WRITE, &value, null );
        }
    }

    T opCast( T )()
    if ( isSupportedType!T ) {
        static if ( is( T == _SVariant ) ) { return this; }
        else {
            TypeInfo handleTi;
            TypeInfo ti = typeid( T );

            assert( !isEmpty(), "Trying to read data from emtry varint" );

            handler.operator( EOperation.TYPE, cast( void* )&handleTi, null );

            //assert( handleTi is ti, String( "Cannot cast from '", handleTi.toString(), "' to '", T.stringof, "'" ) );
            assert( handleTi is ti, "Invalid cast types" );

            T ret;
            handler!T.operator( EOperation.READ, &ret, null );

            return ret;
        }
    }

    TypeInfo typeinfo() {
        assert( !isEmpty() );
        
        TypeInfo ti;
        handler.operator( EOperation.TYPE, &ti, null );

        return ti;
    }

    void* ptr() {
        assert( !isEmpty() );

        void* ret;
        handler.operator( EOperation.POINTER, &ret, null );

        return ret;
    }

    T as( T )() { return opCast!T(); }

    bool isEmpty() {
        return data.data is null;
    }

protected:
    IVariantData handler( T = void )() {
        static if ( !is( T == void ) ) {
            if ( data.data is null ) {
                data.data = allocate!( CVariantData!T );
            } else {
                TypeInfo handleTi;
                TypeInfo ti = typeid( T );

                data.data.operator( EOperation.TYPE, &handleTi, null );

                if ( handleTi !is ti ) {
                    deallocate( data.data );

                    data.data = allocate!( CVariantData!T );
                }
            }
        }

        return data.data;
    }


static:
    void _dataInitialize( SVariantRefDataHandler* idata ) {}

    void _dataDestruct( SVariantRefDataHandler* idata ) {
        if ( idata.data ) {
            deallocate( idata.data );
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
