module engine.smodules.display_server.x11.display_server;

version( linux ):
import engine.thirdparty.x11.X;
import engine.thirdparty.x11.Xlib;
import engine.thirdparty.x11.Xutil;
import engine.thirdparty.x11.Xtos;

import engine.thirdparty.bindings.glx.glx;

import engine.core.memory : allocate, deallocate;
import engine.core.log : log;
import engine.core.string;

import engine.modules.display_server;

//import smodules.display_server.x11.input_map;
import engine.smodules.display_server.x11.input;

private {
    enum GLX_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
    enum GLX_CONTEXT_MINOR_VERSION_ARB = 0x2092;

    /*enum int[] ATTRS = [
        4,
        8, 1,
        9, 1,
        10, 1,
        5,
        12, 1,
        0
    ];*/

    enum int[] ATTRS = [
        0x8011, 0x00000001,
        0x8010, 0x00000001,
        5, true,
        8, 1,
        9, 1,
        10, 1,
        12, 24,
        None
    ];

    enum int[] GL3_ATTRS = [
        GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
        GLX_CONTEXT_MINOR_VERSION_ARB, 2,
        0x9126, 0x00000001,
        0x2094, 0x00000002,
        None
    ];

    enum uint INPUT_MASK = 
        ExposureMask |
        FocusChangeMask |
        KeyPressMask |
        KeyReleaseMask |
        PointerMotionMask |
        ButtonPressMask |
        ButtonReleaseMask |
        StructureNotifyMask;

    class CX11WinData : CObject {
        mixin( TRegisterClass!CX11WinData );
    public:
        Display* x11Dsp;
        Window x11Win;

        CX11GLXRenderContext context;

        String title;

        bool bMinimized;
        bool bFocused;

        SVec2I cachePos;
        SVec2I cacheSize;

        SCallable eventsCallback;

        this() {
            windowsCount++;
            GDisplayServer.windowsNumUpdated.emit( windowsCount );
        }

        ~this() {
            if ( context ) {
                destroyObject( context );
            }

            XDestroyWindow( x11Dsp, x11Win );
            windowsCount--;
            GDisplayServer.windowsNumUpdated.emit( windowsCount );

            log.info( "Windows closed: ", title );
        }
    }

    class CX11GLXRenderContext : CObject {
        mixin( TRegisterClass!CX11GLXRenderContext );
    public:
        Display* x11Dsp;
        void* glxGlc;

        ~this() {
            if ( glxGlc ) {
                glXDestroyContext( cast( void* )x11Dsp, glxGlc );
            }
        }
    }

    template TGetWindowData( string ret = "" ) {
        enum TGetWindowData = "
            CX11WinData data = getObjectByID!CX11WinData( id );
            if ( !data ) {
                return " ~ ret ~ ";
            }
        ";
    }

    extern( C ) int _x11_errorHandler( Display* dsp, XErrorEvent* event ) {
        import std.string : format;

        char[256] errorDescription;
        XGetErrorText( dsp, event.error_code, errorDescription.ptr, errorDescription.sizeof );

        assert( false,
            format(
                "X11 Display server error:\n" ~
                "Handled X error on display %1$s:\n" ~
                "error = %2$s (%3$s)\n" ~
                "major = %4$s\n" ~
                "minor = %5$s\n",
                dsp,
                event.error_code,
                errorDescription,
                event.request_code,
                event.minor_code
            )
        );
    }

    uint windowsCount = 0;
}

class CX11DisplayServer : ADisplayServer {
    mixin( TRegisterClass!CX11DisplayServer );
protected:
    Display* dsp;
    XVisualInfo* vi;
    void* fbcfg;
    int screensCount;
    int defaultScreen;
    ulong blackColor;
    ulong whiteColor;

    Atom WM_DELETE_WINDOW;

    Array!CX11WinData windows;
    CX11InputBackend input;

