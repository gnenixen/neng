module engine.core.string.impl;

import std.traits;

import engine.core.memory;
import engine.core.ref_count;
import engine.core.typedefs;
import engine.core.containers : CopyOnWrite, Array;
import engine.core.utils.ustruct;
import engine.core.string.wrapper_struct;

alias Char = dchar;
alias CChar = char;
alias WChar = wchar;

alias String = SString!Char;
alias CString = SString!CChar;
alias WString = SString!WChar;

template TIsStringsProcessAvaible( This, T, R ) {
    enum TIsStringsProcessAvaible =
        is( T == Unqual!( This ) ) ||
        is( R == immutable( T )[] ) ||
        is( R == const immutable( T )[] )||
        is( Unqual!( This ) == R );
}

/**
    Custom string implementation with ref-count
    based memory managment.
*/
struct SString( T ) {
    mixin( TRefCountable!( "Array!T" ) );
    mixin( TWrapStructStringMethods!( SString!T, typeof( this ) ) );
public:
    alias TString = SString!T;
    alias toString this;

public:
    this( Args... )( Args args ) {
        foreach ( arg; args ) {
            lappend( arg );
        }
    }

    this( const( T )* cstr ) {
        if ( !cstr ) {
            resize( 0 );
            return;
        }

        const( T )* str = cstr;
        for ( ; *str; str++ ) {}
        
        size_t len = cast( size_t )( str - cstr );

        if ( len == 0 ) {
            resize( 0 );
            return;
        }

        resize( len );

        Memory.memcpy( cast( void* )data.ptr(), cast( void* )cstr, len * T.sizeof );
    }

    this( RawData rdata ) {
        // Null terminate string
        rdata ~= 0;

        this( cast( const( char )* )rdata.ptr );
    }

    size_t length() {
        size_t ret = data.length;

        // Minus "\0" symbol
        if ( ret > 0 ) {
            ret -= 1;
        }

        return ret;
    }
    
    const( T )* cstr() {
        if ( length == 0 ) return null;
        return data.ptr;
    }

    void resize( size_t nsize ) {
        if ( nsize == 0 ) {
            data.resize( 0 );
            return;
        }

        removeTerminator();
            data.resize( nsize + 1 );
        addTerminator();
    }

    static T toT( U )( U ch ) {
        import std.utf : byUTF;

        static if ( is( T == Unqual!U ) ) {
            return ch;
        } else {
            return byUTF!T( [cast( Unqual!U )ch] ).front();
        }
    }

    size_t find( TString str, size_t from ) {
        if ( from < 0 ) return -1;

        size_t stlen = str.length;
        size_t len = length;

        if ( stlen == 0 || len == 0 ) return -1;

        for ( size_t i = from; i <= (len - stlen); i++ ) {
            bool bFound = true;

            for ( size_t j = 0; j < stlen; j++ ) {
                size_t rpos = i + j;

                if ( rpos >= len ) {
                    return -1;
                }

                if ( this[rpos] != str[j] ) {
                    bFound = false;
                    break;
                }
            }

            if ( bFound ) {
                return i;
            }
        }

        return -1;
    }

    size_t rfind( TString str, size_t from = -1 ) {
        size_t limit = length - str.length;
        if ( limit < 0 ) return -1;

        if ( from < 0 ) {
            from = limit;
        } else if ( from > limit ) {
            from = limit;
        }

        size_t srcl = str.length;
        size_t len = length;

        if ( srcl == 0 || len == 0 ) return -1;

        for ( size_t i = from; i >= 0; i-- ) {
            bool bFound = true;
            for ( size_t j = 0; j < srcl; j++ ) {
                size_t rpos = i + j;

                if ( rpos >= len ) {
                    return -1;
                }

                if ( this[rpos] != str[j] ) {
                    bFound = false;
                    break;
                }
            }
            
            if ( bFound ) {
                return i;
            }
        }

        return -1;
    }

    TString substr( size_t from, size_t chars ) {
        if ( chars == -1 ) {
            chars = length - from;
        }

        if ( length == 0 || from < 0 || from > length || chars <= 0 ) {
            return TString();
        }

        if ( (from + chars) >= length ) {
            chars = length - from;
        }

        if ( from == 0 && chars >= length ) {
            return this;
        }

        return this[from..(from + chars)];
    }

    TString replace( TString key, TString by ) {
        TString res;
        size_t searchFrom = 0;
        size_t result = 0;

        while ( (result = find( key, searchFrom )) != -1 ) {
            res ~= substr( searchFrom, result - searchFrom );
            res ~= by;

            size_t k = 0;
            while ( key[k] != '\0' ) {
                k++;
            }
            
            searchFrom = result + k;
        }

        if ( searchFrom == 0 ) return this;

        res ~= substr( searchFrom, length - searchFrom );

        return res;
    }

