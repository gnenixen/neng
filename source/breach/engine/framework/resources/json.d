module engine.framework.resources.json;

import engine.core.memory;
import engine.core.containers;
import engine.core.string;
import engine.core.object;
import engine.core.resource;
import engine.core.utils.ustruct;
import engine.core.log;

class CJSONParsedData : CObject {
    mixin( TRegisterClass!CJSONParsedData );
public:
    String source;
    Array!SJSONToken tokens;

    this( String isource, Array!SJSONToken itokens ) {
        source = isource;
        tokens = itokens;
    }

    CJSONValue* root() {
        return allocate!CJSONValue( this, tokens.ptr, tokens.ptr );
    }
}

struct CJSONValue {
    mixin( TRegisterStruct!CJSONValue );
public:
    CJSONParsedData data;
    SJSONToken* token;
    SJSONToken* dataToken;

    Array!(CJSONValue*) _arr;
    Dict!( CJSONValue*, String ) properties;

    this( CJSONParsedData idata, SJSONToken* itoken, SJSONToken* idataToken ) {
        assert( idata !is null );
        assert( itoken !is null );
        assert( idataToken !is null );

        data = idata;
        token = itoken;
        dataToken = idataToken;
    }

    Array!(CJSONValue*) arr() {
        if ( _arr.length != 0 ) return _arr;

        if ( dataToken.type == EJSONType.ARRAY ) {
            foreach ( i; 0..dataToken.size ) {
                SJSONToken* tok = json_getTokenByIndex( dataToken, i );
                if ( tok is null ) continue;

                _arr ~= allocate!CJSONValue( data, tok, tok );
            }
        }

        return _arr;
    }

    auto get( T )( T idx ) {
        static if ( is( T == size_t ) || is( T == int ) ) {
            if ( token.type != EJSONType.ARRAY ) return arr[idx];

            return null;
        }
        else static if ( is( T == String ) ) {
            CJSONValue* val = properties.get( idx, null );
            if ( val !is null ) return val;

            SJSONToken* tok = json_getTokenByKey( data.source, dataToken, idx );
            if ( tok is null ) return null;

            val = allocate!CJSONValue( data, tok, tok + 1 );
            properties.set( idx, val );

            return val;
        } else static if ( is( T == string ) ) {
            return get( String( idx ) );
        }
        else {
            static assert( false );
        }
    }

    bool isNull() { return as!String == "null"; }

    T as( T )() {
        assert( data !is null );
        assert( dataToken !is null );

        String svalue = data.source[dataToken.start..dataToken.end];

        static if ( is( T == bool ) ) {
            return svalue == "true";
        }
        else static if ( is( T == String ) ) {
            return svalue;
        }
        else static if ( is( T == int ) ) {
            int ret = 0;
            bool bMin = svalue[0] == '-';

            int idx = bMin ? 1 : 0;

            foreach ( i; idx..svalue.length ) {
                ret = ret * 10 + svalue[i] - '0';
            }

            if ( bMin ) {
                ret *= -1;
            }

            return ret;
        }
        else {
            return T.init;
        }
    }
}

class CJSONParser {
public:
    static CJSONParsedData parse( String source ) {
        SJSONParser parser;
        Array!SJSONToken tokens;
        int size = json_parse( parser, source, tokens );

        if ( size < 0 ) {
            log.error( "JSON parse ends with error: ", size );
            log.error( source );
            log.error( source.substr( parser.pos - 10, 20 ) );
            log.error( parser.pos, "/", source.length, ":", source[parser.pos], "(", cast( int )source[parser.pos], ")" );
            return null;
        }
        
        tokens.resize( size );
        parser = SJSONParser();

        json_parse( parser, source, tokens );

        return newObject!CJSONParsedData( source, tokens );
    }
}

enum EJSONType {
    UNDEFINED,
    OBJECT,
    ARRAY,
    STRING,
    PRIMITIVE
}

enum EJSONError {
    NOMEM = -1,
    INVAL = -2,
    PART = -3
}

struct SJSONToken {
    EJSONType type;
    int start = -1;
    int end = -1;
    int size = 0;
    int parent = -1;
}

struct SJSONParser {
    uint pos = 0;
    uint toknext = 0;
    int toksuper = -1;
}

