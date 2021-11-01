module engine.core.string.wrapper;

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
    alias DefaultParams = ParameterDefaults!M1;
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

        static if ( !is( DefaultParams[i] == void ) ) {
            result ~= " = " ~ to!string( DefaultParams[i] );
        }

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

string TWrapStringMethods( T, S = String, R = string )()
if ( is( T == class ) ) {
    string res;

    foreach ( m; __traits( allMembers, T ) ) {
        alias member = __traits( getMember, T, m );

        alias P = BaseClassesTuple!T[0];
        // TODO: fix this HACK with "as" name
        static if ( !__traits( hasMember, P, m ) && m != "as" ) {
            static if ( isFunction!member && ( functionAttributes!member & FunctionAttribute.property ) == 0 ) {
                alias ret = ReturnType!member;
                alias params = Parameters!member;

                static if ( params.length > 0 ) {
                    enum mustProcess = hasAsParam!( S, params );

                    static if ( mustProcess ) {
                        // 1 - return type
                        // 2 - name of original func
                        // 3 - params in formated form
                        // 4 - params with NString( var ) form

                        static if ( is( ret == void ) ) {
                            enum fstring = q{ %1$s %2$s( %3$s ) { %2$s( %4$s ); } };
                        } else {
                            enum fstring = q{ %1$s %2$s( %3$s ) { return %2$s( %4$s ); } };
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
            else static if ( __traits( compiles, { alias val = member!S; } ) ) {
                alias retS = ReturnType!( member!S );
                alias retR = ReturnType!( member!R );

                static if ( is( ret == void ) ) {
                    enum fstring = q{ %1$s %2$s( T )( %3$s ) { %2$s!T( %4$s ); } };
                } else {
                    enum fstring = q{ %1$s %2$s( T )( %3$s ) { return %2$s!T( %4$s ); } };
                }

                static if ( is( retS == retR ) ) {
                    string ret = retS.stringof;
                } else {
                    string ret = "T";
                }

                res ~= format(
                    fstring,
                    ret,
                    m,
                    createDefaultFormT!( member!S, member!R, S, R )(),
                    createdWrappedFormT!( member!S, member!R, S )
                );
            }
        }
    }

    return res;
}
