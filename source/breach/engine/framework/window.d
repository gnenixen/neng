module engine.framework.window;

import engine.core.object;
import engine.core.signal;
import engine.core.callable;

import engine.modules.display_server;

class CWindow : CObject {
    mixin( TRegisterClass!CWindow );
public:
    Signal!() closed;
    Signal!( bool ) minimized;
    Signal!( bool ) focused;
    Signal!( String ) rename;
    Signal!( SVec2I ) move;
    Signal!( SVec2I ) resize;

protected:
    ID winId = ID_INVALID;
    ID contextID = ID_INVALID;

public:
    this() {}

    this( String ititle, uint posx, uint posy, uint width, uint height ) {
        winId = GDisplayServer.window_create( ititle, posx, posy, width, height );
    }

    ~this() {
        GDisplayServer.destroy( winId );

        closed.disconnectAll();
        minimized.disconnectAll();
        focused.disconnectAll();
        rename.disconnectAll();
        move.disconnectAll();
        resize.disconnectAll();
    }

    override void postInit() {
        GDisplayServer.window_setEventCallback( winId, SCallable( rs!"winEventHandler", id ) );
    }

    void setup( String ititle, uint posx, uint posy, uint width, uint height ) {
        assert( winId == ID_INVALID );

        winId = GDisplayServer.window_create( ititle, posx, posy, width, height );
        GDisplayServer.window_setEventCallback( winId, SCallable( rs!"winEventHandler", id ) );
    }

    //TODO: Write normal logic
    void makeContextCurrent() {
        renderContext = contextID;
    }

    void createContext() {
        contextID = GDisplayServer.rc_create();
    }

    void swapBuffers() {
        GDisplayServer.window_swapBuffers( winId );
    }

    SVec2I toWindowCoords( SVec2I ipos ) {
        return position - ipos;
    }

    @property pragma( inline, true ) {
        bool bIsFocused() {
            return GDisplayServer.window_isFocused( winId );
        }

        void bIsFocused( bool bVal ) {
            GDisplayServer.window_setFocused( winId, bVal );
            focused.emit( bVal );
        }

        bool bIsMinimized() {
            return GDisplayServer.window_isMinimized( winId );
        }

        void bIsMinimized( bool bVal ) {
            GDisplayServer.window_setMinimized( winId, bVal );
            minimized.emit( bVal );
        }

        SVec2I position() {
            return GDisplayServer.window_getPos( winId );
        }

        String title() {
            return GDisplayServer.window_getTitle( winId );
        }

        void title( String ititle ) {
            GDisplayServer.window_setTitle( winId, ititle );
            rename.emit( title );
        }

        void position( SVec2I ipos ) {
            GDisplayServer.window_setPos( winId, ipos );
            move.emit( ipos );
        }

        SVec2I size() {
            return GDisplayServer.window_getSize( winId );
        }

        void size( SVec2I isize ) {
            GDisplayServer.window_setSize( winId, isize );
            resize.emit( isize );
        }

        uint width() {
            return GDisplayServer.window_getSize( winId ).x;
        }

        void width( uint val ) {
            SVec2I winSize = GDisplayServer.window_getSize( winId );
            winSize.x = val;

            GDisplayServer.window_setSize( winId, winSize );
            resize.emit( winSize );
        }

        uint height() {
            return GDisplayServer.window_getSize( winId ).y;
        }

        void height( uint val ) {
            SVec2I winSize = GDisplayServer.window_getSize( winId );
            winSize.y = val;

            GDisplayServer.window_setSize( winId, winSize );
            resize.emit( winSize );
        }

        ID renderContext() {
            return GDisplayServer.window_getContext( winId );
        }

        void renderContext( ID id ) {
            GDisplayServer.window_setContext( winId, contextID );
        }
    }

protected:
    void winEventHandler( EDSWindowEvent event, SVariant data ) {
        switch ( event ) {
        case EDSWindowEvent.CLOSED:
            closed.emit();
            break;
        case EDSWindowEvent.RESIZE:
            resize.emit( data.as!SVec2I );
            break;
        case EDSWindowEvent.MOVE:
            move.emit( data.as!SVec2I );
            break;
        default:
            break;
        }
    }

public:
    this( string ititle, uint posx, uint posy, uint width, uint height ) {
        winId = GDisplayServer.window_create( String( ititle ), posx, posy, width, height );
    }
}
