module engine.core._reflection;

import std.traits;
import std.meta;
import std.functional;

import engine.core.memory;
import engine.core.containers;
import engine.core.string;
import engine.core._variant;
import engine.core.log;

alias var = _SVariant;

class CReflectionRuntime {
protected:
    Array!CReflectionTypeDescriptor ldescriptors;

public:
    void register( CReflectionTypeDescriptor descriptor ) {
        assert( ldescriptors.find!"a.name == b.name"( descriptor ) == -1 );

        ldescriptors ~= descriptor;
    }

    CReflectionTypeDescriptor get( TypeInfo ti ) {
        size_t idx = ldescriptors.find!"a == b.typeinfo"( ti );
        if ( idx == -1 ) return null;

        return ldescriptors[idx];
    }
}

alias ReflectionInstantiator = Object function();

class CReflectionTypeDescriptor {
protected:
    String lname;
    size_t lsize;
    bool lbAbstract;

    CReflectionTypeDescriptor lparent;

    TypeInfo ltypeinfo;
    ReflectionInstantiator linstantiator;

    Array!CReflectionMethod lmethods;
    Array!CReflectionField lfields;

public:
    this(
        String iname,
        size_t isize,
        bool ibAbstract,
        CReflectionTypeDescriptor iparent,
        TypeInfo itypeinfo,
        ReflectionInstantiator iinstantiator,
        Array!CReflectionMethod imethods,
        Array!CReflectionField ifields
    ) {
        lname = iname;
        lsize = isize;
        lbAbstract = ibAbstract;
        lparent = iparent;
        ltypeinfo = itypeinfo;
        linstantiator = iinstantiator;
        lmethods = imethods;
        lfields = ifields;
    }

    Object instance() {
        assert( linstantiator );

        return linstantiator();
    }

    CReflectionMethod method( String name ) {
        int idx = lmethods.find!"a == b.name"( name );

        return idx != -1 ? lmethods[idx] : null;
    }

    CReflectionField field( String name ) {
        int idx = lfields.find!"a == b.name"( name );

        return idx != -1 ? lfields[idx] : null;
    }

    CReflectionMethod method( string name ) { return method( String( name ) ); }
    CReflectionField field( string name ) { return field( String( name ) ); }

public pragma( inline, true ):
    String name() { return lname; }
    size_t size() { return lsize; }
    bool isAbtract() { return lbAbstract; }
    CReflectionTypeDescriptor parent() { return lparent; }
    TypeInfo typeinfo() { return typeinfo; }
    Array!CReflectionMethod methods() { return lmethods; }
    Array!CReflectionField fields() { return lfields; }
}

struct SReflectionMethodInvokeParams {
    import engine.core.memory : alloc = allocate, dealloc = deallocate, Memory;
public:
    TypeInfo* argTypes;
    void** args;
    uint* flags;

private:
    size_t lsize;

public:
    void allocate( size_t size ) {
        assert( size > 0 );
        assert( lsize == 0 );
        assert( argTypes is null );
        assert( args is null );
        assert( flags is null );

        argTypes = cast( TypeInfo* )alloc( TypeInfo.sizeof * size );
        args = cast( void** )alloc( (void*).sizeof * size );
        flags = cast( uint* )alloc( uint.sizeof * size );

        lsize = size;
    }

    void free() {
        assert( lsize > 0 );

        dealloc( argTypes );
        dealloc( args );
        dealloc( flags );

        argTypes = null;
        args = null;
        flags = null;
        lsize = 0;
    }

    size_t size() { return lsize; }

    void setArg( T )( int idx, void* val, uint iflags = 0 ) {
        argTypes[idx] = typeid( T );
        args[idx] = val;
        flags[idx] = iflags;
    }

    void setArgT( T )( int idx, T val, uint iflags = 0 ) {
        T* arg = cast( T* )alloc( T.sizeof );
        Memory.markOneFrame( arg );
            
        *arg = val;
            
        argTypes[idx] = typeid( T );
        args[idx] = arg;
        flags[idx] = iflags;
    }

    void setArgEx( int idx, TypeInfo typeID, void* val, uint iflags = 0 ) {
        argTypes[idx] = typeID;
        args[idx] = val;
        flags[idx] = iflags;
    }
}

alias ReflectionMethodInvoker = var function( var target, ref SReflectionMethodInvokeParams params );

class CReflectionMethod {
protected:
    String lname;
    bool lbCallable;

    ReflectionMethodInvoker linvoker;

public:
    this(
        String iname,
        bool ibCallable,
        ReflectionMethodInvoker iinvoker
    ) {
        lname = iname;
        lbCallable = ibCallable;
        linvoker = iinvoker;
    }

