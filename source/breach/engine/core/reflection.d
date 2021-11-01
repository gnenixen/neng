/**
    Basic reflection for Object
*/
module engine.core.reflection;

import core.vararg;
import std.variant;
import std.conv;
import std.format;
import std.functional;
import std.meta;
import std.stdio;
import std.string;
import std.traits;
import std.typecons;
import std.uni;
import std.meta;

import engine.core.memory;
public import engine.core.variant;

enum ESymbolType {
    UNSUPPORTED,
    MODULE,
    INTERFACE,
    CLASS,
    STRUCT,
    UNION,
    ENUM,
    CONSTANT,
    SCALAR,
    FIELD,
    METHOD,
    PROPERTY,
}

enum ESymbolProtection {
    PUBLIC,
    PRIVATE,
    PROTECTED,
    PACKAGE,
    EXPORT,
}

struct NoReflection {}

abstract class AReflectSymbol {
    string name() const;
    ESymbolType type() const;
    TypeInfo typeId() const;
    override string toString() const;
}

final class CRSUnsupported : AReflectSymbol {
private:
    string lname;
    TypeInfo ltype;

public:
    this( string iname, TypeInfo itype ) {
        lname = iname;
        ltype = itype;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.UNSUPPORTED;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return lname;
    }
}

abstract class CRSScope : AReflectSymbol {
protected:
    const( CRSInterface )[] linterfaces;
    const( CRSClass )[] lclasses;
    const( CRSStruct )[] lstructs;
    const( CRSEnum )[] lenums;
    const( CRSProperty )[] lproperties;
    const( CRSField )[] lfields;
    const( CRSMethod )[] lmethods;

public:
    final const( CRSInterface )[] interfaces() const {
        return linterfaces;
    }

    final const( CRSClass )[] classes() const {
        return lclasses;
    }

    final const( CRSStruct )[] structs() const {
        return lstructs;
    }

    final const( CRSEnum )[] enums() const {
        return lenums;
    }

    final const( CRSProperty )[] properties() const {
        return lproperties;
    }

    final const( CRSField )[] fields() const {
        return lfields;
    }

    final const( CRSMethod )[] methods() const {
        return lmethods;
    }

    final const( CRSInterface ) getInterface( string name ) const {
        return findByName( linterfaces, name );
    }

    final const( CRSClass ) getClass( string name ) const {
        return findByName( lclasses, name );
    }

    final const( CRSStruct ) getStruct( string name ) const {
        return findByName( lstructs, name );
    }

    final const( CRSEnum ) getEnum( string name ) const {
        return findByName( lenums, name );
    }

    final const( CRSProperty ) getProperty( string name ) const {
        return findByName( lproperties, name );
    }

    final const( CRSField ) getField( string name ) const {
        return findByName( lfields, name );
    }

    final const( CRSMethod ) getMethod( string name ) const {
        return findByName( lmethods, name );
    }
}

final class CRSModule : CRSScope {
private:
    string lname;

public:
    this( string iname ) {
        lname = iname;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.MODULE;
    }

    override TypeInfo typeId() const {
        return null;
    }

    override string toString() const {
        return "module " ~ lname;
    }
}

final class CRSInterface : CRSScope {
private:
    string lname;
    TypeInfo ltype;
    ESymbolProtection lprot;
    const( CRSInterface )[] lbases;

public:
    this( string iname, TypeInfo itype, ESymbolProtection iprot, const( CRSInterface )[] ibases ) {
        lname = iname;
        ltype = itype;
        lprot = iprot;
        lbases = ibases;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.INTERFACE;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return "interface " ~ lname;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    const( CRSInterface[] ) bases() const {
        return lbases;
    }
}

final class CRSClass : CRSScope {
private:
    string lname;
    TypeInfo ltype;
    ESymbolProtection lprot;
    const( CRSClass ) lbase;
    const( CRSInterface )[] litfs;
    const( AReflectSymbol )[] lattributes;
    Object function( string, int ) linstantiator;

public:
    this(
        string iname,
        TypeInfo itype,
        ESymbolProtection iprot,
        const( CRSClass ) ibase,
        const( CRSInterface )[] iitfs,
        Object function( string, int ) iinstantiator
    ) {
        lname = iname;
        ltype = itype;
        lprot = iprot;
        lbase = ibase;
        litfs = iitfs;
        linstantiator = iinstantiator;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.CLASS;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return "class " ~ lname;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    const( CRSClass ) base() const {
        return lbase;
    }

    const( CRSInterface[] ) itfs() const {
        return litfs;
    }

    const( AReflectSymbol )[] attributes() const {
        return lattributes;
    }

    Object createInstance() const {
        return linstantiator( "", 0 );
    }
}

final class CRSStruct : CRSScope {
private:
    string lname;
    TypeInfo ltype;
    ESymbolProtection lprot;
    ESymbolType lstype;
    string lstypeName;

public:
    this(
        string iname,
        TypeInfo itype,
        ESymbolProtection iprot,
        ESymbolType istype,
        string istypeName
    ) {
        lname = iname;
        ltype = itype;
        lprot = iprot;
        lstype = istype;
        lstypeName = istypeName;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return lstype;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return lstypeName ~ " " ~ lname;
    }

