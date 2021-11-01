module engine.core.serialization;

import engine.core.object;
import engine.core.string;
import engine.core.containers;
import engine.core.typedefs;
import engine.core.log;

interface ISerializeBackend {
    RawData serialize( CArchive archive );
    CArchive deserialize( RawData data );
}

interface ISerializable {
    void serialize( CArchive archive );
    void deserialize( CArchive archive );
}

struct SArchivePacker {
    static CArchive pack( CObject object ) {
        assert( object );
        assert( object.classDescription );

        CClassDescription description = object.classDescription;
        CCDC_Serialize sr = description.get!CCDC_Serialize();

        rClass rclass = description.rclass;

        CArchive archive = NewObject!CArchive();

        CArchiveMember fields = NewObject!CArchiveMember( EArchiveDataType.OBJECT );
        CArchiveMember typeinfo = NewObject!CArchiveMember( EArchiveDataType.OBJECT );
        // Other objects serialized into separeted field
        CArchiveMember objects = NewObject!CArchiveMember( EArchiveDataType.ARRAY );

        typeinfo["type"] = String( rclass.name );

        archive["__fields"] = fields;
        archive["__typeinfo"] = typeinfo;
        archive["__external_objects"] = objects;

        foreach ( fieldName; sr.lvalues ) {
            rField field = rclass.getField( fieldName.c_str );
            if ( !field ) continue;

            rSymbol fieldType = field.fieldType;
            TypeInfo typeId = field.typeId;

            var vobject = var( object );
            var value = field.getValue( vobject );

            log.warning( typeId.toString, " ", value.type.toString );

            if ( typeId is typeid( bool ) ) {
                fields[field.name] = value.as!bool;
            }
            else if ( typeId is typeid( int ) ) {
                fields[field.name] = value.as!int;
            }
            else if ( typeId is typeid( long ) ) {
                fields[field.name] = value.as!long;
            }
            else if ( typeId is typeid( ulong ) ) {
                fields[field.name] = value.as!ulong;
            }
            else if ( typeId is typeid( size_t ) ) {
                fields[field.name] = cast( long )value.as!size_t;
            }
            else if ( typeId is typeid( String ) ) {
                fields[field.name] = String( value.as!String );
            }
            else if ( fieldType is reflect!CObject ) {
            }
            else {
                void* arrayPtr = field.getValueAsPtr( vobject ).as!( void* );
                void* arrayDataPtr = arrayPtr + Array!int.ldata.offsetof;
                SArrayData* arrayData = cast( SArrayData* )arrayDataPtr;
                log.warning( arrayData.typeinfo is null );
            }
        }

        return archive;
    }

    static bool unpack( CObject object, CArchive archive ) { return false; }
}

enum EArchiveDataType {
    NULL,
    OBJECT,
    ARRAY,
    STRING,
    FLOAT,
    INT,
    BOOL,
}

class CArchiveBackingData : CObject {
    mixin( TRegisterClass!CArchiveBackingData );
public:
    Array!CArchiveMember varray;
    Dict!( CArchiveMember, String ) vdict;

    String vstring;
    double vdouble;
    long vint;
    bool vbool;

public:
    this( T )( T value ) {
        static if ( is( T == bool ) ) {
            vbool = value;
        }
        else static if ( is( T == String ) ) {
            vstring = value;
        }
        else static if ( is( T == int ) ) {
            vint = value;
        }
        else static if ( is( T == long ) ) {
            vint = value;
        }
        else static if ( is( T == ulong ) ) {
            vint = value;
        }
        else static if ( is( T == float ) ) {
            vdouble = value;
        }
        else static if ( is( T == double ) ) {
            vdouble = value;
        }
    }

    ~this() {
        foreach ( elem; varray ) {
            DestroyObject( elem );
        }

        foreach ( k, v; vdict ) {
            DestroyObject( v );
        }

        varray.free();
        vdict.free();
    }
}

class CArchiveMember : CObject {
    mixin( TRegisterClass!CArchiveMember );
private:
    EArchiveDataType ltype;
    CArchiveBackingData ldata;

public:
    this() {
        ldata = NewObject!CArchiveBackingData();
    }

    this( T )( T value ) {
        ldata = NewObject!CArchiveBackingData();
        set( value );
    }

    this( EArchiveDataType itype ) {
        ldata = NewObject!CArchiveBackingData();
        ltype = itype;
    }

    ~this() {
        DestroyObject( ldata );
    }