    var invoke( T )( auto ref T target, ref SReflectionMethodInvokeParams params ) const {
        static if ( is( T == var ) ) {
            return linvoker( target, params );
        }
        else static if ( is( T == struct ) ) {
            var o = &target;
            return linvoker( o, params );
        }
        else static if (
            is( T == typeof( null ) ) ||
            is( T == class ) ||
            is( T == interface )
        ) {
            var o = target;
            return linvoker( o, params );
        }
        else {
            static assert( false, "invalid invocation target '" ~ T.stringof ~ "' - " ~
                          "target must be a class, interface, struct, struct*, null, " ~
                          "or a SVariant containing one of those types" );
        }
    }

    var invoke( T, Args... )( auto ref T target, auto ref Args args ) const {
        SReflectionMethodInvokeParams params;

        static if ( Args.length > 0 ) {
            params.allocate( Args.length );

            foreach ( i, argType; Args ) {
                static if ( is( argType == var ) ) {
                    params.setArgEx( i, args[i].type, args[i].ldata );
                } else {
                    params.setArg!argType( i, &args[i] );
                }
            }
        }

        var ret = invoke( target, params );
        
        if ( params.size > 0 ) {
            params.free();
        }
        
        return ret;
    }

public:
    String name() { return lname; }
}

enum EReflectionFieldOperation {
    GET,
    SET,
    ADDRESS
}

alias ReflectionFieldOperator = void function( var target, var* value, EReflectionFieldOperation operation );

class CReflectionField {
protected:
    String lname;
    size_t loffset;

    CReflectionTypeDescriptor ltype;
    ReflectionFieldOperator loperator;

public:
    this(
        String iname,
        size_t ioffset,
        CReflectionTypeDescriptor itype,
        ReflectionFieldOperator ioperator
    ) {
        lname = iname;
        loffset = ioffset;
        ltype = itype;
        loperator = ioperator;
    }

    var get( var target ) {
        var ro;
        loperator( target, &ro, EReflectionFieldOperation.GET );
        return ro;
    }

    void set( var target, var val ) {
        loperator( target, &val, EReflectionFieldOperation.SET );
    }

    void* ptr( var target ) {
        var ro;
        loperator( target, &ro, EReflectionFieldOperation.ADDRESS );
        return ro.as!( void* );
    }

public:
    String name() { return lname; }
    CReflectionTypeDescriptor type() { return ltype; }
}

class CReflectionBuilder {
protected:
    String tname;
    size_t tsize;
    TypeInfo ttypeinfo;

    ReflectionInstantiator instantiator;
    Array!CReflectionField fields;
    Array!CReflectionMethod methods;

public:
    auto type( T )() {
        static if ( is( T == class ) ) {
            static Object linstantiator() {
                import engine.core.memory : allocate;
                enum bCanInstance = __traits( compiles, { auto _ = allocate!T; } );

                static if ( bCanInstance ) {
                    return allocate!T();
                } else {
                    return null;
                }
            }

            instantiator = &linstantiator;
        }

        tname = String( T.stringof );
        tsize = T.sizeof;
        ttypeinfo = typeid( T );

        return this;
    }

