module engine.framework.scene_tree.base.main_loop;

import engine.core.object;
//import engine.core.main_loop;
import engine.core.gengine;

import engine.modules;

import engine.framework.imgui;

import engine.framework.scene_tree.base.tree;
import engine.framework.scene_tree.base.node;
import engine.framework.scene_tree.base.render;
/*
class CSceneTreeMainLoop : IMainLoop {
    enum TIME_STEP = 1.0f / 300.0f;

public:
    CSceneTree tree;

private:
    bool bWork = true;

    CWindow win;

    CSceneTreeRender render;

    float accumulator = 0.0f;

public:
    this() {
        win = getObjectByID!CWindow( cfg.get!ID( "mainWindowId" ) );
        assert( win );

        GDisplayServer.windowsNumUpdated.connect( &lwinNumUpdate );

        tree = newObject!CSceneTree();
        render = newObject!CSceneTreeRender();
    }
    
    EMainLoopSignals update( float delta ) {
        // To first update display server
        if ( !bWork ) { return EMainLoopSignals.EXIT; }
        
        GModules.tick( delta );

        // Process nodes messages
        lphysics( delta );
        linput();
        lupdate( delta );

        // Rendering
        {
            GImGUI.newFrame( delta, win.width, win.height );
            GPhysics2D.debug_redraw();
            lrender();
            debug debugInfo( delta );
            GImGUI.endFrame();
        }


        // Draw main camera into screen
        CRender2D_View mainView = render.render().get( "main", null );
        if ( isValid( mainView ) ) {
            if ( win.size.x > 0 && win.size.y > 0 ) {
                mainView.resolution = win.size();
            }

            debug render.debugRender( mainView );
            GWindowCompositor.drawToWindowInRect( win, mainView.framebuffer );
        }

        return EMainLoopSignals.NONE;
    }

private:
        //1) Send updates from scene tree to physics
           //backend in ptick
        //2) Update physics backend
        //3) Synchronize updates with scene tree in psync
    void lphysics( float delta ) {
        float frameTime = Math.min( delta, 0.25f );
        accumulator += frameTime;

        tree.message( ENodeMessageType.PHYSICS_TICK, "", delta );
        while ( accumulator >= TIME_STEP ) {
            GPhysics2D.update( TIME_STEP );
            accumulator -= TIME_STEP;
        }
        tree.message( ENodeMessageType.PHYSICS_SYNC, "" );
    }

    void lrender() { tree.message( ENodeMessageType.RENDER, "", render ); }
    
    void linput() {
        GInput.makeFrameInputQueue();
        
        SInputEvent ie;
        while ( ( ie = GInput.pop() ).type != "null" ) {
            if ( SIMKeyboard.check( ie ) ) {
                SIMKeyboard.SEvent event = SIMKeyboard.get( ie );

                if ( event.isDown() ) {
                    if ( event.key == EKeyboard.K_DELETE ) {
                        destroyObject( win );
                    }
                }
            }

            GImGUI.input( ie );
            tree.message( ENodeMessageType.INPUT, "", ie );
        }
    }

    void lupdate( float delta ) { tree.message( ENodeMessageType.TICK, "", delta ); }

    void lwinNumUpdate( ulong num ) {
        bWork = num > 0;
    }

    void debugInfo( float delta ) {
        GImGUI.setNextWindowPos( SVec2I( 0, 0 ), EImGUICond.FIRST_START );
        if ( GImGUI.begin( "info", null,
            EImGUIWinFlags.NO_TITLE_BAR |
            EImGUIWinFlags.NO_RESIZE |
            EImGUIWinFlags.NO_MOVE |
            EImGUIWinFlags.NO_SAVED_SETTINGS
        ) ) {
            GImGUI.text( TEXT( "FPS: ", cfg.get!int( "engine/fps" ) ) );
            GImGUI.text( TEXT( "Delta: ", Math.round( delta * 10000 ) / 10000 ) );
            GImGUI.text( TEXT( "Allocated mem(MB): ", Math.round( (Memory.allocatedMemory / 1024.0f / 1024.0f) * 100 ) / 100 ) );
            GImGUI.text( TEXT( "Allocations count: ", Memory.allocationsCount ) );

            bool bDrawPhys2D = GPhysics2D.bDebugDraw;
                GImGUI.checkbox( "Debug draw", &bDrawPhys2D );
            GPhysics2D.bDebugDraw = bDrawPhys2D;

            // HACK
            if ( GImGUI.button( "Restart" ) ) {
                import main;

                destroyObject( tree.root );
                tree.root = setupWorld();
                log.info( "Reloaded" );
                render.clear();
            }

            GImGUI.separator();
            GImGUI.text( "Input:\n A/D - movement\n Space - jump\n Right arrow - attack" );
        }
        GImGUI.end();
    }
}*/