    ulong mouseWheel = 0;

public:
    this() {
        XSetErrorHandler( &_x11_errorHandler );
        XInitThreads();
        _c_initializeGLX();

        dsp = XOpenDisplay( null );
        if ( !dsp ) {
            throw new Exception( "Cannot open display.\n" );
        }

        screensCount = ScreenCount( dsp );
        defaultScreen = DefaultScreen( dsp );
        blackColor = BlackPixel( dsp, defaultScreen );
        whiteColor = BlackPixel( dsp, defaultScreen );

        WM_DELETE_WINDOW = XInternAtom( dsp, "WM_DELETE_WINDOW", false );

        int elemc;
        fbcfg = glXChooseFBConfig( cast( void* )dsp, defaultScreen, ATTRS.ptr, &elemc );
        assert( fbcfg );
    }

    ~this() {
        XCloseDisplay( dsp );
    }

    @NoReflection
    void processEvent( XEvent event, CX11WinData data ) {
        switch ( event.type ) {
        case ClientMessage:
            if ( event.xclient.data.l[0] == WM_DELETE_WINDOW ) {
                sendWindowEvent( data, EDSWindowEvent.CLOSED, var( null ) );
                GDisplayServer.destroy( data.id );
            }
            break;
        case FocusIn:
            data.bFocused = true;
            break;
        case FocusOut:
            data.bFocused = false;
            break;
        case ConfigureNotify:
            SVec2I nSize = SVec2I( event.xconfigure.width, event.xconfigure.height );
            if ( data.cacheSize != nSize ) {
                sendWindowEvent( data, EDSWindowEvent.RESIZE, SVariant( nSize ) );
                data.cacheSize = nSize;
                break;
            }
            
            SVec2I nPos = SVec2I( event.xconfigure.x, event.xconfigure.y );
            if ( data.cachePos != nPos ) {
                sendWindowEvent( data, EDSWindowEvent.MOVE, SVariant( nPos ) );
                data.cachePos = nPos;
            }
            break;
        default:
            break;
        }
    }

    void sendWindowEvent( CX11WinData win, EDSWindowEvent event, SVariant data ) {
        if ( !win.eventsCallback.isNull() ) {
            win.eventsCallback.call( event, data );
        }
    }

override:
    void update( float delta ) {
        input.clearQueue();

        while ( XPending( dsp ) > 0 ) {
            XEvent event;
            XNextEvent( dsp, &event );

            CX11WinData data = null;
            foreach ( win; windows ) {
                if ( event.xany.window == win.x11Win ) {
                    data = win;
                    break;
                }
            }

            if ( XFilterEvent( &event, None ) || !isValid( data ) ) {
                continue;
            }

            processEvent( event, data );
            input.processEvent( event );
        }
    }

    void destroy( ID id ) {
        destroyObject( id );
    }

    void input_init() {
        import engine.core : GSymbolDB;
        import engine.smodules.display_server.x11.input : CX11InputBackend;

        GSymbolDB.register!CX11InputBackend;
        input = newObject!CX11InputBackend( dsp );
    }

    /*********** WINDOWS ***********/
    ID window_create( String title, uint posx, uint posy, uint width, uint height ) {
        CX11WinData data = newObject!CX11WinData();
        
        data.x11Dsp = dsp;
        data.x11Win = XCreateSimpleWindow(
            dsp,
            RootWindow( dsp, defaultScreen ),
            posx, posy,
            width, height,
            1,
            blackColor,
            whiteColor
        );

        data.title = title;

        data.cachePos = SVec2I( posx, posy );
        data.cacheSize = SVec2I( width, height );

        XSelectInput( dsp, data.x11Win, INPUT_MASK );
        XMapWindow( dsp, data.x11Win );
        XClearWindow( dsp, data.x11Win );
        XStoreName( dsp, data.x11Win, cast( char* )title.opCast!char.toString() );

        XSetWMProtocols( dsp, data.x11Win, &WM_DELETE_WINDOW, 1 );

        //Wait for the MapNotify event
        while ( 1 ) {
            XEvent ev;
            XNextEvent( dsp, &ev );
            if ( ev.type == MapNotify ) {
                break;
            }
        }

        XFlush( dsp );

        windows ~= data;

        log.info( "Window created: ", title );

        return data.id;
    }

    void window_setEventCallback( ID id, SCallable callable ) {
        mixin( TGetWindowData!() );
        data.eventsCallback = callable;
    }
    
    bool window_isMinimized( ID id ) {
        mixin( TGetWindowData!( "false" ) );
        return data.bMinimized;
    }