    ESymbolProtection protection() const {
        return lprot;
    }
}

final class CRSConstant : AReflectSymbol {
private:
    string lname;
    TypeInfo ltype;
    ESymbolProtection lprot;
    SVariant function() lgetter;
    string lotype;

public:
    this(
        string iname,
        TypeInfo itype,
        ESymbolProtection iprot,
        SVariant function() igetter,
        string iotype
    ) {
        lname = iname;
        ltype = itype;
        lprot = iprot;
        lgetter = igetter;
        lotype = iotype;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.CONSTANT;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return lname ~ " " ~ lotype;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    SVariant value() const {
        return lgetter();
    }
}

final class CRSEnum : AReflectSymbol {
private:
    string lname;
    TypeInfo ltype;
    ESymbolProtection lprot;
    const( CRSConstant )[] lmembers;

public:
    this(
        string iname,
        TypeInfo itype,
        ESymbolProtection iprot,
        const( CRSConstant )[] imembers
    ) {
        lname = iname;
        ltype = itype;
        lprot = iprot;
        lmembers = imembers;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.ENUM;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return "enum " ~ lname;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    const( CRSConstant )[] members() const {
        return lmembers;
    }

    const( CRSConstant ) getMember( string name ) const {
        return findByName( lmembers, name );
    }
}

final class CRSScalar : AReflectSymbol {
private:
    string lname;
    TypeInfo ltype;
    SVariant function( void* ptr ) lgetter;
    void function( void* ptr, ref SVariant val ) lsetter;

public:
    this(
        string iname,
        TypeInfo itype,
        SVariant function( void* ptr ) igetter,
        void function( void* ptr, ref SVariant val ) isetter
    ) {
        lname = iname;
        ltype = itype;
        lgetter = igetter;
        lsetter = isetter;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.SCALAR;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return lname;
    }

    SVariant get( void* ptr ) const {
        return lgetter( ptr );
    }

    void set( void* ptr, ref SVariant val ) const {
        lsetter( ptr, val );
    }
}

abstract class ARSAccessor : AReflectSymbol {
protected:
    abstract SVariant getValue( ref SVariant target ) const;
    abstract void setValue( ref SVariant target, ref SVariant value ) const;
    
public:
    bool canGetValue() const;
    bool canSetValue() const;
    const( AReflectSymbol ) getterReturnType() const;
    const( AReflectSymbol ) setterParameterType() const;

    SVariant get( T )( auto ref T target ) const {
        static if ( is( T == SVariant ) ) {
            return getValue( target );
        } else static if ( is( T == struct ) ) {
            SVariant o = &target;
            return getValue( o );
        } else static if ( 
            is( T == typeof( null ) ) || 
            is( T == class ) || 
            is( T == interface ) 
        ) {
            SVariant o = target;
            return getValue( o );
        } else {
            static assert( false, "Invalid accessor target '" ~ T.stringof ~ "' - " ~
                          "target must be a class, interface, struct, struct*, null, " ~
                          "or a SVariant containing one of those types" );
        }
    }

    void set( T, V )( auto ref T target, auto ref V value ) const {
        SVariant val = value;

        static if ( is( T == SVariant ) ) {
            setValue( target, val );
        } else static if ( is( T == struct ) ) {
            SVariant o = &target;
            setValue( o, val );
        } else static if ( 
            is( T == typeof( null ) ) || 
            is( T == class ) || 
            is( T == interface ) 
        ) {
            SVariant o = target;
            setValue( o, val );
        } else {
            static assert( false, "Invalid field target '" ~ T.stringof ~ "' - " ~
                          "target must be a class, interface, struct, struct*, null, " ~
                          "or a SVariant containing one of those types" );
        }
    }
}

final class CRSField : ARSAccessor {
    enum EOperation {
        O_GET,
        O_SET,
        O_ADDRESS,
    }

private:
    alias Operator = void function( ref SVariant target, SVariant* value, EOperation operation );

    const( CRSStruct )[] lattributes;

    string lname;
    string ltypeName;
    TypeInfo ltype;
    ESymbolProtection lprot;
    string lfieldTypeName;
    size_t loffset;
    bool bIsStatic;
    Operator loperator;

public:
    this(
        string iname,
        string itypeName,
        TypeInfo itype,
        ESymbolProtection iprot,
        string ifieldTypeName,
        size_t ioffset,
        bool ibIsStatic,
        Operator ioperator
    ) {
        lname = iname;
        ltypeName = itypeName;
        ltype = itype;
        lprot = iprot;
        lfieldTypeName = ifieldTypeName;
        loffset = ioffset;
        bIsStatic = ibIsStatic;
        loperator = ioperator;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.FIELD;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return ltypeName;
    }

    const( CRSStruct )[] attributes() const {
        return lattributes;
    }

    const( CRSStruct ) getAttribute( string iname ) const {
        return findByName( attributes, iname );
    }

