module engine.framework.resources._json;

import engine.core.containers;
import engine.core.resource;
import engine.core.utils.ustruct;
import engine.core.log;

enum EJSONClass {
    NULL,
    OBJECT,
    ARRAY,
    STRING,
    FLOAT,
    INT,
    BOOL,
}

class CJSONBackingData : CObject {
    mixin( TRegisterClass!CJSONBackingData );
public:
    Array!CJSON varray;
    Dict!( CJSON, String ) vdict;

    String vstring;
    double vdouble;
    long vint;
    bool vbool;

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
        else static if ( is( T == float ) ) {
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

class CJSON : CObject {
    mixin( TRegisterClass!CJSON );
private:
    EJSONClass ltype = EJSONClass.NULL;
    CJSONBackingData linternal;

public:
    this() {
        linternal = NewObject!CJSONBackingData();
    }

    this( T )( T value ) {
        linternal = NewObject!CJSONBackingData();
        set( value );
    }

    this( EJSONClass itype ) {
        linternal = NewObject!CJSONBackingData();
        ltype = itype;
    }

    ~this() {
        DestroyObject( linternal );
    }

    auto get( T )( T idx ) {
        static if ( is( T == size_t ) || is( T == int ) ) {
            if ( ltype != EJSONClass.ARRAY ) return null;

            return linternal.varray[idx];
        }
        else static if ( is( T == String ) ) {
            return linternal.vdict.get( idx );
        }
        else static if( is( T == string ) ) {
            return get( String( idx ) );
        }
        else {
            static assert( false );
        }
    }

    void set( T )( int idx, T value ) {
        setType( EJSONClass.ARRAY );

        if ( idx >= linternal.varray.length ) {
            linternal.varray.resize( idx + 1 );
        }

        static if ( !is( T == CJSON ) ) {
            linternal.varray[idx] = NewObject!CJSON( value );
        } else {
            linternal.varray[idx] = value;
        }
    }

    void set( T )( String idx, T value ) {
        setType( EJSONClass.OBJECT );

        static if ( !is( T == CJSON ) ) {
            linternal.vdict.set( idx, NewObject!CJSON( value ) );
        } else {
            linternal.vdict.set( idx, value );
        }
    }

    void set( T )( string idx, T value ) { set( String( idx ), value ); }

    void set( T )( T value ) {
        static if ( is( T == bool ) ) {
            setType( EJSONClass.BOOL );
            linternal.vbool = value;
        }
        else static if ( is( T == String ) ) {
            setType( EJSONClass.STRING );
            linternal.vstring = value;
        }
        else static if ( is( T == int ) ) {
            setType( EJSONClass.INT );
            linternal.vint = value;
        }
        else static if ( is( T == float ) ) {
            setType( EJSONClass.FLOAT );
            linternal.vdouble = value;
        }
    }

    T as( T )() {
        static if ( is( T == bool ) ) {
            assert( ltype == EJSONClass.BOOL );

            return linternal.vbool;
        }
        else static if ( is( T == String ) ) {
            assert( ltype == EJSONClass.STRING );

            return linternal.vstring;
        }
        else static if ( is( T == int ) ) {
            assert( ltype == EJSONClass.INT );

            return cast( int )linternal.vint;
        }
        else {
            return T.init;
        }
    }

    bool isNull() { return ltype == EJSONClass.NULL; }

    String dump( int depth = 1 ) {
        String pad = "";
        foreach ( i; 0..depth ) { pad ~= "  "; }

        switch ( ltype ) {
        case EJSONClass.NULL:
            return rs!"null";

        case EJSONClass.OBJECT: {
            String s = "{\n";
            bool bSkip = true;
            foreach ( k, v; linternal.vdict ) {
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

        case EJSONClass.ARRAY: {
            String s = "[";
            bool bSkip = true;

            foreach ( elem; linternal.varray ) {
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

        case EJSONClass.STRING:
            return String( "\"", linternal.vstring, "\"" );

        case EJSONClass.FLOAT:
            return String( linternal.vdouble );

        case EJSONClass.INT:
            return String( linternal.vint );

        case EJSONClass.BOOL:
            return String( linternal.vbool );

        default:
            return String();
        }
    }

private:
    void clearInternal() {
        linternal.varray.free();
        linternal.vdict.free();
    }

    void setType( EJSONClass type ) {
        if ( ltype == type ) return;

        clearInternal();
        ltype = type;
    }

public:
    auto opIndex( U )( U u ) {
        return get( u );
    }

    auto opIndexAssign( T )( T t, int idx ) { set( idx, t ); }
    auto opIndexAssign( T )( T t, String idx ) { set( idx, t ); }
    auto opIndexAssign( T )( T t, string idx ) { set( idx, t ); }
}

struct SJSONParser {
    static bool isSpace( Char ch ) {
        return
            ch == '\t' ||
            ch == '\n' ||
            ch == ' ';
    }

    static void skipWhitespace( ref String str, ref size_t offset ) {
        while ( isSpace( str[offset] ) ) offset++;
    }

    static CJSON parse_object( ref String str, ref size_t offset ) {
        CJSON object = NewObject!CJSON( EJSONClass.OBJECT );

        offset++;
        skipWhitespace( str, offset );
        if ( str[offset] == '}' ) {
            offset++;
            return object;
        }

        while ( true ) {
            CJSON key = parse_next( str, offset );
            skipWhitespace( str, offset );
            if ( str[offset] != ':' ) {
                log.error( "Error: Object: Expected colon, found '", str[offset], "'" );
                break;
            }

            offset++;
            skipWhitespace( str, offset );

            CJSON value = parse_next( str, offset );
            object[key.as!String] = value;

            skipWhitespace( str, offset );
            if ( str[offset] == ',' ) {
                offset++;
                continue;
            }
            else if ( str[offset] == '}' ) {
                offset++;
                break;
            }
            else {
                log.error( "Error: Object: Expected comma, found '", str[offset], "'" );
                break;
            }
        }

        return object;
    }

    static CJSON parse_array( ref String str, ref size_t offset ) {
        CJSON array = NewObject!CJSON( EJSONClass.ARRAY );
        uint index = 0;

        offset++;
        skipWhitespace( str, offset );
        if ( str[offset] == ']' ) {
            offset++;
            return array;
        }

        while ( true ) {
            array[index++] = parse_next( str, offset );
            skipWhitespace( str, offset );

            if ( str[offset] == ',' ) {
                offset++;
                continue;
            }
            else if ( str[offset] == ']' ) {
                offset++;
                break;
            }
            else {
                log.error( "Error: Array: Expected ',', or ']', found '", str[offset], "'" );
                DestroyObject( array );
                return NewObject!CJSON( EJSONClass.ARRAY );
            }
        }

        return array;
    }

    static CJSON parse_string( ref String str, ref size_t offset ) {
        CJSON lstring = NewObject!CJSON( EJSONClass.STRING );
        String val;

        for ( Char c = str[++offset]; c != '\"'; c = str[++offset] ) {
            if ( c != '\\' ) {
                val ~= c;
                continue;
            }

            switch ( str[++offset] ) {
                case '\"': val ~= '\"'; break;
                case '\\': val ~= '\\'; break;
                case '/': val ~= '/'; break;
                case 'b': val ~= '\b'; break;
                case 'f': val ~= '\f'; break;
                case 'n': val ~= '\n'; break;
                case 'r': val ~= '\r'; break;
                case 't': val ~= '\t'; break;
                //case 'u': val ~= '\u'; break;

                default: val ~= '\\'; break;
            }
        }

        offset++;

        lstring.set( val );
        return lstring;
    }

    static CJSON parse_number( ref String str, ref size_t offset ) {
        CJSON number = NewObject!CJSON( EJSONClass.INT );

        String val;
        Char c;
        bool bDouble = false;

        while ( true ) {
            c = str[offset++];
            if ( (c == '-') || (c >= '0' && c <= '9') ) {
                val ~= c;
            } else if ( c == '.' ) {
                val ~= c;
                bDouble = true;
            } else {
                break;
            }
        }

        --offset;

        int ret = 0;
        bool bMin = val[0] == '-';

        int idx = bMin ? 1 : 0;

        foreach ( i; idx..val.length ) {
            ret = ret * 10 + val[i] - '0';
        }

        if ( bMin ) {
            ret *= -1;
        }

        number.set( ret );

        return number;
    }

    static CJSON parse_bool( ref String str, ref size_t offset ) {
        CJSON lbool = NewObject!CJSON( EJSONClass.BOOL );

        if ( str.substr( offset, 4 ) == "true" ) {
            lbool.set( true );
        }
        else if ( str.substr( offset, 5 ) == "false" ) {
            lbool.set( false );
        }
        else {
            log.error( "Error: Bool: Expected 'true' or 'false', found '", str.substr( offset, 5 ), "'" );
            DestroyObject( lbool );
            return NewObject!CJSON( EJSONClass.NULL );
        }

        offset += lbool.as!bool ? 4 : 5;

        return lbool;
    }

    static CJSON parse_null( ref String str, ref size_t offset ) {
        CJSON lnull = NewObject!CJSON( EJSONClass.NULL );

        if ( str.substr( offset, 4 ) != "null" ) {
            log.error( "Error: Null: Expected 'null', found '", str.substr( offset, 4 ), "'" );
            return lnull;
        }

        offset += 4;

        return lnull;
    }

    static CJSON parse_next( ref String str, ref size_t offset ) {
        Char value;
        
        skipWhitespace( str, offset );

        value = str[offset];
        
        switch ( value ) {
            case '[': return parse_array( str, offset );
            case '{': return parse_object( str, offset );
            case '\"': return parse_string( str, offset );
            case 't': return parse_bool( str, offset );
            case 'f': return parse_bool( str, offset );
            case 'n': return parse_null( str, offset );

            default:
                if ( (value <= '9' && value >= '0') || value == '-' ) {
                    return parse_number( str, offset );
                }
        }

        log.error( "Error: Parse: Unknown starting character '", value, "'" );
        return null;
    }

    static CJSON parse( String str ) {
        size_t offset = 0;
        return parse_next( str, offset );
    }
}