    void window_setMinimized( ID id, bool bVal ) {
        mixin( TGetWindowData!() );
        data.bMinimized = bVal;

        if ( !bVal ) {
            XIconifyWindow( dsp, data.x11Win, defaultScreen );
        } else {
            XMapRaised( dsp, data.x11Win );
        }
    }

    bool window_isFocused( ID id ) {
        mixin( TGetWindowData!( "false" ) );
        return data.bFocused;
    }

    void window_setFocused( ID id, bool bVal ) {
        mixin( TGetWindowData!() );
        data.bFocused = bVal;

        XSetInputFocus( dsp, data.x11Win, RevertToNone, CurrentTime );
    }

    SVec2I window_getPos( ID id ) {
        mixin( TGetWindowData!( "SVec2I( -1 )" ) );
        return data.cachePos;
    }

    void window_setPos( ID id, SVec2I pos ) {
        mixin( TGetWindowData!() );
        XMoveWindow( dsp, data.x11Win, pos.x, pos.y );
        XFlush( dsp );
    }

    SVec2I window_getSize( ID id ) {
        mixin( TGetWindowData!( "SVec2I( -1 )" ) );
        return data.cacheSize;
    }

    void window_setSize( ID id, SVec2I size ) {
        mixin( TGetWindowData!() );
        XResizeWindow( dsp, data.x11Win, size.x, size.y );
        XFlush( dsp );
    }

    String window_getTitle( ID id ) {
        mixin( TGetWindowData!( "String()" ) );
        return data.title;
    }

    void window_setTitle( ID id, String title ) {
        mixin( TGetWindowData!() );
        XStoreName( dsp, data.x11Win, cast( char* )title.opCast!char.toString() );
        XFlush( dsp );
    }

    void message( String title, String text, ushort flags ) {
        /*Window win = XCreateSimpleWindow( dsp, RootWindow( dsp, defaultScreen ), 0, 0, 800, 100, 1, 
            blackColor, whiteColor );
        
        XSelectInput( dsp, win, ExposureMask | PointerMotionMask | ButtonPressMask | ButtonReleaseMask );
        XMapWindow( dsp, win );

        Atom _WM_DELETE_WINDOW = XInternAtom( dpy, "WM_DELETE_WINDOW", False );
        XSetWMProtocols( dsp, win, &_WM_DELETE_WINDOW, 1 );

        XGCValues gcValues;
        gcValues.font = XLoadFond( dsp, "7x13" );
        gcValues.foreground = BlackPixel( dsp, 0 );
        GC textGC = XCreateGC( dsp, win, GCFond + GCForeground, &gcValues );
        XUnmapWindow( dsp, win );

        //

        Colormap cmap = DefaultColormap( dsp, ds );

        uint winW, winH;
        uint textW, textH;
        */
    }

    /*********** MONITORS ***********/
    int monitor_count() {
        return screensCount;
    }

    SMonitorInfo monitor_getInfo( uint idx ) {
        if ( idx > screensCount ) {
            return SMonitorInfo();
        }

        return SMonitorInfo();
    }

    /*********** RENDER ***********/
    ID rc_create() {
        CX11GLXRenderContext ctx = newObject!CX11GLXRenderContext();
        ctx.x11Dsp = dsp;
        ctx.glxGlc = glXCreateContextAttribsARB( cast( void* )dsp, fbcfg, null, 1, GL3_ATTRS.ptr );
        return ctx.id;
    }

    ID window_getContext( ID id ) {
        mixin( TGetWindowData!( "ID_INVALID" ) );
        if ( data.context ) {
            return data.context.id;
        }

        return ID_INVALID;
    }

    void window_setContext( ID id, ID context ) {
        mixin( TGetWindowData!() );

        CX11GLXRenderContext ctx = getObjectByID!CX11GLXRenderContext( context );
        assert( ctx );

        glXMakeCurrent( cast( void* )dsp, data.x11Win, ctx.glxGlc );
    }

    void window_swapBuffers( ID id ) {
        mixin( TGetWindowData!() );
        glXSwapBuffers( cast( void* )dsp, data.x11Win );
    }
}
