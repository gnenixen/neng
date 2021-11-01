module engine.framework;

public:
import engine.framework._debug;
import engine.framework.bt;
import engine.framework.imgui;
import engine.framework.input;
import engine.framework.resources;
import engine.framework.render;
import engine.framework.scene_tree;

import engine.framework.astar;
import engine.framework.console;
import engine.framework.fsm;
import engine.framework.postprocess;
import engine.framework.pathfinder;
import engine.framework.window;
import engine.framework.spine;

private {
    import engine.core.symboldb;
}

static __gshared struct GFramework {
static:
    CWindow mwindow;

    void update( float delta ) {
        GInput.update();
    }
}

void preInitializeFramework() {
    import engine.core.object;

    GSymbolDB.register!CP2DDebugRenderBackRD;

    GSymbolDB.register!CWindow;
    GSymbolDB.register!CInput;
    GSymbolDB.register!CImGUI;
    GSymbolDB.register!CConsole;

    GFramework.mwindow = NewObject!CWindow( String( "rn_neng" ), 0, 0, 1280, 720 );
    GFramework.mwindow.createContext();
    GFramework.mwindow.makeContextCurrent();

    _spine_initialize();
    GSceneTree.initialize();

    log.info( "Framework pre initialized" );
}

void initializeFramework() {
    import engine.core.resource;
    import engine.modules.sound;

    SLowLevelRender.initialize();

    GSoundServer.initialize( 512 );

    GSymbolDB.register!CWindowCompositor;

    GResourceManager.register( NewObject!CSpineResourceOperator() );

    log.info( "Framework initialized" );
}
