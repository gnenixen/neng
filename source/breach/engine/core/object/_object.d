module engine.core.object._object;

public {
    import engine.core.reflection;
    import engine.core.error;
    import engine.core.string;

    import engine.core.object.class_description;
    import engine.core.object.util_cdc;
    import engine.core.object.object_extension;
    import engine.core.object.serialize;
}

import engine.core.memory.memory;
import engine.core.log;

alias ID = ulong;
enum ID_INVALID = ulong.max;

/*
    Custom object type

    Object type can be declarated as struct with given
    members:
        template TMixin( T ) - mixin for generated code
        String typename - for check object type
        bool isNeedCustomInit - for check if object need custom initialize logic
        bool objectInit - object initialize logic
        bool isCanDestroy - some objects maybe need custom logic of lifetime

    to specify object type just add struct as second param in
    TRegisterClass mixin in body of class:
        mixin( TRegisterClass!( T, Singleton ) );

    ( See SOT_Default and Singleton as example )
*/
struct SOT_Default {
static:
    template TMixin( T ) { enum TMixin = ""; }
    String typename() { return rs!"default"; }
    bool isNeedCustomInit() { return false; }
    bool isInitOverridable() { return true; }
    bool objectInit( CObject obj ) { return true; }
    bool isCanDestroy( CObject obj ) { return true; }
}

template TRegisterClass( T, OT = SOT_Default ) {
    import std.string : format;
    import engine.core.utils.uda : hasUDA;
    
    enum TRegisterHeader = "";

    enum OBJECT_FORMAT_HEADER = q{
        private {
            import std.traits : BaseClassesTuple;
            import engine.core.memory : allocate, deallocate;
        }

        private static {
            CRSClass __class_reflection;
            CClassDescription __class_description;
        }

        /* STATIC CLASS INFO API */
        static void initializeClass( rClass rclass ) {
            // Check functions protection
            {
                static if ( __traits( compiles, lclassDescription( null ) ) ) {
                    static assert(
                        __traits( getProtection, %1$s.lclassDescription ) != "public",
                        "lclassDescription must be private or protected for: %1$s"
                    );
                }
            }

            {
                __class_reflection = cast()rclass;
            }

            // Generate description info
            {
                __class_description = allocate!CClassDescription();
                __class_description.bind( __class_reflection );
                __full_gen_reflClassDescription( __class_description );
            }
        }

        static void deinitializeClass() {
            deallocate( __class_description );
        }

        static CClassDescription stClassDescription() {
            return __class_description;
        }

        protected {
            static void __full_gen_reflClassDescription( CClassDescription descr ) {

                alias P = BaseClassesTuple!( %1$s )[0];
                P.__full_gen_reflClassDescription( descr );
                static if ( __traits( compiles, lclassDescription( descr ) ) ) {
                    lclassDescription( descr );
                }

                CCDC_ObjectInit oi = descr.get!CCDC_ObjectInit;

                if ( oi.bCanOverride ) {
                    oi.isNeedCustomInit = &%2$s.isNeedCustomInit;
                    oi.bCanOverride = %2$s.isInitOverridable();
                    oi.objectInit = &%2$s.objectInit;
                    oi.isCanDestroy = &%2$s.isCanDestroy;
                }
            }
        }

        public override @property pragma( inline, true ) {
            String typename() {
                return String( typeof( this ).stringof );
            }
        }

        override rClass reflection() {
            return __class_reflection;
        }

        override CClassDescription classDescription() {
            return __class_description;
        }

        static String objectType() {
            return %2$s.typename();
        }
    };

    enum TRegisterClass = TRegisterHeader ~
    format(
        OBJECT_FORMAT_HEADER ~ OT.TMixin!T ~ TWrapStringMethods!T,
        T.stringof,
        OT.stringof
    );
}

/**
    Basic engine object
    
    Lifetime process:
        this                                    - object just initialized in memory
        postInit                                - object added to pool and accesible by getObjectByID
        *** Some interestring life ***
        preDelete                               - object still in pool, but ready to be deleted from them
        ~this                                   - basic destruct, object already removed from pool

    Reflection:
        rClass rclass = obj.reflection();

    Object can be additionaly descripted in lclassDescription, for
    registering some usefull stuff, like script methods export,
    associating member with property and more. For example see
    CCDC_MPA and CObject.lclassDescription

    For correct inheritance add this in class body:
        mixin( TRegisterClass!TYPE );
        OR
        mixin( TRegisterClass!( TYPE, * ) );
*/
class CObject {
protected:
    ID lid = ID_INVALID;    /// Object unique id

    CObjectExtensionsHandler __object_extensions_handler;

private:
    static {
        // Static handler class reflection for future usage
        CRSClass __class_reflection;

        // User defined object information
        CClassDescription __class_description;
    }

