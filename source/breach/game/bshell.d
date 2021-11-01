module game.bshell;

import shell;

import game;

class CBreachGame : CGame {
    mixin( TRegisterClass!CBreachGame );
public:
    CFSM fsm;

    this() {
        fsm = NewObject!CFSM();
    }

    CGameState state() {
        return fsm.current!CGameState;
    }
}

class CBreachGameModule : CGameModule {
    mixin( TRegisterClass!CBreachGameModule );
private:
    float pAccumulator = 0.0f;

    CP2DDebugRenderBackRD lphysicsDebug;
    CImGUIRender limguiRender;
    CP2DWorld p2dworld;

    CR2D_View view;

public:
    override void initialize( CShell shell, CGame game ) {
        CBreachGame bgame = Cast!CBreachGame( game );
        assert( bgame );

        register_game();
        mountDefaultFS();
        setupBaseInput();

        p2dworld = NewObject!CP2DWorld();
        p2dworld.makeCurrent();

        lphysicsDebug = NewObject!CP2DDebugRenderBackRD();
        GPhysics2D.debug_setDrawBackend( lphysicsDebug );
        GPhysics2D.bDebugDraw = true;
        //GPhysics2D.bDebugDraw = false;
        limguiRender = NewObject!CImGUIRender();

        shell.targetFps = 60;

        bgame.fsm.addState!CGameState_Game( rs!"game" );
        bgame.fsm.addState!CTestState_NewRender( rs!"test_newRender" );

        //bgame.fsm.transition( "test_newRender" );
        bgame.fsm.transition( "game" );

        view = NewObject!CR2D_View( 1, 1 );

        //import engine.core.serialization;
        //CResource n = GResourceManager.load!CTextFile( "res/test.txt" );
        //WaitUntilResourceBeenLoaded( n );

        //CArchive archive = SArchivePacker.pack( n );
        //log.warning( archive.dump() );

        SDirRef dir = GFileSystem.dir( "res/game/dev_test" );
        Array!SFSEntry entries = dir.entries();
        Array!String spineResPaths;
        foreach ( entry; entries ) {
            if ( entry.path.isEndsWith( ".json" ) ) {
                spineResPaths ~= entry.path;
            }
        }

        foreach ( r; spineResPaths ) {
            log.error( r );
        }

        //DestroyObject( archive );
        //DestroyObject( n );
    }

    override void update( CShell shell, CGame game, float delta ) {
        CBreachGame bgame = Cast!CBreachGame( game );
        assert( bgame );

        CGameState state = bgame.state;
        if ( state ) {
            // Setup main world for this state
            p2dworld.makeCurrent();

            linput( shell, state );

            if ( !GConsole.bOpen ) {
                lphysics( state, delta );
                lupdate( state, delta );
            }

            lrender( shell, state, delta );
        }
    }

private:
    void mountDefaultFS() {
    }

    void setupBaseInput() {
        CIKeyboardEvent exit_key = CIKeyboardEvent.newReference( EKeyboard.ESCAPE );
        CIKeyboardEvent console_key = CIKeyboardEvent.newReference( EKeyboard.BACKSLASH );
        CIKeyboardEvent move_right_key = CIKeyboardEvent.newReference( EKeyboard.RIGHT );
        CIKeyboardEvent move_left_key = CIKeyboardEvent.newReference( EKeyboard.LEFT );
        CIKeyboardEvent attack_key = CIKeyboardEvent.newReference( EKeyboard.Z );
        CIKeyboardEvent jump_key = CIKeyboardEvent.newReference( EKeyboard.SPACE );
        CIKeyboardEvent block_key = CIKeyboardEvent.newReference( EKeyboard.SHIFT );
        CIKeyboardEvent dodge_key = CIKeyboardEvent.newReference( EKeyboard.V );
        CIKeyboardEvent r_key = CIKeyboardEvent.newReference( EKeyboard.R );

        GInput.action_add( "exit", EInputActionType.BUTTON );
        GInput.action_add( "console", EInputActionType.BUTTON );
        GInput.action_add( "r", EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.MOVE_RIGHT, EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.MOVE_LEFT, EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.ATTACK, EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.JUMP, EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.BLOCK, EInputActionType.BUTTON );
        GInput.action_add( EGameInputActions.DODGE, EInputActionType.BUTTON );

        GInput.action_addEvent( "exit", exit_key );
        GInput.action_addEvent( "console", console_key );
        GInput.action_addEvent( "r", r_key );
        GInput.action_addEvent( EGameInputActions.MOVE_RIGHT, move_right_key );
        GInput.action_addEvent( EGameInputActions.MOVE_LEFT, move_left_key );
        GInput.action_addEvent( EGameInputActions.ATTACK, attack_key );
        GInput.action_addEvent( EGameInputActions.JUMP, jump_key );
        GInput.action_addEvent( EGameInputActions.BLOCK, block_key );
        GInput.action_addEvent( EGameInputActions.DODGE, dodge_key );
    }

    void lphysics( CGameState state, float delta ) {
        enum TIME_STEP = 1.0f / 300.0f;

        float frameTime = Math.min( delta, 0.25f );
        pAccumulator += frameTime;

        state.ptick( delta );
        while ( pAccumulator >= TIME_STEP ) {
            GPhysics2D.update( TIME_STEP );
            pAccumulator -= TIME_STEP;
        }
        state.psync();

        GPhysics2D.postUpdate();
    }

    void linput( CShell shell, CGameState state ) {
        GImGUI.input( GInput.frameEvents() );

        foreach ( action; GInput.frameActions() ) {
            if ( action.isActionPressed( "exit" ) ) { shell.bWork = false; }
            if ( action.isActionPressed( "console" ) ) { GConsole.bOpen = !GConsole.bOpen; }
            if ( action.isActionPressed( "r" ) ) {
                
            }

            if ( !GConsole.bOpen ) {
                state.input( action );
            }
        }
    }

    void lupdate( CGameState state, float delta ) {
        state.tick( delta );
    }

    void lrender( CShell shell, CGameState state, float delta ) {
        CWindow win = shell.mwindow;

        view.resolution = win.size;

        GImGUI.newFrame( delta, win.width, win.height );
        GPhysics2D.debug_redraw();

        CR2D_View sview = state.render( SVec2I( 1920, 1080 ), delta );

        GConsole.render();

        GImGUI.endFrame();

        if ( sview ) {
            lphysicsDebug.render( sview );
        }

        GWindowCompositor.drawToFramebufferWithAspectRatio( view.framebuffer, sview.framebuffer );

        limguiRender.render( view );

        GWindowCompositor.drawToWindowInRect( win, view.framebuffer );
    }
}