    auto field( alias T )()
    if ( isField!T ) {
        alias P = Alias!( __traits( parent, T ) );
        alias FT = typeof( T );

        static if ( __traits( compiles, { enum _ = T.offsetof; } ) ) {
            enum offset = T.offsetof;
            enum bIsStatic = false;
        } else {
            enum offset = 0;
            enum bIsStatic = true;
        }

        ReflectionFieldOperator operator = ( var target, var* val, EReflectionFieldOperation operation ) {
            final switch ( operation ) {
            case EReflectionFieldOperation.SET:
                static if ( isSetSupported!FT ) {
                    static if ( bIsStatic ) {
                        T = cast( FT )( *val );
                    } else {
                        static if ( is( P == class ) || is( P == interface ) ) {
                            P tar = cast( P )target;
                        }
                        else static if ( is( P == struct ) ) {
                            bool bIsPtr = (target.typeinfo == typeid( P* ));
                            P* tar = bIsPtr ? cast( P* )target : cast( P* )target.ptr;
                        }
                        else {
                            static assert( false, "Target instance must by a class, interface, or struct*" );
                        }

                        *cast( FT* )( cast( void* )tar + offset ) = cast( FT )*val;
                    }
                } else {
                    log.error( "SET operation not supported for this field type" );
                }
                break;

            case EReflectionFieldOperation.GET:
                static if ( isGetSupported!FT ) {
                    static if ( bIsStatic ) {
                        *val = T;
                    } else {
                        static if ( is( P == class ) || is( P == interface ) ) {
                            P tar = cast( P )target;
                        }
                        else static if ( is( P == struct ) ) {
                            bool bIsPtr = (target.typeinfo == typeid( P* ));
                            P* tar = bIsPtr ? cast( P* )target : cast( P* )target.ptr;
                        }
                        else {
                            static assert( false, "Target instance must by a class, interface, or struct*" );
                        }

                        *val = *cast( FT* )( cast( void* )tar + offset );
                    }
                } else {
                    log.error( "SET operation not supported for this field type" );
                }
                break;

            case EReflectionFieldOperation.ADDRESS:
                static if ( bIsStatic ) {
                    *val = cast( void* )( &T );
                } else {
                    static if ( is( P == class ) || is( P == interface ) ) {
                        P tar = cast( P )target;
                    }
                    else static if ( is( P == struct ) ) {
                        bool bIsPtr = (target.typeinfo == typeid( P* ));
                        P* tar = bIsPtr ? cast( P* )target : cast( P* )target.ptr;
                    }
                    else {
                        static assert( false, "Target instance must by a class, interface, or struct*" );
                    }

                    *val = cast( void* )tar + offset;
                }
                break;
            }
        };

        CReflectionTypeDescriptor typeinfo;

        static if ( __traits( compiles, { T.reflect( null ); } ) ) {
            CReflectionBuilder builder = allocate!CReflectionBuilder();
                T.reflect( builder );
                typeinfo = builder.build();
            deallocate( builder );
        } else {
            typeinfo = allocate!CReflectionTypeDescriptor(
                String( T.stringof ),
                T.sizeof,
                false,
                null,
                typeid( T ),
                null,
                Array!CReflectionMethod(),
                Array!CReflectionField()
            );
        }

        fields ~= allocate!CReflectionField(
                String( __traits( identifier, T ) ),
                offset,
                typeinfo,
                operator
            );

        return this;
    }

    auto method( alias T )()
    if ( isSomeFunction!T ) {
        alias P = Alias!( __traits( parent, T ) );

        static if ( isFinalFunction!P ) {
            enum bIsCallable = true;
        } else static if ( isAbstractClass!P || isAbstractFunction!P ) {
            enum bIsCallable = false;
        } else {
            enum bIsCallable = true;
        }

        static var invoker( var target, ref SReflectionMethodInvokeParams params ) {
            alias RT = ReturnType!T;

            static if( !isFinalFunction!T && isAbstractClass!P ) {
                assert( false, "Cannot call methjods of abstract class" );
            }
            else static if ( isAbstractFunction!T ) {
                assert( false, "Cannot call abstract methods" );
            }
            else {
                static if ( isAggregateType!P ) {
                    static if ( is( P == class ) || is( P == interface ) ) {
                        P tar = null;
                        if ( !target.isEmpty() ) {
                            tar = cast( P )target;
                        }
                    }
                    else static if ( is( P == struct ) ) {
                        bool bIsPtr = false;
                        P* tar = null;

                        if ( !target.isEmpty() ) {
                            bIsPtr = (target.typeinfo == typeid( P* ));
                            tar = bIsPtr ? cast( P* )target : cast( P* )target.ptr;
                        }
                    }
                    else {
                        static assert( false, "Instance type must be a class, interface, or struct*" );
                    }

                    static if ( __traits( isStaticFunction, T ) ) {
                        assert( tar is null, "Instance pointer should be null for static function" );
                    } else {
                        assert( tar !is null, "Instance pointer cannot be null for regular function" );
                    }
                }
            }

            alias ParamType = Parameters!T;
            alias ArgType = UnqualTuple!ParamType;
            alias DefaultParams = ParameterDefaults!T;

            static var[DefaultParams.length] defaultArgs;
            static foreach ( i, arg; DefaultParams ) {
                static if ( is( arg == void ) ) {
                    defaultArgs[i] = var( null );
                } else {
                    defaultArgs[i] = var( arg );
                }
            }

            if ( params.size != ParamType.length ) {
                log.error( "Wrong number of arguments, ", ParamType.length, " expected, when ", params.size, " received" );
                return var();
            }

            // Check is params types equals to what we receive
            foreach ( i, ptype; ParamType ) {
                import engine.core.utils.typeinfo : isBaseClassTypeInfoFor;

                TypeInfo rt = params.argTypes[i];
                TypeInfo lt = typeid( ptype );

                // Skip default params
                if ( rt is null ) continue;

                // Skip string, variant
                if (
                    rt.toString() == "char[]" ||
                    ptype.stringof == "string" || 
                    ptype.stringof == "SVariant"
                ) continue;

                // Checл if it is class inheritance
                if ( isBaseClassTypeInfoFor( rt, lt ) ) continue;

                if ( rt !is lt ) {
                    log.error( "Wrong argument type - expected '", ptype.stringof, "', received '", rt.toString(), "'" );
                    return var();
                }
            }

            ArgType args;
            foreach ( i, atype; ArgType ) {
                if ( params.argTypes[i] is null ) {
                    static if ( is( atype == bool ) ) {
                        args[i] = cast( bool )cast( int )defaultArgs[i];
                    } else {
                        atype val = cast( atype )defaultArgs[i];
                        args[i] = val;
                    }

                    continue;
                }

                static if ( is( atype == String ) ) {
                    if ( params.flags[i] == 1 ) {
                        args[i] = String( cast( char* )params.args[i] );
                    } else {
                        args[i] = *cast( atype* )params.args[i];
                    }
                }
                else static if ( is( atype : Object ) ) {
                    if ( params.flags[i] == 2 ) {
                        args[i] = cast( atype )params.args[i];
                    } else {
                        args[i] = *cast( atype* )params.args[i];
                    }
                }
                else {
                    static if ( is( atype == var ) ) {
                        import engine.core.ref_count;

                        var v;
                        v.ldate = cast( SVariantRefDataHandler* )params.args[i];

                        RC.incRef( v.ldata );

                        args[i] = v;
                    } else {
                        args[i] = *cast( atype* )params.args[i];
                    }
                }
            }

            alias MethodTypeOf!T MethodType;
            MethodType fun;

            static if ( isDelegate!MethodType ) {
                fun.funcptr = cast( typeof( fun.funcptr ) )&T;
                fun.ptr = cast( void* )tar;
            } else {
                fun = &T;
            }

            var ret;

            static if ( __traits( compiles, var( fun( args ) ) ) ) {
                ret = var( fun( args ) );
            } else {
                fun( args );
                ret = var();
            }

            static foreach ( i, S; ArgType ) {
                import std.traits : hasElaborateDestructor;

                static if ( hasElaborateDestructor!S ) {
                    typeid( S ).destroy( cast( void* )&args[i] );
                }
            }

            return ret;
        }

        methods ~= allocate!CReflectionMethod(
                String( __traits( identifier, T ) ),
                bIsCallable,
                &invoker
            );

        return this;
    }

