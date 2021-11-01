module engine.core.string.wrapper_struct;

public {
    import engine.core.string.impl;
}

private {
    import std.conv : to;
    import std.traits;
    import std.typecons;
    import std.string;
}

alias alHelper( alias T ) = T;
alias alHelper( T ) = T;

template hasAsParam( T, P... ) {
    template findT( int i ) {
        static if ( P.length == 0 ) {
            enum findT = -1;
        }
        else static if ( i >= P.length ) {
            enum findT = -1;
        }
        else {
            static if ( is( alHelper!( P[i] ) == T ) || is( typeof( P[i] ) == T ) ) {
                enum findT = i;
            } else {
                enum findT = findT!( i + 1 );
            }
        }
    }

    enum hasAsParam = findT!( 0 ) != -1;
}

string createDefaultFormT( alias M1, alias M2, T, R )() {
    //alias DefaultParams = ParameterDefaults!M1;
    alias P = Parameters!M1;
    alias S = Parameters!M2;
    
    enum len = P.length;

    string result;

    static foreach ( i; 0..len ) {
        static if ( !is( alHelper!( P[i] ) == alHelper!( S[i] ) ) ) {
            result ~= "T v" ~ to!string( i );
        } else static if ( is( alHelper!( P[i] ) == T ) ) {
            result ~= R.stringof ~ " v" ~ to!string( i );
        } else {
            result ~= alHelper!( P[i] ).stringof ~ " v" ~ to!string( i );
        }

        //static if ( !is( DefaultParams[i] == void ) ) {
            //result ~= " = " ~ to!string( DefaultParams[i] );
        //}

        static if ( i != len - 1 ) {
            result ~= ", ";
        }
    }

    return result;
}

string createdWrappedFormT( alias M1, alias M2, T )() {
    alias P = Parameters!M1;
    alias S = Parameters!M2;
    
    enum len = P.length;

    string result;

    static foreach ( i; 0..len ) {
        static if ( !is( alHelper!( P[i] ) == alHelper!( S[i] ) ) ) {
            result ~= " v" ~ to!string( i );
        } else static if ( is( alHelper!( P[i] ) == T ) ) {
            result ~=  T.stringof ~ "( v" ~ to!string( i ) ~ " )";
        } else {
            result ~= " v" ~ to!string( i );
        }

        static if ( i != len - 1 ) {
            result ~= ", ";
        }
    }

    return result;
}

string TWrapStructStringMethods( T, S = String, R = string )()
if ( is( T == struct ) ) {
    string res;

    foreach ( m; __traits( allMembers, T ) ) {
        if ( m == "opAssign" ) continue;
        if ( m == "__postblit" ) continue;
        if ( m == "__ctor" ) continue;

        alias member = __traits( getMember, T, m );

        static if ( isFunction!member && ( functionAttributes!member & FunctionAttribute.property ) == 0 ) {
            alias ret = ReturnType!member;
            alias params = Parameters!member;

            static if ( params.length > 0 ) {
                enum mustProcess = hasAsParam!( S, params );

                static if ( mustProcess ) {
                    static if ( is( ret == void ) ) {
                        enum fstring = "%1$s %2$s( %3$s ) { %2$s( %4$s ); }\n";
                    } else {
                        enum fstring = "%1$s %2$s( %3$s ) { return %2$s( %4$s ); }\n";
                    }

                    res ~= format(
                        fstring,
                        ret.stringof,
                        m,
                        createDefaultFormT!( member, member, S, R )(),
                        createdWrappedFormT!( member, member, S )
                    );
                }
            }
        }
    }

    return res;
}