    bool hasAttribute( string iname ) const {
        return getAttribute( iname ) !is null;
    }

    bool hasAttribute( T )() const {
        foreach ( attr; lattributes ) {
            if ( attr.typeId is typeid( T ) ) {
                return true;
            }
        }

        return false;
    }

    override SVariant getValue( ref SVariant target ) const {
        SVariant ro;
        loperator( target, &ro, EOperation.O_GET );
        return ro;
    }

    override void setValue( ref SVariant target, ref SVariant val ) const {
        loperator( target, &val, EOperation.O_SET );
    }

    var getValueAsPtr( ref SVariant target ) const {
        SVariant ro;
        loperator( target, &ro, EOperation.O_ADDRESS );
        return ro;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    bool isStatic() const {
        return bIsStatic;
    }

    override bool canGetValue() const {
        return true;
    }

    override bool canSetValue() const {
        return true;
    }

    override const( AReflectSymbol ) getterReturnType() const {
        return reflect( lfieldTypeName );
    }

    override const( AReflectSymbol ) setterParameterType() const {
        return reflect( lfieldTypeName );
    }

    const( AReflectSymbol ) fieldType() const {
        return reflect( lfieldTypeName );
    }

    size_t offset() const {
        return loffset;
    }
}

final class CRSMethod : AReflectSymbol {
    struct SInvokeParams {
        import engine.core.memory : alloc = allocate, dealloc = deallocate, Memory;
    public:
        TypeInfo[] argTypes;
        void*[] args;
        uint[] flags;
        
    private:
        size_t lsize;

    public:
        void allocate( size_t size ) {
            assert( size > 0 );
            assert( lsize == 0 );
            assert( argTypes is null );
            assert( args is null );
            assert( flags is null );

            argTypes = alloc!( TypeInfo[] )( size );
            args = alloc!( void*[] )( size );
            flags = alloc!( uint[] )( size );

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

        size_t size() {
            return lsize;
        }

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

    alias Invoker = SVariant function( ref SVariant target, ref SInvokeParams params );

private:
    const( CRSStruct )[] lattributes;

    string lname;
    TypeInfo ltype;
    string lreturnTypeName;
    ESymbolProtection lprot;
    bool bIsStatic;
    bool bIsFinal;
    bool bIsOverride;
    bool bIsProperty;
    bool bIsCallable;
    string[] lparamTypeNames;
    string[] lparamNames;
    int defParamsNum;

    Invoker linvoker;

public:
    this(
        string iname,
        TypeInfo itype,
        string ireturnTypeName,
        string[] iparamTypeNames,
        string[] iparamNames,
        int idefaultParamsNum,
        ESymbolProtection iprot,
        bool ibIsStatic,
        bool ibIsFinal,
        bool ibIsOverride,
        bool ibIsProperty,
        bool ibIsCallable,
        Invoker iinvoker
    ) {
        lname = iname;
        ltype = itype;
        lreturnTypeName = ireturnTypeName;
        lprot = iprot;
        bIsStatic = ibIsStatic;
        bIsFinal = ibIsFinal;
        bIsOverride = ibIsOverride;
        bIsProperty = ibIsProperty;
        bIsCallable = ibIsCallable;
        lparamTypeNames = iparamTypeNames;
        lparamNames = iparamNames;
        defParamsNum = idefaultParamsNum;
        linvoker = iinvoker;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.METHOD;
    }

    override TypeInfo typeId() const {
        return cast( TypeInfo )ltype;
    }

    override string toString() const {
        return lname;
    }

    ESymbolProtection protection() const {
        return lprot;
    }

    const( AReflectSymbol ) returnType() const {
        return reflect( lreturnTypeName );
    }

    const( CRSStruct )[] attributes() const {
        return lattributes;
    }

    bool isStatic() const {
        return bIsStatic;
    }

    bool isFinal() const {
        return bIsStatic;
    }

    bool isOverride() const {
        return bIsOverride;
    }

    bool isProperty() const {
        return bIsProperty;
    }

    bool isCallable() const {
        return bIsCallable;
    }

    SReflectionRange parameterTypes() const {
        return SReflectionRange( cast( string[] )lparamTypeNames );
    }

    string[] parameterNames() const {
        return cast( string[] )lparamNames;
    }

    size_t parametersCount() const {
        return lparamNames.length;
    }

    string[] parameterTypesNames() const {
        return cast( string[] )lparamTypeNames;
    }

    int defaultParametersCount() const {
        return defParamsNum;
    }

    SVariant invoke( T )( auto ref T target, ref SInvokeParams params ) const {
        static if ( is( T == SVariant ) ) {
            return linvoker( target, params );
        } else static if ( is( T == struct ) ) {
            SVariant o = &target;
            return linvoker( o, params );
        } else static if ( 
            is( T == typeof( null ) ) || 
            is( T == class ) || 
            is( T == interface ) 
        ) {
            SVariant o = target;
            return linvoker( o, params );
        } else {
            static assert( false, "invalid invocation target '" ~ T.stringof ~ "' - " ~
                          "target must be a class, interface, struct, struct*, null, " ~
                          "or a Box containing one of those types" );
        }
    }

    SVariant invoke( T, Args... )( auto ref T target, auto ref Args args ) const {
        SInvokeParams params;

        static if ( Args.length > 0 ) {
            params.allocate( Args.length );

            foreach ( i, argType; Args ) {
                static if ( is( argType == SVariant ) ) {
                    params.setArgEx( i, args[i].type, args[i].ldata );
                } else {
                    params.setArg!argType( i, &args[i] );
                }
            }
        }

        SVariant ret = invoke( target, params );
        
        if ( params.size > 0 ) {
            params.free();
        }
        
        return ret;
    }
}

final class CRSProperty : ARSAccessor {
private:
    string lname;
    const( CRSMethod )[] lgetters;
    const( CRSMethod )[] lsetters;

public:
    this(
        string iname,
        const( CRSMethod )[] igetters,
        const( CRSMethod )[] isetters
    ) {
        lname = iname;
        lgetters = igetters;
        lsetters = isetters;
    }

