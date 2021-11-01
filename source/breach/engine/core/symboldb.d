module engine.core.symboldb;

public:
import engine.core.object;
import engine.core.signal;
import engine.core.containers.array;

class CRegSymbol {
public:
    String name;
    Array!String pseudonames;
}
    
class CRegClass : CRegSymbol {
public:
    String type;
    size_t instsize;
    TypeInfo_Class itype;
    CRSClass reflection;
    CClassDescription description;
}

class CRegStruct : CRegSymbol {
public:
    TypeInfo_Struct itype;
    CRSStruct reflection;
    var initInstance;
}

class CRegEnum : CRegSymbol {
public:
    TypeInfo_Enum itype;
    CRSEnum reflection;
}

class CSymbolDB : CObject {
    mixin( TRegisterClass!( CSymbolDB, Singleton ) );
@NoReflection:
public:
    alias Symbol = CRegSymbol;
    alias Class = CRegClass;
    alias Struct = CRegStruct;
    alias Enum = CRegEnum;

public:
    SSignal!( Symbol ) newSymbolRegistered;
    
    Array!Symbol rsymbols;
    Array!Class rclasses;
    Array!Struct rstructs;
    Array!Enum renums;

public:
    ~this() {
        newSymbolRegistered.disconnectAll();

        rclasses.free(
            ( rc ) { deallocate( rc.description ); }
        );
    }

    /**
        Register type
        Params:
            rname - pseude name for type
    */
    auto register( T )( String rname ) {
        CRegSymbol rsymbol;

        static if ( is( T : CObject ) ) {
            checkDoubleRegister!T( rclasses );

            rClass lreflection = reflect!T;
            T.initializeClass( lreflection );

            Class rclass = allocate!Class();
            with ( rclass ) {
                name = rname == "" ? String( lreflection.name ) : rname;
                type = T.objectType;
                instsize = __traits( classInstanceSize, T );
                itype = T.classinfo;
                reflection = cast()lreflection;
                description = T.stClassDescription();
            }

            rclass.pseudonames ~= rclass.name;
            rclass.pseudonames ~= String( rclass.itype.name );

            rsymbol = rclass;
            rclasses ~= rclass;

            // Initialze singleton automatically
            if ( T.objectType == rs!"singleton" ) {
                static if ( __traits( compiles, { NewObject!T(); } ) ) {
                    NewObject!T();
                }
            }
        }
        else static if ( is( T == struct ) ) {
            checkDoubleRegister!T( rstructs );
            
            var linitInstance = var();
            static if ( __traits( compiles, var( T() ) ) ) {
                linitInstance = var( T() );
            }

            CRSStruct lreflection = cast()reflect!T;

            Struct rstruct = allocate!Struct();
            with ( rstruct ) {
                name = rname == "" ? String( typeid( T ).name ) : rname;
                itype = typeid( T );
                reflection = lreflection;
                initInstance = linitInstance;
            }

            rstruct.pseudonames ~= rstruct.name;
            rstruct.pseudonames ~= String( lreflection.toString() );
            rstruct.pseudonames ~= String( rstruct.itype.name );

            rsymbol = rstruct;
            rstructs ~= rstruct;
        }
        else static if ( is( T == enum ) ) {
            checkDoubleRegister!T( renums );

            Enum renum = allocate!Enum();
            with ( renum ) {
                name = rname == "" ? String( typeid( T ).name ) : rname;
                itype = typeid( T );
                reflection = cast()reflect!T;
            }

            renum.pseudonames ~= renum.name;
            renum.pseudonames ~= String( renum.itype.name );

            rsymbol = renum;
            renums ~= renum;
        }
        else {
            static assert( false, "Trying to register invalid symbol: " ~ T.stringof );
        }

        rsymbols ~= rsymbol;
        newSymbolRegistered.emit( rsymbol );

        return cast()reflect!T;
    }

    Class getClassInfo( String name ) {
        foreach ( cl; rclasses ) {
            if ( cl.pseudonames.has( name ) ) {
                return cl;
            }
        }

        return null;
    }

    Struct getStructInfo( String name ) {
        foreach ( st; rstructs ) {
            if ( st.pseudonames.has( name ) ) {
                return st;
            }
        }

        return null;
    }

    Enum getEnumInfo( String name ) {
        foreach ( en; renums ) {
            if ( en.pseudonames.has( name ) ) {
                return en;
            }
        }

        return null;
    }

    Class getClassInfo( rClass rclass ) {
        foreach ( cl; rclasses ) {
            if ( cl.reflection is cast()rclass ) {
                return cl;
            }
        }

        return null;
    }

    Struct getStructInfo( rStruct rstruct ) {
        foreach ( st; rstructs ) {
            if ( st.reflection is cast()rstruct ) {
                return st;
            }
        }

        return null;
    }

    Enum getEnumInfo( rEnum renum ) {
        foreach ( en; renums ) {
            if ( en.reflection is cast()renum ) {
                return en;
            }
        }

        return null;
    }

    auto register( T )( string rname ) { return register!T( String( rname ) ); }
    auto register( T )() { return register!T( String( "" ) ); }

private:
    void checkDoubleRegister( T, U )( Array!U regarea ) {
        assert(
            regarea.find!"a == b.itype"( typeid( T ) ),
            "Trying to register alredy registered symbol: " ~ T.stringof
        );
    }
}

pragma( inline, true ) static __gshared {
    CSymbolDB GSymbolDB() {
        return CSymbolDB.sig;
    }
}