SJSONToken* json_allocToken( ref SJSONParser parser, Array!SJSONToken tokens ) {
    SJSONToken* tok;
    if ( parser.toknext >= tokens.length ) return null;
    static int z = 0;

    tok = &tokens.ptr[parser.toknext++];
    tok.start = tok.end = -1;
    tok.size = 0;
    tok.parent = -1;

    return tok;
}

void json_fillToken( SJSONToken* token, EJSONType type, int start, int end ) {
    token.type = type;
    token.start = start;
    token.end = end;
    token.size = 0;
}

int json_parsePrimitive( ref SJSONParser parser, String str, Array!SJSONToken tokens ) {
    SJSONToken* token;
    int start;

    start = parser.pos;
    for ( ; parser.pos < str.length && str[parser.pos] != '\0'; parser.pos++ ) {
        switch ( str[parser.pos] ) {
        case '\t':
        case '\r':
        case '\n':
        case ' ':
        case ',':
        case ']':
        case '}':
            goto found;
        default:
            break;
        }

        if ( str[parser.pos] < 32 || str[parser.pos] >= 127 ) {
            parser.pos = start;
            log.error( "INVAL" );
            return EJSONError.INVAL;
        }
    }

found:
    if ( !tokens.length ) {
        parser.pos--;
        return 0;
    }

    token = json_allocToken( parser, tokens );
    if ( token is null ) {
        parser.pos = start;
        return EJSONError.NOMEM;
    }

    json_fillToken( token, EJSONType.PRIMITIVE, start, parser.pos );
    token.parent = parser.toksuper;
    parser.pos--;
    return 0;
}

int json_parseString( ref SJSONParser parser, String str, Array!SJSONToken tokens ) {
    SJSONToken* token;
    int start = parser.pos;
    
    parser.pos++;

    for ( ; parser.pos < str.length && str[parser.pos] != '\0'; parser.pos++ ) {
        dchar c = str[parser.pos];

        if ( c == '\"' ) {
            if ( !tokens.length ) return 0;

            token = json_allocToken( parser, tokens );
            if ( token is null ) {
                parser.pos = start;
                return EJSONError.NOMEM;
            }

            json_fillToken( token, EJSONType.STRING, start + 1, parser.pos );
            token.parent = parser.toksuper;
            return 0;
        }

        if ( c == '\\' && parser.pos + 1 < str.length ) {
            int i;
            parser.pos++;

            switch ( str[parser.pos] ) {
                case '\"':
                case '/':
                case '\\':
                case 'b':
                case 'f':
                case 'r':
                case 'n':
                case 't':
                    break;

                case 'u':
                    parser.pos++;
                    for ( i = 0; i < 4 && parser.pos < str.length && str[parser.pos] != '\0'; i++ ) {
                        if ( false ) {
                            parser.pos = start;
                            log.error( "INVAL" );
                            return EJSONError.INVAL;
                        }

                        parser.pos++;
                    }

                    parser.pos--;
                    break;

                default:
                    parser.pos = start;
                    log.error( "INVAL" );
                    return EJSONError.INVAL;
            }
        }
    }

    parser.pos = start;
    return EJSONError.PART;
}