    override string name() const {
        return lname;
    }

    override ESymbolType type() const {
        return ESymbolType.PROPERTY;
    }

    override TypeInfo typeId() const {
        return typeid( this );
    }

    const( CRSMethod )[] getters() const {
        return lgetters;
    }

    const( CRSMethod )[] setters() const {
        return lsetters;
    }

    const( AReflectSymbol ) returnType() const {
        assert( lgetters.length );
        return lgetters[0].returnType;
    }

    const( AReflectSymbol ) paramType() const {
        assert( lsetters.length );
        return lsetters[0].parameterTypes.front();
    }

    override string toString() const {
        return "property " ~ name;
    }

protected:
    override SVariant getValue( ref SVariant target ) const {
        assert( lgetters.length );
        return lgetters[0].invoke( target );
    }

    override void setValue( ref SVariant target, ref SVariant val ) const {
        assert( lsetters.length );
        lsetters[0].invoke( target, val );
    }

    override bool canGetValue() const {
        return lgetters.length > 0;
    }

    override bool canSetValue() const {
        return lsetters.length > 0;
    }

    override const( AReflectSymbol ) getterReturnType() const {
        assert( lgetters.length );
        return lgetters[0].returnType();
    }

    override const( AReflectSymbol ) setterParameterType() const {
        assert( lsetters.length );
        return lsetters[0].parameterTypes.front();
    }


}

private:

Rebindable!( const( AReflectSymbol ) )[string] _reflections;

struct SReflectionRange {
private:
    string[] ltypeNames;
    Rebindable!( const AReflectSymbol ) lcurrent;

public:
    bool empty() const {
        return ltypeNames.length > 0;
    }

    const( AReflectSymbol ) front() const {
        assert( !empty );
        return lcurrent;
    }

    void popFront() {
        assert( !empty );
        ltypeNames = ltypeNames[1..$];
        if ( ltypeNames.length ) {
            lcurrent = reflect( ltypeNames[0] );
        }
    }
}

final class CReflector( T )
if ( isScalarType!T ) {
    static this() {
        _reflections[fullyQualifiedName!T] = get();
    }
    
    static auto get() {
        static SVariant getter( void* ptr ) {
            return SVariant( *cast( T* )ptr );
        }

        static void setter( void* ptr, ref SVariant value ) {
            static if ( isSetSupported!T ) {
                *( cast( T* )ptr ) = cast( T )value;
            } else {
                assert( false );
            }
        }

        static rScalar refl = new CRSScalar( T.stringof, typeid( T ), &getter, &setter );
        return refl;
    }
}

final class CReflector( alias T ) {
    static this() {
        static if ( isModule!T || isSomeFunction!T ) {
            _reflections[fullyQualifiedName!T] = get();
        } else {
            _reflections[fullyQualifiedName!( Unqual!T )] = get();
        }
    }