    Array!TString split( TString splitter, bool bAllowEmpty = true, int maxsplit = 0 ) {
        Array!TString ret;
        size_t from = 0;

        while ( true ) {
            size_t end = find( splitter, from );
            if ( end == -1 ) {
                end = length;
            }

            if ( bAllowEmpty || (end > from) ) {
                if ( maxsplit <= 0 ) {
                    ret ~= substr( from, (end - from) );
                } else {
                    if ( maxsplit == ret.length ) {
                        ret ~= substr( from, length );
                        break;
                    }

                    ret ~= substr( from, (end - from) );
                }
            }

            if ( end == length ) {
                break;
            }

            from = end + splitter.length;
        }

        return ret;
    }

    bool isEndsWith( TString str ) {
        size_t l = str.length();
        if ( l > length ) return false;
        if ( l == 0 ) return true;

        size_t offset = length - l;

        foreach ( i; 0..l ) {
            if ( opIndex( offset + i ) != str[i] ) {
                return false;
            }
        }

        return true;
    }

    bool isBeginsWith( TString str ) {
        size_t l = str.length();
        if ( l > length ) return false;
        if ( l == 0 ) return true;

        foreach ( i; 0..l ) {
            if ( opIndex( i ) != str[i] ) {
                return false;
            }
        }

        return true;
    }

    TString dirname() {
        size_t pos = rfind( TString( "/" ), -1 );
        if ( pos == -1 ) return TString( "" );

        return substr( 0, pos );
    }

    TString filename() {
        size_t pos = rfind( TString( "/" ), -1 );
        size_t dotpos = rfind( TString( "." ), -1 );
        if ( pos == -1 || dotpos < pos ) return this;

        return this[pos + 1..dotpos];
    }

    TString extension() {
        size_t pos = rfind( TString( "." ), -1 );
        if ( pos == -1 ) return TString();

        return substr( pos + 1, length );
    }

    const( T )* ptr() => data.ptr();

private:
    T* ptrw() => data.ptr();

    /**
        Remove C '\0' terminator at
        the end of string
    */
    void removeTerminator() {
        if ( data.length == 0 ) return;
        if ( data.ptr[length] != toT( '\0' ) ) return;

        ptrw[length] = toT( ' ' );
    }

    /**
        Add C '\0' terminator at
        the end of string
    */
    void addTerminator() {
        ptrw[length] = '\0';
    }

    /**
        String append based on U type.
        Etends static if/else structure
        for every type
    */
    void lappend( U )( U adata ) {
        long _length( C )( C* ch ) {
            C* temp;

            temp = ch;
            while ( *temp ) {
                temp++;
            }

            return temp - ch;
        }

        template TSingleChar( T ) {
            import std.string : format;

            enum TSingleChar = format( q{
                else static if ( is( U == Unqual!%1$s ) ) {
                    app ~= toT( adata );
                }
                }, 
                T.stringof 
            );
        }

        template TCLikeString( T ) {
            import std.string : format;

            enum TCLikeString = format( q{
                else static if ( is( U == const(%1$s)* ) || is( U == %1$s* ) ) {
                    if ( !adata ) return;

                    long llength = _length( adata );
                    assert( llength != -1 );

                    app.reserve( llength );
                    
                    foreach ( i; 0..llength ) {
                        app ~= toT( adata[i] );
                    }
                }
                else static if ( __traits( compiles, {%1$s* d = adata.ptr;} ) ) {
                    if ( !adata.ptr ) return;

                    long llength = _length( adata.ptr );

                    app.reserve( llength );
                    
                    foreach ( i; 0..llength ) {
                        app ~= toT( adata[i] );
                    }
                }
                }, 
                T.stringof
            );
        }

        template TXString( T ) {
            import std.string : format;

            enum TXString = format( q{
                else static if ( is( U == %1$s ) ) {
                    app.reserve( adata.length );

                    foreach ( i; 0..adata.length ) {
                        app ~= toT( adata[i] );
                    }
                }
                },
                T.stringof
            );
        }

        template TXStringCast( T ) {
            import std.string : format;

            enum TXStringCast = format( q{
                else static if ( __traits( compiles, {%1$s str = cast( %1$s )adata.toString();} ) ) {
                    app.reserve( adata.length );

                    foreach ( i; 0..adata.length ) {
                        app ~= toT( adata[i] );
                    }
                }
                },
                T.stringof
            );
        }

        Array!T app;

        static if ( is( U == bool ) ) {
            lappend( adata ? "true" : "false" );
        }
        else static if ( is( U : Object ) ) {
            if ( adata !is null ) {
                lappend( adata.toString() );
            } else {
                lappend( "null" );
            }
        }
        else static if ( is( __traits( compiles, { adata.toString(); } ) ) ) {
            lappend( adata.toString() );
        }
        else static if ( is( __traits( compiles, { adata._toString(); } ) ) ) {
            lappend( adata._toString() );
        }
        else static if ( isIntegral!U ) {
            U bSign;
            if ( (bSign = adata) < 0 ) {
                adata = -adata;
            }

            U n = adata;
            size_t chars = 0;

            do {
                n /= 10;
                chars++;
            } while( n );

            if ( bSign < 0 ) {
                chars++;
            }

            T[] nstr = allocate!( T[] )( chars );

            while ( chars ) {
                nstr[--chars] = adata % 10 + '0';
                adata /= 10;
            }

            if ( bSign < 0 ) {
                nstr[0] = '-';
            }

            app.reserve( nstr.length );
            foreach ( i; nstr ) {
                app ~= toT( i );
            }

            deallocate( nstr );
        }
        else static if ( is( U == float ) || is( U == double ) || is( U == real ) ) {
            // TODO: Write GC-less converter
            import std.conv : to;
            if ( adata == -0.0 ) {
                adata = 0.0;
            }

            lappend( to!string( adata ) );
        }
        else static if ( is( U == void* ) ) {
            if ( adata is null ) {
                lappend( "null" );
                return;
            }

            static string array = "0123456789ABCDEF";
            T* ptr;
            T[50] buffer;
            size_t n = cast( size_t )adata;
            size_t len = 1;

            ptr = &buffer[49];
            *ptr = '\0';

            do {
                *--ptr = array[n % 16];
                n /= 16;
                len++;
            } while ( n != 0 );

            *--ptr = 'x';
            *--ptr = '0';
            len += 2;

            app.reserve( len );
            foreach ( i; 0..len ) {
                app ~= ptr[i];
            }
        }
        else static if ( is( U == typeof( this ) ) ) {
            if ( adata.length == 0 ) return;

            app.reserve( adata.length );
            foreach ( i; 0..adata.length ) {
                app ~= adata[i];
            }
        }
        else {
            mixin(
                "static if ( false ) {}",
                    TSingleChar!char,
                    TSingleChar!wchar,
                    TSingleChar!dchar,

                    TCLikeString!char,
                    TCLikeString!wchar,
                    TCLikeString!dchar,

                    TXString!string,
                    TXString!wstring,
                    TXString!dstring,

                    TXStringCast!string,
                    TXStringCast!wstring,
                    TXStringCast!dstring
            );
        }

        if ( app.length != 0 ) {
            if ( app[0] == '\0' ) return;
            size_t startLength = length;
            resize( startLength + app.length );
            Memory.memcpy( cast( void* )( data.ptr + startLength ), cast( void* )app.ptr, app.length * T.sizeof );
            addTerminator();
        }
    }

public:
    bool opEquals( U )( U other ) {
        if ( length != other.length ) return false;

        foreach ( i; 0..length ) {
            if ( this[i] != toT( other[i] ) ) {
                return false;
            }
        }

        return true;
    }