int json_parse( ref SJSONParser parser, String str, Array!SJSONToken tokens ) {
    int r;
    int i;
    SJSONToken* token;
    int count = parser.toknext;

    for (; parser.pos < str.length && str[parser.pos] != '\0'; parser.pos++ ) {
        dchar c;
        EJSONType type;

        c = str[parser.pos];
        switch ( c ) {
        case '{':
        case '[':
            count++;
            if ( !tokens.length ) break;

            token = json_allocToken( parser, tokens );
            if ( token is null ) return EJSONError.NOMEM;

            if ( parser.toksuper != -1 ) {
                SJSONToken* t = &tokens.ptr[parser.toksuper];
                t.size++;
                token.parent = parser.toksuper;
            }

            token.type = (c == '{' ? EJSONType.OBJECT : EJSONType.ARRAY);
            token.start = parser.pos;
            parser.toksuper = parser.toknext - 1;
            break;
        case '}':
        case ']':
            if ( !tokens.length ) break;

            type = (c == '}' ? EJSONType.OBJECT : EJSONType.ARRAY);
            if ( parser.toknext < 1 ) {
                log.error( "INVAL" );
                return EJSONError.INVAL;
            }

            token = &tokens.ptr[parser.toknext - 1];
            for ( ;; ) {
                if ( token.start != -1 && token.end == -1 ) {
                    if ( token.type != type ) {
                        log.error("INVAL");
                        return EJSONError.INVAL;
                    }

                    token.end = parser.pos + 1;
                    parser.toksuper = token.parent;
                    break;
                }

                if ( token.parent == -1 ) {
                    if ( token.type != type || parser.toksuper == -1 ) {
                        log.error("INVAL");
                        return EJSONError.INVAL;
                    }
                    break;
                }

                token = &tokens.ptr[token.parent];
            }
            break;

        case '\"':
            r = json_parseString( parser, str, tokens );
            if ( r < 0 ) return r;

            count++;
            if ( parser.toksuper != -1 && tokens.length ) {
                tokens[parser.toksuper].size++;
            }
            break;

        case '\t':
        case '\r':
        case '\n':
        case ' ':
            break;

        case ':':
            parser.toksuper = parser.toknext - 1;
            break;

        case ',':
            if (
                tokens.length && parser.toksuper != -1 &&
                tokens[parser.toksuper].type != EJSONType.ARRAY &&
                tokens[parser.toksuper].type != EJSONType.OBJECT
            ) {
                parser.toksuper = tokens[parser.toksuper].parent;
            }
            break;

        default:
            r = json_parsePrimitive( parser, str, tokens );
            if ( r < 0 ) {
                return r;
            }

            count++;
            if ( parser.toksuper != -1 && tokens.length ) {
                tokens[parser.toksuper].size++;
            }
            break;
        }
    }

    if ( tokens.length ) {
        for ( i = parser.toknext - 1; i >= 0; i-- ) {
            if ( tokens[i].start != -1 && tokens[i].end == -1 ) {
                return EJSONError.PART;
            }
        }
    }
    
    return count;
}

int json_getTotalSize( SJSONToken* token ) {
    uint i;
    uint j;
    SJSONToken* key;
    int result = 0;

    if ( token.type == EJSONType.PRIMITIVE ) {
        result = 1;
    } else if ( token.type == EJSONType.STRING ) {
        result = 1;
    } else if ( token.type == EJSONType.OBJECT ) {
        j = 0;
        for ( i = 0; i < token.size; i++ ) {
            key = token + 1 + j;
            j += json_getTotalSize( key );
            if ( key.size > 0 ) {
                j += json_getTotalSize( token + 1 + j );
            }
        }

        result = j + 1;
    } else if ( token.type == EJSONType.ARRAY ) {
        j = 0;
        for ( i = 0; i < token.size; i++ ) {
            j  += json_getTotalSize( token + 1 + j );
        }

        result = j + 1;
    }

    return result;
}

SJSONToken* json_getTokenByKey( String source, SJSONToken* token, String key ) {
    uint i = 0;
    int res = -1;
    size_t keylen = key.length;
    size_t totalSize;

    if ( token.type != EJSONType.OBJECT ) return null;

    totalSize = json_getTotalSize( token );

    for ( i = 1; i < totalSize; i++ ) {
        int j;
        int len = token[i].end - token[i].start;
        int match = 1;

        if ( len == keylen ) {
            for ( j = 0; j < len; ++j ) {
                if ( source[token[i].start + j] != key[j] ) {
                    match = 0;
                    break;
                }
            }
        } else {
            match = 0;
        }

        if ( match ) {
            res = i;
            break;
        }

        i += json_getTotalSize( &token[i + 1] );
    }

    return res == -1 ? null : &token[res];
}

SJSONToken* json_getTokenByIndex( SJSONToken* token, uint index ) {
    int i;
    int res = -1;
    int totalSize;

    if ( token.type != EJSONType.ARRAY ) return null;

    totalSize = json_getTotalSize( token );
    for ( i = 1; i< totalSize; i++ ) {
        if ( index == 0 ) return &token[i];

        i += json_getTotalSize( &token[i] ) - 1;
        --index;
    }

    return null;
}