    auto get( T )( T idx ) {
        static if ( is( T == size_t ) || is( T == int ) ) {
            if ( ltype != EArchiveDataType.ARRAY ) return null;

            return ldata.varray[idx];
        }
        else static if ( is( T == String ) ) {
            return ldata.vdict.get( idx );
        }
        else static if( is( T == string ) ) {
            return get( String( idx ) );
        }
        else {
            static assert( false );
        }
    }

    void set( T )( int idx, T value ) {
        setType( EArchiveDataType.ARRAY );

        if ( idx >= ldata.varray.length ) {
            ldata.varray.resize( idx + 1 );
        }

        CArchiveMember member = ldata.varray[idx];

        if ( member ) {
            DestroyObject( member );
        }

        static if ( !is( T == CArchiveMember ) ) {
            ldata.varray[idx] = NewObject!CArchiveMember( value );
        } else {
            ldata.varray[idx] = value;
        }
    }

    void set( T )( String idx, T value ) {
        setType( EArchiveDataType.OBJECT );

        if ( ldata.vdict.has( idx ) ) {
            DestroyObject( ldata.vdict.get( idx ) );
        }

        static if ( !is( T == CArchiveMember ) ) {
            ldata.vdict.set( idx, NewObject!CArchiveMember( value ) );
        } else {
            ldata.vdict.set( idx, value );
        }
    }

    void set( T )( string idx, T value ) { set( String( idx ), value ); }

    void set( T )( T value ) {
        static if ( is( T == bool ) ) {
            setType( EArchiveDataType.BOOL );
            ldata.vbool = value;
        }
        else static if ( is( T == String ) ) {
            setType( EArchiveDataType.STRING );
            ldata.vstring = value;
        }
        else static if ( is( T == int ) ) {
            setType( EArchiveDataType.INT );
            ldata.vint = value;
        }
        else static if ( is( T == float ) ) {
            setType( EArchiveDataType.FLOAT );
            ldata.vdouble = value;
        }
    }

    T as( T )() {
        static if ( is( T == bool ) ) {
            assert( ltype == EArchiveDataType.BOOL );

            return ldata.vbool;
        }
        else static if ( is( T == String ) ) {
            assert( ltype == EArchiveDataType.STRING );

            return ldata.vstring;
        }
        else static if ( is( T == int ) ) {
            assert( ltype == EArchiveDataType.INT );

            return cast( int )ldata.vint;
        }
        else {
            return T.init;
        }
    }

    bool isNull() { return ltype == EArchiveDataType.NULL; }

    String dump( int depth = 1 ) {
        String pad = "";
        foreach ( i; 0..depth ) { pad ~= "  "; }

        switch ( ltype ) {
        case EArchiveDataType.NULL:
            return rs!"null";

        case EArchiveDataType.OBJECT: {
            String s = "{\n";
            bool bSkip = true;
            foreach ( k, v; ldata.vdict ) {
                if ( !bSkip ) {
                    s ~= ",\n";
                }

                if ( v ) {
                    s ~= String( pad, "\"", k, "\": ", v.dump( depth + 1 ) );
                } else {
                    s ~= String( pad, "\"", k, "\": ", "null" );
                }

                bSkip = false;
            }

            s ~= String( "\n", pad, "}" );

            return s;
        }

        case EArchiveDataType.ARRAY: {
            String s = "[";
            bool bSkip = true;

            foreach ( elem; ldata.varray ) {
                if ( !bSkip ) {
                    s ~= ", ";
                }

                if ( elem ) {
                    s ~= elem.dump( depth + 1 );
                } else {
                    s ~= "null";
                }

                bSkip = false;
            }

            s ~= "]";
            return s;
        }

        case EArchiveDataType.STRING:
            return String( "\"", ldata.vstring, "\"" );

        case EArchiveDataType.FLOAT:
            return String( ldata.vdouble );

        case EArchiveDataType.INT:
            return String( ldata.vint );

        case EArchiveDataType.BOOL:
            return String( ldata.vbool );

        default:
            return String();
        }
    }

private:
    void clearData() {
        ldata.varray.free();
        ldata.vdict.free();
    }

    void setType( EArchiveDataType type ) {
        if ( ltype == type ) return;

        clearData();
        ltype = type;
    }

public:
    auto opIndex( U )( U u ) { return get( u ); }

    auto opIndexAssign( T )( T t, int idx ) { set( idx, t ); }
    auto opIndexAssign( T )( T t, String idx ) { set( idx, t ); }
    auto opIndexAssign( T )( T t, string idx ) { set( idx, t ); }
}

class CArchive : CObject {
    mixin( TRegisterClass!CArchive );
public:
    CArchiveMember root;
    alias root this;

public:
    this() {
        root = NewObject!CArchiveMember();
    }

    ~this() {
        DestroyObject( root );
    }
}
