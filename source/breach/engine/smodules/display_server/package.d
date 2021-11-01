module engine.smodules.display_server;

public:

void display_server__register() {
    import engine.core : GSymbolDB;
    import engine.modules.display_server : ADisplayServer;
    
    version( linux ) {
        import engine.smodules.display_server.x11 : CX11DisplayServer;

        ADisplayServer.backend = GSymbolDB.register!CX11DisplayServer;
    }

    version( Windows ) {
        import engine.smodules.display_server.win;

        ADisplayServer.backend = GSymbolDB.register!CWinDisplayServer;
    }
}

void display_server__unregister() {}
