module engine.modules.display_server.server;

public {
    import engine.core.math.vec;
    import engine.core.containers.array;
    import engine.core.object;
    import engine.core.signal;
    import engine.core.callable;
    import engine.core.input;
}

enum EDSWindowEvent {
    CLOSED,
    FOCUSED,
    MINIMIZED,
    RENAME,
    RESIZE,
    MOVE,
}

enum EDSMessageButtons {
    OK = 0,

}

struct SMonitorInfo {
    SVec2I pos;
    SVec2I size;
    float dpi;
}

abstract class ADisplayServer : CObject {
    mixin( TRegisterClass!( ADisplayServer, SingletonBackendable ) );
public:
    static CRSClass backend;

    Signal!( ulong ) windowsNumUpdated;

    ~this() {
        windowsNumUpdated.disconnectAll();
    }

    void update( float delta );
    void destroy( ID id );

    void input_init();

    /*********** WINDOWS ***********/
    ID window_create( String title, uint posx, uint posy, uint width, uint height );
    void window_setEventCallback( ID win, SCallable callable );

    bool window_isMinimized( ID id );
    void window_setMinimized( ID id, bool bVal );

    bool window_isFocused( ID id );
    void window_setFocused( ID id, bool bVal );

    SVec2I window_getPos( ID id );
    void window_setPos( ID id, SVec2I pos );

    SVec2I window_getSize( ID id );
    void window_setSize( ID id, SVec2I size );

    String window_getTitle( ID id );
    void window_setTitle( ID id, String title );

    void message( String title, String text, ushort flags = 0 );

    /*********** MONITORS ***********/
    int monitor_count();
    SMonitorInfo monitor_getInfo( uint idx );

    /*********** RENDER ***********/
    ID rc_create();

    ID window_getContext( ID win );
    void window_setContext( ID win, ID context );
    void window_swapBuffers( ID win );
}

pragma( inline, true ):
static __gshared ADisplayServer GDisplayServer() {
    return ADisplayServer.sig;
}
