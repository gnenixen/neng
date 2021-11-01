module engine.modules.display_server;

public:
import engine.modules.display_server.server;

private {
    import engine.core.symboldb;

    import engine.modules.module_decl;
}

class CMD_display_server : AModuleDeclaration {
    mixin( TRegisterClass!CMD_display_server );
public:
    this() {
        name = "DisplayServer";
        initPhase = EModuleInitPhase.PRE;
    }

    override void initialize() {
        //GSymbolDB.register!ADisplayServer;

        assert( ADisplayServer.backend );

        newObjectR!ADisplayServer( ADisplayServer.backend );
        GDisplayServer.input_init();
    }

    override void update( float delta ) {
        GDisplayServer.update( delta );
    }
}