    static auto get() {
        static if ( isModule!T ) {
            static const( CRSModule ) refl = parseScope!T( new CRSModule( T.stringof[7..$] ) );
        } else static if ( is( T == interface ) ) {
            static const( CRSInterface ) refl = parseScope!T( 
                new CRSInterface( __traits( identifier, T ), typeid( T ), protectionOf!T, baseInterfaces!T )
            );
        } else static if ( is( T == class ) ) {
            static Object instantiator( string file = __FILE__, int line = __LINE__ ) {
                import engine.core.memory : allocate, allocateEx;
                enum canInstance = __traits( compiles, { auto X = allocate!T; } );
                static if ( canInstance ) {
                    return allocateEx!T( file, line );
                } else {
                    return null;
                }
            }

            static const( CRSClass ) refl = parseScope!T(
                new CRSClass(
                    __traits( identifier, T ), typeid( T ), protectionOf!T, baseclassOf!T, baseInterfaces!T, &instantiator
                )
            );
        } else static if ( is( T == struct ) || is( T == union ) ) {
            static const( CRSStruct ) refl = parseScope!T(
                new CRSStruct(
                    __traits( identifier, T ), typeid( T ), protectionOf!T, is( T == struct ) ? ESymbolType.STRUCT : ESymbolType.UNION, T.stringof
                )
            );
        } else static if ( is( T == enum ) ) {
            static const( CRSEnum ) refl = parseScope!T( new CRSEnum( T.stringof, typeid( T ), protectionOf!T, enumMembers!T ) );
        } else static if ( isDelegate!T ) {}
        else static if ( isFunctionPointer!T ) {}
        else static if ( isSomeFunction!T && !isReservedMethod!T ) {
            alias S = Alias!( __traits( parent, T ) );

            static if ( isFinalFunction!S ) {
                enum isCallable = true;
            } else static if ( isAbstractClass!S || isAbstractFunction!S ) {
                enum isCallable = false;
            } else {
                enum isCallable = true;
            }

            static SVariant invoker( ref SVariant target, ref CRSMethod.SInvokeParams params ) {
                alias RT = ReturnType!( typeof( &T ) );

                static if ( !isFinalFunction!T && isAbstractClass!S ) {
                    throw new Exception( "Cannot call methods of abstract class" );
                } else static if ( isAbstractFunction!T ) {
                    throw new Exception( "Cannot call abstract methods" );
                } else static if ( is( RT _S == inout _S ) || is( RT _S == inout _S[] ) ) {
                    throw new Exception( "Cannot call inout function" );
                } else {
                    static if ( isAggregateType!S ) {
                        static if ( is( S == class ) || is( S == interface ) ) {
                            S tar = null;
                            if ( !target.isEmpty() ) {
                                tar = cast( S )target;
                            }
                        } else static if ( is( S == struct ) ) {
                            bool isPtr = false;
                            S* tar = null;
                            
                            if ( !target.isEmpty() ) {
                                isPtr = ( target.type == typeid( S* ) );
                                tar = isPtr ? cast( S* )target : cast( S* )target.ptr;
                            }
                        } else {
                            static assert( false, "Instance type must be a class, interface, or struct*" );
                        }

                        static if ( __traits( isStaticFunction, T ) ) {
                            if ( tar !is null ) {
                                throw new Exception( "Instance pointer should be null" );
                            }
                        } else {
                            if ( tar is null ) {
                                throw new Exception( "Instance pointer cannot be null" );
                            }
                        }
                    }

                    alias ParamType = Parameters!( typeof( &T ) );
                    alias DefaultParams = ParameterDefaults!T;
                    alias ArgType = UnqualTuple!( ParamType );

                    static SVariant[DefaultParams.length] defaultArgs;
                    static foreach ( i, arg; DefaultParams ) {
                        static if ( is( arg == void ) ) {
                            defaultArgs[i] = SVariant( null );
                        } else {
                            defaultArgs[i] = SVariant( arg );
                        }
                    }

                    if ( params.size != ParamType.length ) {
                        throw new Exception( "Wrong number of arguments" );
                    }

                    foreach ( i, ptype; ParamType ) {
                        import engine.core.utils.typeinfo : isBaseClassTypeInfoFor;
                        
                        TypeInfo rt = params.argTypes[i];
                        TypeInfo lt = typeid( ptype );

                        // Skip default params
                        if ( rt is null ) {
                            continue;
                        }

                        // Skip string, variant
                        if ( rt.toString() == "char[]" || ptype.stringof == "string" || ptype.stringof == "SVariant" ) {
                            continue;
                        }

                        // Checл if it is class inheritance
                        if ( isBaseClassTypeInfoFor( rt, lt ) ) {
                            continue;
                        }

                        if ( rt !is lt ) {
                            throw new Exception( "Wrong argument type - expected '" ~ ptype.stringof ~ "', received '" ~ rt.toString() );
                        }
                    }

                    ArgType args;
                    foreach ( i, atype; ArgType ) {
                        if ( params.argTypes[i] !is null ) {
                            static if ( is( atype == string ) ) {
                                if ( params.flags[i] == 1 ) {
                                    args[i] = cast( string )fromStringz( cast( char* )params.args[i] );
                                } else {
                                    args[i] = *cast( atype* )params.args[i];
                                }
                            } else static if ( is( atype : Object ) ) {
                                if ( params.flags[i] == 2 ) {
                                    args[i] = cast( atype )params.args[i];
                                } else {
                                    args[i] = *cast( atype* )params.args[i];
                                }
                            } else {
                                static if ( is( atype == var ) ) {
                                    import engine.core.ref_count;

                                    var v;
                                    v.ldata = cast( SVariantData* )params.args[i];

                                    RC.incRef( v.ldata );

                                    args[i] = v;
                                } else {
                                    args[i] = *cast( atype* )params.args[i];
                                }
                            }
                        } else {
                            static if ( is( atype == bool ) ) {
                                args[i] = cast( bool )cast( int )defaultArgs[i];
                            } else {
                                atype val = cast(atype)defaultArgs[i];
                                args[i] = val;
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

                    var result;

                    static if ( __traits( compiles, SVariant( fun( args ) ) ) ) {
                        result = SVariant( fun( args ) );
                    } else {
                        fun( args );
                        result = SVariant();
                    }

                    // In some situations may be buggy
                    // TODO: TESTS
                    static foreach ( i, S; ArgType ) {
                        import std.traits : hasElaborateDestructor;

                        static if ( hasElaborateDestructor!S ) {
                            typeid( S ).destroy( cast( void* )&args[i] );
                        }
                    }

                    return result;
                }
            }

            static const( CRSMethod ) refl = new CRSMethod(
                __traits( identifier, T ),
                typeid( typeof( &T ) ),
                fullyQualifiedName!( ReturnType!T ),
                paramTypeNames!T(),
                cast(string[])[ParameterIdentifierTuple!T],
                defaultParamsNum!T(),
                protectionOf!T,
                __traits( isStaticFunction, T ),
                __traits( isFinalFunction, T ),
                __traits( isOverrideFunction, T ),
                ( functionAttributes!( T ) & FunctionAttribute.property ) != 0,
                isCallable,
                &invoker
            );
        } else {
            static assert( "Cannot reflect type '" ~ T.stringof ~ "'" );
        }

        return refl;
    }
}

T parseScope( alias S, T )( T target ) {
    import engine.core : log;

    foreach ( member; __traits( allMembers, S ) ) {
        static if ( __traits( compiles, mixin( "hasUDA!( __traits( getMember, S, member ), NoReflection )" ) ) ) {
            enum noReflection = hasUDA!( __traits( getMember, S, member ), NoReflection );
        } else {
            enum noReflection = true;
        }

        static if ( !noReflection ) {
            alias mem = Alias!( __traits( getMember, S, member ) );

            static if ( is( member == interface ) ) {
                target.linterfaces ~= reflect!( __traits( getMember, S, member ) )();
            }

            static if ( is( member == class ) ) {
                target.lclasses ~= reflect!( __traits( getMember, S, member ) )();
            } else static if ( is( member == struct ) || is( member == union ) ) {
                target.lstructs ~= reflect!( __traits( getMember, S, member ) )();
            } else static if ( is( member == enum ) ) {
                target.lenums ~= reflect!( __traits( getMember, S, member ) )();
            } else static if ( isDelegate!( __traits( getMember, S, member ) ) ) {}
            else static if ( isFunctionPointer!( __traits( getMember, S, member ) ) ) {}
            else static if ( isSomeFunction!( __traits( getMember, S, member ) ) && !isReservedMethod!mem ) {
                enum isProp = isProperty!mem;
                alias overloadSeq = AliasSeq!( __traits( getOverloads, S, member ) );

                static if ( isProp ) {
                    alias aGetters = Filter!( isGetterProperty, overloadSeq );
                    alias aSetters = Filter!( isSetterProperty, overloadSeq );
                    CRSMethod[] getters = new CRSMethod[aGetters.length];
                    CRSMethod[] setters = new CRSMethod[aSetters.length];
                    size_t getterCount = 0;
                    size_t setterCount = 0;
                } else {
                    CRSMethod[] overloads = new CRSMethod[overloadSeq.length];
                }

                foreach ( i, overload; overloadSeq ) {
                    CRSMethod m = cast( CRSMethod )reflect!overload;

                    static if ( isProp ) {
                        static if ( isGetterProperty!overload ) {
                            getters[getterCount++] = m;
                        }

                        static if ( isSetterProperty!overload ) {
                            setters[setterCount++] = m;
                        }
                    } else {
                        overloads[i] = m;
                    }
                }

                static if ( isProp ) {
                    target.lproperties ~= new CRSProperty( member, cast( const( CRSMethod )[] )getters, cast( const( CRSMethod )[] )setters );
                } else {
                    target.lmethods ~= cast( const( CRSMethod )[] )overloads;
                }
            } else static if ( isField!( __traits( getMember, S, member ) ) ) {
                alias FT = typeof( mem );

                static if ( __traits( compiles, { enum _ = mem.offsetof; } ) ) {
                    enum offset = mem.offsetof;
                    enum isStatic = false;
                } else {
                    enum offset = 0;
                    enum isStatic = true;
                }

                CRSField.Operator operator = ( ref SVariant target, SVariant* val, CRSField.EOperation operation ) {
                    final switch ( operation ) {
                    case CRSField.EOperation.O_SET:
                        static if ( isSetSupported!FT ) {
                            static if ( isStatic ) {
                                mem = cast( FT )( *val );
                            } else {
                                static if ( is( S == class ) || is( S == interface ) ) {
                                    S tar = cast( S )target;
                                } else static if ( is( S == struct ) ) {
                                    bool isPtr = ( target.type == typeid( S* ) );
                                    S* tar = isPtr ? cast( S* )target : cast( S* )target.ptr;
                                } else {
                                    static assert( false, "Target instance must be a class, interface, or struct*" );
                                }

                                *cast( FT* )( cast( void* )tar + offset ) = cast( FT )*val;
                            }
                        } else {
                            log.warning( "setValue not supported for this field type" );
                        }
                        break;

                    case CRSField.EOperation.O_GET:
                        static if ( isGetSupported!FT ) {
                            static if ( isStatic ) {
                                *val = mem;
                            } else {
                                static if ( is( S == class ) || is( S == interface ) ) {
                                    S tar = cast( S )target;
                                } else static if ( is( S == struct ) ) {
                                    bool isPtr = ( target.type == typeid( S* ) );
                                    S* tar = isPtr ? cast( S* )target : cast( S* )target.ptr;
                                } else {
                                    static assert( false, "Instance type must be a class, interface, or struct*" );
                                }

                                *val = *cast( FT* )( cast( void* )tar + offset );
                            }
                        } else {
                            log.warning( "getValue not supported for this field type" );
                        }
                        break;
                    
                    case CRSField.EOperation.O_ADDRESS:
                        static if ( isStatic ) {
                            *val = cast( void* )( &mem );
                        } else {
                            static if ( is( S == class ) || is( S == interface ) ) {
                                S tar = cast( S )target;
                            } else static if ( is( S == struct ) ) {
                                bool isPtr = ( target.type == typeid( S* ) );
                                S* tar = isPtr ? cast( S* )target : cast( S* )target.ptr;
                            } else {
                                static assert( false, "Instance type must be a class, interface, or struct*" );
                            }

                            *val = cast( void* )tar + offset;
                        }
                        break;
                    }
                };

                alias ATTRS = __traits( getAttributes, mem );
                CRSStruct[] attributes = new CRSStruct[ATTRS.length];

                CRSField _field = new CRSField(
                    __traits( identifier, mem ),
                    FT.stringof,
                    typeid( FT ),
                    toProtection!( __traits( getProtection, mem ) ),
                    fullyQualifiedName!FT,
                    offset,
                    isStatic,
                    operator
                );

                _field.lattributes ~= attributes;

                target.lfields ~= _field;
            } else {}
        } else {}
    }

    return target;
}

public:
const( CRSModule ) reflect( alias T )()
if ( is( isModule!T ) ) {
    return CReflector!T.get();
}

const( CRSInterface ) reflect( alias T )() 
if ( is( T == interface ) && !__traits( isTemplate, T ) ) {
    return CReflector!( Unqual!T ).get();
}

const( CRSClass ) reflect( alias T )()
if ( is( T == class ) && !__traits( isTemplate, T ) ) {
    return CReflector!( Unqual!T ).get();
}

const( CRSStruct ) reflect( alias T )()
if ( ( is( T == struct ) || is( T == union ) ) && !__traits( isTemplate, T ) ) {
    return CReflector!( Unqual!T ).get();
}

const( CRSEnum ) reflect( alias T )()
if ( is( T == enum ) && !__traits( isTemplate, T ) ) {
    return CReflector!( Unqual!T ).get();
}

const( CRSScalar ) reflect( T )()
if ( isScalarType!T && !__traits( isTemplate, T ) ) {
    return CReflector!( Unqual!T ).get();
}

const( CRSMethod ) reflect( alias T )()
if ( isSomeFunction!T && !isReservedMethod!T && !__traits( isTemplate, T ) ) {
    return CReflector!T.get();
}

const( CRSUnsupported ) reflect( T )()
if ( __traits( isTemplate, T ) || isDelegate!T || isArray!T || isPointer!T ||
   !( isScalarType!T || isModule!T || is( T == interface ) || is( T == class ) || is( T == struct ) || is( T == union ) || is( T == enum ) )
)
{
    static const( CRSUnsupported ) refl = new CRSUnsupported( T.stringof, typeid(T) );
    return refl;
}

const( AReflectSymbol ) reflect( string qualifiedName )  {
    assert( !__ctfe, "this method cannot be called at compile time" );
    auto r = qualifiedName in _reflections;
    return r ? *r : null;
}

string[] paramTypeNames( alias T )() {
    alias Types = ParameterTypeTuple!( typeof( &T ) );
    string[] ret = new string[Types.length];
    
    foreach( i, Ty; Types ) {
        ret[i] = fullyQualifiedName!Ty;
    }

    return ret;
}

int defaultParamsNum( alias T )() {
    alias Defaults = ParameterDefaults!( typeof( &T ) );
    int vidx = 0;
    foreach ( i, de; Defaults ) {
        if ( !is( de == void ) ) {
            vidx += 1;
            break;
        }
    }

    return vidx;
}

template isGetSupported( T ) {
    enum isGetSupported = __traits( compiles, { SVariant( T.init ); } );
}

template isSetSupported( T ) {
	import std.traits : isNumeric, isBoolean, isSomeString;
	enum isSetSupported = isNumeric!T || isBoolean!T || is( T : Object ) || isSomeString!T;
}

const(CRSConstant)[] enumMembers(T)()
{
    alias allMembers = AliasSeq!(__traits(allMembers, T));
    auto ret = new CRSConstant[allMembers.length];

    foreach(i, member; allMembers)
    {
        static if(__traits(hasMember, T, member))
        {
            alias M = Alias!(__traits(getMember, T, member));
            alias OriginalType!(typeof(M)) OT;
            SVariant function() getter = { return SVariant(cast(OT)M); };
            ret[i] = new CRSConstant(__traits(identifier, M), typeid(M), protectionOf!M, getter, to!string(cast(OT)M));
        }
    }
    return ret;
}

template isScalar( T ) {
    import std.traits : isScalarType;
    enum isScalar = isScalarType!T;
}

template isScalar( alias T ) {
    enum isScalar = false;
}

template isScalar( string fqn ) {
    import std.traits : isScalarType;
    
    static if(__traits(compiles, { mixin( "enum e = isScalarType!(" ~ fqn ~ ");" ); }) ) {
        mixin("enum isScalar = isScalarType!(" ~ fqn ~ ");");
    } else {
        enum isScalar = false;
    }
}

const( CRSInterface )[] baseInterfaces( T )() {
    alias Itfs = InterfacesTuple!T;
    
    CRSInterface[] ret = new CRSInterface[Itfs.length];
    
    foreach( i, Itf; Itfs ) {
        ret[i] = cast()reflect!Itf;
    }
    
    return ret;
}

template MethodTypeOf( alias M ) {
    static if( __traits( isStaticFunction, M ) ) {
        alias MethodTypeOf = typeof( toDelegate( &M ).funcptr );
    } else {
        alias MethodTypeOf = typeof( toDelegate( &M ) );
    }
}

template owningModule( alias T ) {
    alias parent = Alias!( __traits( parent, T ) );

    static if( isModule!parent ) {
        alias owningModule = parent;
    } else {
        alias owningModule = owningModule!parent;
    }
}

template isModule(alias T) {
    enum isModule = __traits( isModule, T );
}

template isField( alias T ) {
    enum hasInit = is( typeof( typeof(T).init ) );

    enum isManifestConst = __traits( compiles, { enum e = T; } );
    
    enum isField = hasInit && !isManifestConst;
}

T findByName( T )( T[] arr, string name ) {
    foreach( e; arr ) {
        if ( e.name == name ) {
            return e;
        }
    }

    return null;
}

T[] findAllByName( T )( T[] arr, string name ) {
    T[] ret;

    foreach( e; arr ) {
        if ( e.name == name ) {
            ret ~= e;
        }
    }

    return ret;
}

private template toProtection( string prot ) {
    static if ( prot == "public" ) {
        enum toProtection = ESymbolProtection.PUBLIC;

    } else static if ( prot == "protected" ) {
        enum toProtection = ESymbolProtection.PROTECTED;

    } else static if ( prot == "private" ) {
        enum toProtection = ESymbolProtection.PRIVATE;

    } else static if ( prot == "package" ) {
        enum toProtection = ESymbolProtection.PACKAGE;

    } else static if ( prot == "export" ) {
        enum toProtection = ESymbolProtection.EXPORT;

    }
}

private template protectionOf( alias T ) {
    enum prot = __traits( getProtection, T );
    enum protectionOf = toProtection!prot;
}

const( CRSClass ) baseclassOf( alias T )() {
    static if ( !is( T == Object ) ) {
        alias BaseClassesTuple!T B;
        return reflect!( B[0] );
    } else {
        return null;
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

template isReservedMethod( alias M ) {
    enum id = __traits( identifier, M );
    enum isReservedMethod = id.length >= 2 && id[0..2] == "__";
}

template isProperty( alias T ) {
    enum isProperty = ( functionAttributes!T & FunctionAttribute.property ) != 0;
}

template isGetterProperty( alias T ) {
    static if ( isProperty!T && !is( ReturnType!T == void ) && ( arity!T == 0 ) ) {
        enum isGetterProperty = true;
    
    } else {
        enum isGetterProperty = false;
    }
}

template isSetterProperty( alias T ) {
    static if ( isProperty!T && is( ReturnType!T == void ) && ( arity!T == 1 ) ) {
        enum isSetterProperty = true;
    } else {
        enum isSetterProperty = false;
    }
}

public {
    static rbool = reflect!bool;
    static rint = reflect!int;
    static ruint = reflect!uint;
    static rbyte = reflect!byte;
    static rubyte = reflect!ubyte;
    static rfloat = reflect!float;
    static rdouble = reflect!double;
    static rstring = reflect!string;

    static rboolp = reflect!(bool*);
    static rintp = reflect!(int*);
    static ruintp = reflect!(uint*);
    static rbytep = reflect!(byte*);
    static rubytep = reflect!(ubyte*);
    static rfloatp = reflect!(float*);
    static rdoublep = reflect!(double*);
    static rstringp = reflect!(string*);

    alias rSymbol = const AReflectSymbol;
    alias rClass = const CRSClass;
    alias rConstant = const CRSConstant;
    alias rEnum = const CRSEnum;
    alias rField = const CRSField;
    alias rInterface = const CRSInterface;
    alias rMethod = const CRSMethod;
    alias rModule = const CRSModule;
    alias rProperty = const CRSProperty;
    alias rScalar = const CRSScalar;
    alias rScope = const CRSScope;
    alias rStruct = const CRSStruct;
    alias rUnsupported = const CRSUnsupported;
}
