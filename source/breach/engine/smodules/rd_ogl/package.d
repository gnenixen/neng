module engine.smodules.rd_ogl;

public:
import engine.smodules.rd_ogl.render;

void rd_ogl__register() {
    import engine.core : GSymbolDB;
    import engine.modules.render_device : ARenderDevice;

    ARenderDevice.backend = GSymbolDB.register!COpenGLRD;
}

void rd_ogl__unregister() {}
