module engine.modules.render_device;

public:
import engine.modules.render_device.render_device;
import engine.modules.render_device.texture;
import engine.modules.render_device.util;

private {
    import engine.core.config;
    import engine.core.symboldb;
    import engine.core.resource;
    import engine.modules.module_decl;
}

class CMD_render_device : AModuleDeclaration {
    mixin( TRegisterClass!CMD_render_device );
public:
    this() {
        name = "RenderDevice";
        initPhase = EModuleInitPhase.NORMAL;
    }

    override void initialize() {
        GSymbolDB.register!ERDBufferType;
        GSymbolDB.register!ERDBufferUpdate;
        GSymbolDB.register!ERDCompare;
        GSymbolDB.register!ERDDrawIndicesType;
        GSymbolDB.register!ERDFace;
        GSymbolDB.register!ERDPrimitiveType;
        GSymbolDB.register!ERDRasterMode;
        GSymbolDB.register!ERDShaderType;
        GSymbolDB.register!ERDStencilAction;
        GSymbolDB.register!ERDTextureDataFormat;
        GSymbolDB.register!ERDTextureType;
        GSymbolDB.register!ERDWinding;

        //GSymbolDB.register!ARenderDevice;

        assert( ARenderDevice.backend, "Invalid render device backend class!" );

        newObjectR( ARenderDevice.backend );

        GResourceManager.register( NewObject!CTextureOperator );
    }
}
