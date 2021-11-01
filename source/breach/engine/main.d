module engine.main;

import engine.core;
import engine.modules;
import engine.framework;
import engine.os;

/**
    Initialize only basic engine functionality and mount
    resource file directory as "res" filesystem root,
    in real sense THIS IS RN_NENG, other functionality
    is more and more abstraction layers.

    Engine not require render for correct work:/
    Engine not require physics for correct work
    Input can be refused in some games, and some
    programmers can realize better logic than
    we already have.

    THIS IS NAMLESS ENGINE initializer, nothing more.

    Anything upper than this call is custom logic, not
    original RN_NENG.

    RN_NENG is just a game engine core, anything upper
    is YOUR engine:)
*/
void preInitEngine( string[] args ) {
    void initResourcesFS() {
        AFSBackend back = OS.fs_get( String( OS.env_get( "exec/path" ), "/resources" ) );
        
        if ( !back ) {
            log.warning( "Canno't find resources directory for engine, please mount it by hand" );
            return;
        }

        GFileSystem.mount( "res", back );
    }

    preInitLowLevelSystems();   // Setup basic crash handlers and other
    preInitCore();              // Init memory, log and ClassDB
    initOS();                   // Init os backend

    // Configure engine config
    SGEngineConfig cfg;

    foreach ( i, arg; args ) {
        if ( i == 0 ) continue;

        if ( arg == "-bDisableThreadPool" ) {
            cfg.bDisableThreadPool = true;
        } else {
            log.error( "Unsupported param: ", arg );
        }
    }

    initCore( cfg );            // Init cfg, fs, resource manager, object pool

    initResourcesFS();

    log.info( "Engine pre initialized correctly" );
}

void initEngine() {
    log.info( "Engine init begin" );

    GModules.registerStaticModules();
    log.info( "Static modules registered" );
    
    GModules.initialize( EModuleInitPhase.PRE );
        preInitializeFramework();
    GModules.initialize( EModuleInitPhase.NORMAL );
        initializeFramework();
    GModules.initialize( EModuleInitPhase.POST );
    

    log.info( "Engine initialized" );
    
    /*cfg.set( "engine/fps", 0 );
    cfg.set( "engine/target_fps", 60 );

    cfg.set( "engine/modules/render/rd_backend_class", "smodules.render_ogl.render.COpenGLRD", true );
    cfg.set( "engine/modules/physics_2d/backend_class", "smodules.box2d_physics.world.b2CPhysWorld", true );
    cfg.set( "engine/modules/scripting/backend_class", "smodules.lua_script.scr_lang.CLuaScriptLanguage", true );

    // Default panic handler setup
    GEngine.PANIC_HANDLER = ( string msg ) { GDisplayServer.message( "Engine error!", msg ); };

    initFS();

    CWindow win = newObject!CWindow( "rn_neng", 10, 10, 800, 600 );
    win.createContext();
    win.makeContextCurrent();
    cfg.set( "mainWindowId", win.id, true );

    GModules.initialize( EModuleInitPhase.NORMAL );
    
    GFramework.initialize();
    GSceneTree.initialize();

    GModules.initialize( EModuleInitPhase.POST );
    
    log.info( "Engine initialized" );*/
}

void destroyEngine() {
    /*GFramework.destruct();
    GModules.destruct();
    destroyCore();
    destroyOS();

    log.info( SMSGConst.SHUTDOWN_MEM_LOG );
    log.info( "Allocated memory at exit: ", Memory.allocatedMemory );
    log.info( "Unfree allocations count: ", Memory.allocationsCount );*/
}

void initFS() {
    /*string execPath = OS.env_get( "exec/path" );

    CDiskDir drivers = allocate!CDiskDir( "drivers", execPath ~ "/drivers" );
    CDiskDir resources = allocate!CDiskDir( "resources", execPath ~ "/resources" );

    GFileSystem.addRoot( drivers );
    GFileSystem.addRoot( resources );*/

    //CDiskFS _resources = newObject!CDiskFS( String( execPath, "/resources" ) );
    //_GFileSystem.mount( String( "resources" ), _resources );
}
