module engine.smodules.fmod;

public:
import engine.smodules.fmod.server;

void fmod__register() {
    import engine.core : GSymbolDB;
    import engine.modules.sound : ASoundServer;

    ASoundServer.backend = GSymbolDB.register!CFMODSoundServer;
}

void fmod__unregister() {}
