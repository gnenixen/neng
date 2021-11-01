module shell.rn_neng_back;

public:
import engine;

alias CShell = CGameShell;

class CGameScene : CObject {
    mixin( TRegisterClass!CGameScene );
public:
    CSceneTree tree;
    CSceneTreeRender render;

public:
    this() {
        tree = NewObject!CSceneTree();
        render = NewObject!CSceneTreeRender();
    }

    ~this() {
        DestroyObject( tree );
        DestroyObject( render );
    }
}

class CGame : CObject {
    mixin( TRegisterClass!CGame );
public:
    CShell shell;
    CGameModule mod;

    Dict!( CGameScene, String ) scenes;

    CGameScene currentScene;

    ~this() {
        foreach ( k, v; scenes ) {
            DestroyObject( v );
        }
    }
}

class CGameModule : CObject {
    mixin( TRegisterClass!CGameModule );
public:
    /**
        Called on initialization and nothing more
    */
    void initialize( CShell shell, CGame game ) {}

    /**
        Called on every scene begin play
    */
    void start( CShell shell, CGame game ) {}

    /**
        Called every frame
    */
    void update( CShell shell, CGame game, float delta ) {}
}

private {
    struct SSyncData {
        bool bUpdate = false;
        float delta = 0;
        float sleepTime = 0.0f;
        uint fps = 0;
    }

    class CSyncTimer {
    private:
        long llastTime;
        float ltargetDelta;

        float time = 0.0f;
        uint fps = 0;

    public:
        this( long initTime ) {
            llastTime = initTime;
        }

        SSyncData update( long currTime ) {
            SSyncData dt;

            float delta = (currTime - llastTime) / 1_000_000_000.0f;

            if ( time >= 1.0f ) {
                dt.fps = fps;
                time = 0.0f;
                fps = 0;
            }

            if ( delta >= ltargetDelta ) {    
                time += delta;
                fps++;

                dt.bUpdate = true;
                dt.delta = delta;

                llastTime = currTime;
            } else {
                dt.sleepTime = ltargetDelta - delta;
            }

            return dt;
        }

        void recalcFps( uint targetFps ) {
            if ( targetFps == 0 ) {
                ltargetDelta = 0.0f;
                return;
            }

            ltargetDelta = 1.0f / targetFps;
        }
    }
}

class CGameShell : CObject {
    mixin( TRegisterClass!CGameShell );
public:
    bool bWork = true;
    bool bPause = false;

    CConfig cfg;

    CWindow mwindow; // Main game window

    float time = 0.0f;

private:
    CSyncTimer sync;
    uint ltargetFps = 60;

public:
    this() {
        cfg = NewObject!CConfig();
    
        sync = allocate!CSyncTimer( OS.time_get() );
        sync.recalcFps( ltargetFps );
    }

    void run( CGameModule mod, CGame game ) {
        assert( mod );
        assert( game );

        setupMainWindow();

        mod.initialize( this, game );
        
        SSyncData sdata;

        while ( bWork ) {
            sdata = sync.update( OS.time_get() );
            if ( !sdata.bUpdate || bPause ) {
                OS.time_fdelay( sdata.sleepTime != 0.0f ? sdata.sleepTime : 0.5f );
                continue;
            }

            float delta = sdata.delta;

            time += delta;

            GEngine.update();
            GModules.update( delta );
            GFramework.update( delta );

            mod.update( this, game, delta );

            // Just for simetimes(check method info)
            RD.update( delta );
        }
    }

    @property {
        void targetFps( uint ival ) {
            ltargetFps = ival;
            sync.recalcFps( ltargetFps );
        }

        uint targetFps() => ltargetFps;
    }

protected:
    void setupMainWindow() {
        mwindow = GFramework.mwindow;

        mwindow.title = rs!"breach";

        mwindow.closed.connect( &mwindow_closed );
        mwindow.minimized.connect( &mwindow_minimized );
    }

    void mwindow_closed() { bWork = false; }

    /**
        Reduce cpu usage, when main window is minimized
    */
    void mwindow_minimized( bool bVal ) { bPause = bVal; }
}

static __gshared {
    void setupEngineEnv( string[] args ) {
        preInitEngine( args );        // Initialize engine basic systems
        registerSModules();     // Initialize shared modules
        initEngine();           // Initialize engine framework and modules
    }
}