    /**
        Discripts object by using AClassDescripionCategory
        inherit classes
    */
    static void lclassDescription( CClassDescription descr ) {
        CCDC_MPA mpa = descr.get!CCDC_MPA;
        mpa.register( "lid", "id" );

        CCDC_Serialize sr = descr.get!CCDC_Serialize();
        sr.register( "lid" );
    }

public:
    this() {
        __object_extensions_handler = allocate!CObjectExtensionsHandler;
    }

    ~this() {
        deallocate( __object_extensions_handler );
    }

    /* STATIC CLASS INFO API */

    /**
        Initialize class runtime info, like reflection
        and descrition
    */
    static void initializeClass( rClass rclass ) {
        {
            __class_reflection = cast()rclass;
        }

        // Generate description info
        {
            __class_description = allocate!CClassDescription;
            __class_description.bind( __class_reflection );
            __full_gen_reflClassDescription( __class_description );
        }
    }

    /**
        Free class runtime info
    */
    static void deinitializeClass() {
        deallocate( __class_description );
    }

    /**
        If we have code like:
            CObject obj = newObject!CSprite;
            auto descr = obj.classDescription();
        
        Everything works OK, because called virtual
        method, but with static methods this not work
        correctly, then given method exitsts only for
        code like:
            void func( T )()
            if ( is( T : CObject ) ) {
                ...
                T.stClassDescription();
                ...
            }
    */
    static CClassDescription stClassDescription() {
        return __class_description;
    }

    static String objectType() {
        return SOT_Default.typename();
    }


    /// Called after object added to pool
    void postInit() {}

    /// Called before object removed from pool
    void preDelete() {}

    /// Implements custom object casting
    void* castImpl( TypeInfo typeinfo ) { return null; }

    /// Implements custom object comparation
    bool cmpImpl( CObject obj ) { return true; }

    /**
        Return class description, generated from
        "lclassDescription"
    */
    CClassDescription classDescription() {
        return __class_description;
    }

    T getCDC( T )()
    if ( is( T : AClassDescriptionCategory ) ) {
        return __class_description.get!T;
    }

    T extension( T )()
    if ( is( T : AObjectExtension ) ) {
        return __object_extensions_handler.get!T;
    }

    rClass reflection() {
        return __class_reflection;
    }

    @property pragma( inline, true ) {
        final ID id() const {
            return lid;
        }

        final void id( ID iid ) {
            if ( lid == ID_INVALID ) {
                lid = iid;
            }
        }

        String typename() {
            return String( typeof( this ).stringof );
        }
    }

public:
    override bool opEquals( Object b ) const {
        // Hardly contol is object even
        // allocated by engine
        version( __MEM_CONTROL_HARD )
            assert( !Memory.isValid( cast( void* )b ) );

        CObject obj = cast( CObject )b;

        // Trying to compare with some
        // object that not inherit from
        // CObject
        if ( obj is null ) {
            return false;
        }

        // In some situations we need to
        // compare currently unregistered
        // objects, then ids of it is 
        // ID_INVALID, in given situation
        // we compare adresses of objects
        if ( lid == ID_INVALID && obj.id() == ID_INVALID ) {
            return (cast( void* )this) == (cast( void* )obj);
        }

        // In regular situations just compare ids && call cmpImpl
        return lid == obj.lid;
    }

protected:
    static void __full_gen_reflClassDescription( CClassDescription descr ) {
        lclassDescription( descr );
    }
}

alias Singleton = SOT_Singleton;
struct SOT_Singleton {
static:
    template TMixin( T ) {
        import std.string : format;

        enum TMixin = format( q{
            private static __gshared %1$s lrot_singleton_%1$s = null;

            @property pragma( inline, true ) final public static __gshared {
                void sig( %1$s snglt ) {
                    assert( !lrot_singleton_%1$s, "Trying to initialize singleton twice." );
                    lrot_singleton_%1$s = snglt;
                }

                %1$s sig() {
                    assert( lrot_singleton_%1$s, "Uninitialized singleton usage!" );
                    return lrot_singleton_%1$s;
                }
            }

            // Only for reflection method invoke
            pragma( inline, true ) final public static __gshared %1$s singleton() {
                return lrot_singleton_%1$s;
            }
        },
        T.stringof
        );
    }

    String typename() { return rs!"singleton"; }
    bool isNeedCustomInit() { return true; }
    bool isInitOverridable() { return false; }

    bool objectInit( CObject obj ) {
        rClass rclass = obj.reflection();
        if ( !rclass ) {
            log.error( "Canno't get reflection for singleton: ", obj );
            return false;
        }

        rProperty sig = rclass.getProperty( "sig" );
        if ( !sig ) {
            log.error( "Canno't get 'sig' property for singleton: ", obj );
            return false;
        }

        sig.set( SVariant(), obj );
        
        return true;
    }

