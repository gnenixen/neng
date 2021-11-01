module engine.modules.sound;

public:
import engine.modules.sound.server;
import engine.modules.sound.resource;

private {
    import engine.core.symboldb;
    import engine.core.resource;

    import engine.modules.module_decl;
}

class CMD_sound : AModuleDeclaration {
    mixin( TRegisterClass!CMD_sound );
public:
    this() {
        name = "Sound";
        initPhase = EModuleInitPhase.NORMAL;
    }

    override void initialize() {
        assert( ASoundServer.backend );

        newObjectR!ASoundServer( ASoundServer.backend );

        GResourceManager.register( NewObject!CSoundOperator );
    }

    override void update( float delta ) {
        GSoundServer.update();
    }
}