    CReflectionTypeDescriptor build() {
        return allocate!CReflectionTypeDescriptor(
            String(),
            tsize,
            false,
            null,
            ttypeinfo,
            instantiator,
            methods,
            fields
        );
    }
}

struct STestArrayLike( T ) {
    T val;

    void f( T hi ) { log.warning( "HI" ); }

    void reflect( CReflectionBuilder builder ) {
        builder
            .type!( typeof( this ) )
            .field!val
            .method!f;
    }
}

class CTest {
    int v;
    Array!int a;
    STestArrayLike!int ar;

    void reflect( CReflectionBuilder builder ) {
        a ~= 10;
        a ~= 10;

        builder
            .type!CTest
            .field!v
            .field!a
            .field!ar
            .method!test;
    }

    void test() {
        log.warning("HALLO");
    }
}

template isField( alias T ) {
    enum hasInit = is( typeof( typeof(T).init ) );

    enum isManifestConst = __traits( compiles, { enum e = T; } );
    
    enum isField = hasInit && !isManifestConst;
}

template MethodTypeOf( alias M ) {
    static if( __traits( isStaticFunction, M ) ) {
        alias MethodTypeOf = typeof( toDelegate( &M ).funcptr );
    } else {
        alias MethodTypeOf = typeof( toDelegate( &M ) );
    }
}

private template UnqualTuple( Args... ) {
    static if ( Args.length > 1 ) {
        alias UnqualTuple = AliasSeq!( Unqual!(Args[0]), UnqualTuple!(Args[1..$]) );
    
    } else static if ( Args.length > 0 ) {
        alias UnqualTuple = AliasSeq!( Unqual!(Args[0]) );
    
    } else {
        alias UnqualTuple = AliasSeq!();
    
    }
}

template isGetSupported( T ) {
    enum isGetSupported = __traits( compiles, { var( T.init ); } );
}

template isSetSupported( T ) {
	import std.traits : isNumeric, isBoolean, isSomeString;
	enum isSetSupported = isNumeric!T || isBoolean!T || is( T : Object ) || isSomeString!T;
}
