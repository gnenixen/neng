module engine.core;

public:
import engine.core.containers;
import engine.core.math;
import engine.core.fs;
import engine.core.input;
import engine.core.memory;
import engine.core.object;
import engine.core.os;
import engine.core.resource;
import engine.core.templates;
import engine.core.utils;

import engine.core.bitflags;
import engine.core.callable;
import engine.core.config;
import engine.core.define;
import engine.core.error;
import engine.core.eversion;
import engine.core.gengine;
import engine.core.log;
import engine.core.ref_count;
import engine.core.reference;
import engine.core.reflection;
import engine.core.script_language;
//import engine.core.serialization;
import engine.core.signal;
import engine.core.spin_lock;
import engine.core.string;
import engine.core.symboldb;
import engine.core.thread_pool;
import engine.core.timer;
import engine.core.typedefs;
import engine.core.variant;

void preInitCore() {
    Memory.initialize( CAllocator );
    GEngine.preInititialize();

    {
        import engine.core.utils.console_logger;
        log.addLogger( allocate!CConsoleLogger() );
    }

    log.info( "Memory initialized" );
    log.info( "Core preinitialized" );
}

void initCore( SGEngineConfig cfg = SGEngineConfig() ) {
    GSymbolDB.register!CObject;
    GSymbolDB.register!CObjectIdHandler;
    GSymbolDB.register!CVoidPtrObject;
    
    GSymbolDB.register!AMutexImpl;
    GSymbolDB.register!AThreadImpl;
    GSymbolDB.register!ASempahoreImpl;
    GSymbolDB.register!CMutex;
    GSymbolDB.register!CThread;
    //GSymbolDB.register!AOS;

    GSymbolDB.register!AInputBackend;
    GSymbolDB.register!AInputDevice;
    GSymbolDB.register!AInputState;
    GSymbolDB.register!AInputEvent;
    {
        GSymbolDB.register!CIKeyboard;
        GSymbolDB.register!CIKeyboardEvent;
        GSymbolDB.register!CIKeyboardState;
    }

    GSymbolDB.register!CThreadPool;

    //GSymbolDB.register!AFSBackend;
    GSymbolDB.register!CFileSystem;
    //GSymbolDB.register!CFile;
    //GSymbolDB.register!CDir;

    GSymbolDB.register!CResourceManager;
    {
        GSymbolDB.register!CTextFile;
        GSymbolDB.register!CTextFileOperator;
    }

    GSymbolDB.register!SVec2I( "SVec2I" );
    GSymbolDB.register!SVec2U( "SVec2U" );
    GSymbolDB.register!SVec2D( "SVec2D" );
    GSymbolDB.register!SVec2L( "SVec2L" );
    GSymbolDB.register!SVec2F( "SVec2F" );

    GSymbolDB.register!SVec3I( "SVec3I" );
    GSymbolDB.register!SVec3U( "SVec3U" );
    GSymbolDB.register!SVec3D( "SVec3D" );
    GSymbolDB.register!SVec3L( "SVec3L" );
    GSymbolDB.register!SVec3F( "SVec3F" );

    GSymbolDB.register!SVec4I( "SVec4I" );
    GSymbolDB.register!SVec4U( "SVec4U" );
    GSymbolDB.register!SVec4D( "SVec4D" );
    GSymbolDB.register!SVec4L( "SVec4L" );
    GSymbolDB.register!SVec4F( "SVec4F" );

    assert( Mutex.backend, "Invalid mutex backend class!" );
    assert( Thread.backend, "Invalid thread backend class!" );

    GEngine.initialize( cfg );

    GResourceManager.register( NewObject!CTextFileOperator() );

    struct SVar {
        int x = 200;
    }

    {
    import engine.core._variant;
    _SVariant te;
    te = Array!int( 10, 20 );
    log.warning( (cast( Array!int )te).length );
    //log.warning( cast( int )te );

    }
    

   

    log.error( Memory.allocationsCount );
    {
    import engine.core._reflection;
    import engine.core._variant;
    CReflectionBuilder builder = allocate!CReflectionBuilder();
    CTest test = allocate!CTest();
    _SVariant vtest = _SVariant( test );
    //test.reflect( builder );
    CReflectionTypeDescriptor descr = builder.build();

    //log.warning( vtest.typeinfo );

    CReflectionField field = descr.field( "ar" );
    if ( field ) {
        CReflectionMethod method = field.type.method( "f" );
        //log.warning( method );
        method.invoke( field.get( vtest ), 10 );
    }
    field = descr.field( "a" );
    if ( field ) {
        CReflectionMethod method = field.type.method( "varray" );

        Array!_SVariant array = method.invoke( field.get( _SVariant( test ) ) ).as!( Array!_SVariant );
        array = method.invoke( field.get( _SVariant( test ) ) ).as!( Array!_SVariant );
        array = method.invoke( field.get( _SVariant( test ) ) ).as!( Array!_SVariant );
        array = method.invoke( field.get( _SVariant( test ) ) ).as!( Array!_SVariant );
        array = method.invoke( field.get( _SVariant( test ) ) ).as!( Array!_SVariant );
        //log.warning( array.length );
    }
    //log.warning( field );

    deallocate( test );
    deallocate( builder );
    deallocate( descr );
    }
    log.error( Memory.allocationsCount );

    log.info( "Core initialized" );
}

void destroyCore() {
    GEngine.destruct();
}