    bool isCanDestroy( CObject obj ) {
        return false;
    }
}

alias SingletonBackendable = SOT_SingletonBackendable;
struct SOT_SingletonBackendable {
static:
    template TMixin( T ) {
        import std.string : format;

        enum TMixin = format( q{
            private static __gshared %1$s lrot_singleton_%1$s = null;

            @property pragma( inline, true ) final public static __gshared {
                void sig( %1$s snglt ) {
                    assert( !lrot_singleton_%1$s, "Trying to initialize singleton twice." );
                    lrot_singleton_%1$s = snglt;
                }

                %1$s sig() {
                    assert( lrot_singleton_%1$s, "Uninitialized singleton usage!" );
                    return lrot_singleton_%1$s;
                }
            }

            // Only for reflection method invoke
            pragma( inline, true ) final public static __gshared %1$s singleton() {
                return lrot_singleton_%1$s;
            }
        },
        T.stringof
        );
    }

    String typename() { return rs!"singleton_backendable"; }
    bool isNeedCustomInit() { return true; }
    bool isInitOverridable() { return false; }

    bool objectInit( CObject obj ) {
        rClass rclass = obj.reflection();
        if ( !rclass ) {
            log.error( "Canno't get reflection for singleton: ", obj );
            return false;
        }

        rProperty sig = rclass.getProperty( "sig" );
        if ( !sig ) {
            log.error( "Canno't get 'sig' property for singleton: ", obj );
            return false;
        }

        sig.set( SVariant(), obj );
        
        return true;
    }

    bool isCanDestroy( CObject obj ) {
        return false;
    }
}

/*   OBJECT REFLECTION   */

bool hasMethod( CObject obj, String mname ) {
    scope ( failure ) return false;
        SError.msg( obj !is null, "Passed null object" );
        SError.msg( obj.reflection() !is null, "Given object not have reflection data: ", obj.typename );

    return obj.reflection().getMethod( mname.c_str ) !is null;
}

var call( Args... )( CObject obj, String mname, Args args ) {
    scope ( failure ) return var();
        SError.msg( obj !is null, "Passed null object" );
        SError.msg( obj.reflection() !is null, "Given object not have reflection data: ", obj.typename );

    rMethod method = obj.reflection().getMethod( mname.toNativeString() );
    if ( !method ) {
        log.warning( "Given object not have method: ", obj.typename, ".", mname );
        return var();
    }

    return method.invoke( obj, args );
}

/**
    Wrapper for custom object casting logic
    calls castImpl for object, if it returns null
    cast object directly.

    Created when i canno't write normal opCast
    implementation for class on game level
    (CComponent if you want to see it)

    Single function in core that doesn't match
    guideline, because I not found normal
    name for it, then just Cast, like in some
    other engines.
*/
T Cast( T, U )( U object ) {
    static if ( is( U : CObject ) ) {
        if ( object is null ) return null;

        T obj = cast( T )object.castImpl( typeid( T ) );
        if ( !obj ) {
            obj = cast( T )object;
        }

        return obj;
    }
    else {
        return cast( T )object;
    }

    assert( false );
}

/**
    Simple wrapper for getting some fields,
    it you want to create reflection-based
    code
*/
var get( CObject obj, String mname ) {
    scope ( failure ) return var();
        SError.msg( obj !is null, "Passed null object" );
        SError.msg( obj.reflection() !is null, "Given object not have reflection data: ", obj.typename );

    rField field = obj.reflection().getField( mname.c_str );
    if ( !field ) {
        return var();
    }

    return field.get( obj );
}

/**
    Wrapper for correct setting some values of type,
    using MPA class description.

    If MPA is not setted, then just set field
    directly
*/
void set( Arg )( CObject obj, String mname, Arg arg ) {
    scope ( failure ) return;
        SError.msg( obj !is null, "Passed null object" );
        SError.msg( obj.reflection() !is null, "Given object not have reflection data: ", obj.typename );

    CCDC_MPA mpa = obj.getCDC!CCDC_MPA;
    rProperty prop = mpa.getMemberAssociatedProperty( mname.c_str );
    if ( prop ) {
        prop.set( obj, arg );
        return;
    }

    rField field = obj.reflection().getField( mname.c_str );
    if ( field ) {
        field.set( obj, arg );
    }
}

/**
    Wrappers for "regular" string usage
*/
bool hasMethod( CObject obj, string mname ) { return hasMethod( obj, String( mname ) ); }
var call( Args... )( CObject obj, string mname, Args args ) { return call!Args( obj, String( mname ), args ); }
var get( CObject obj, string mname ) { return get( obj, String( mname ) ); }
void set( Arg )( CObject obj, string mname, Arg arg ) { return set!Arg( obj, String( mname ), arg ); }