    TString opSlice( size_t start, size_t end ) {
        TString ret;
        ret.resize( end - start );
        Memory.memcpy( cast( void* )ret.data.ptr, cast( void* )data.ptr + start * T.sizeof, (end - start) * T.sizeof );

        return ret;
    }

    T opIndex( size_t idx ) {
        return data.ptr[idx];
    }

    auto opIndexAssign( U )( U value, size_t idx ) {
        ptrw[idx] = toT( value );
        return value;
    }

    auto opAssign( U )( U value ) {
        data.free();

        lappend( value );
    }

    auto opOpAssign( string op, U )( U value )
    if ( op == "~" ) {
        lappend( value );
    }

    auto opBinary( string op, U )( const U rhs ) const
    if (
        TIsStringsProcessAvaible!( typeof( this ), T, U ) &&
        op == "~"
    ) {
        typeof( this ) ret = this;

        ret.resize( length + rhs.length );

        foreach ( i; 0..rhs.length ) {
            ret[length + i] = rhs[i];
        }

        return ret;
    }

    SString!U opCast( U )() {
        static if ( is( T == U ) ) {
            return this;
        } else {
            SString!U ret;
            ret.resize( length );

            foreach ( i; 0..length ) {
                ret.ptrw[i] = ret.toT( this[i] );
            }

            return ret;
        }
    }

    size_t opDollar() => length();

    SString!char toNativeString() {
        SString!char ret;
        ret.resize( length );

        foreach ( i; 0..length ) {
            ret.ptrw[i] = ret.toT( this[i] );
        }

        return ret;
    }

    immutable( T )[] toString() {
        return ltoString();
    }

    immutable( T )[] ltoString() {
        if ( length == 0 ) return "";

        return cast( immutable( T )[] )( data.ptr[0..length] );
    }

    CString c_str() => CString( ltoString() );

static:
    void _dataInitialize( Array!T* idata ) {
        idata.ldata = allocate!( Array!T.ArrayData )();
        Array!T._dataInitialize( idata.ldata );
    }

    void _dataDestruct( Array!T* idata ) {
        if ( idata.ldata ) {
            Array!T._dataDestruct( idata.ldata );
            deallocate( idata.ldata );
        }
    }
}

struct SEngineStringLiteral( dstring data ) {
    private __gshared String lstring;

    String str() const {
        static if ( data.length ) {
            if ( lstring == String.init ) {
                lstring = String( data );
            }
        }

        return lstring;
    }

    static if ( data.length ) {
        shared static ~this() {
            if ( lstring != String.init ) {
                lstring.resize( 0 );
            }
        }
    }

    alias str this;
}

enum rs( string str ) = SEngineStringLiteral!str.init;
