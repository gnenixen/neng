module engine.smodules.display_server.win.server;

version( Windows ):
private {
    import core.runtime;
    import core.sys.windows.windows;
}

import std.utf;

import engine.core.memory;
import engine.core.log;
import engine.core.string;

import engine.modules.display_server;

import engine.smodules.display_server.win.input_map;
import engine.smodules.display_server.win.input;

pragma( lib, "gdi32.lib" );
pragma( lib, "opengl32.lib" );

private static __gshared {
    enum WIN_CLASS_NAME = "RN_NENG_WIN";

    HINSTANCE ghInstance;

    uint windowsCount = 0;
}

auto toUTF16z( S )( S s ) {
    return toUTFz!( const(wchar)* )( s );
}

class CWinWindowContext : CObject {
    mixin( TRegisterClass!CWinWindowContext );
public:
    HGLRC rcontext;
    HDC hdc;
}

class CWinWindow : CObject {
    mixin( TRegisterClass!CWinWindow );
public:
    HWND hwnd;
    CWinWindowContext context;

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
        CloseWindow( hwnd );
        windowsCount--;
        GDisplayServer.windowsNumUpdated.emit( windowsCount );
    }
}

template TGetWindowData( string ret = "" ) {
    enum TGetWindowData = "
        CWinWindow data = getObjectByID!CWinWindow( id );
        if ( !data ) {
            log.warning( \"Passed invalid data id!\" );
            return " ~ ret ~ ";
        }
    ";
}

class CWinDisplayServer : ADisplayServer {
    mixin( TRegisterClass!CWinDisplayServer );
public:
    CWindowsInputBackend input;

protected:
    WNDCLASS wc;
    PIXELFORMATDESCRIPTOR pfd;

    Array!CWinWindow windows;

public:
    this() {
		ghInstance = GetModuleHandle( NULL );
	
        wc.hInstance = ghInstance;
        wc.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
        wc.lpszMenuName  = null;
        wc.lpszClassName = WIN_CLASS_NAME.toUTF16z();
        wc.lpfnWndProc = cast( WNDPROC )&WndProc;

        if ( !RegisterClass( &wc ) ) {
            MessageBox( NULL, "Failed To Register The Window Class.", "ERROR", MB_OK | MB_ICONEXCLAMATION );
            assert( false );
        }

        Memory.memset( &pfd, 0, PIXELFORMATDESCRIPTOR.sizeof );

        pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
        pfd.nVersion = 1;
        pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
        pfd.iPixelType = PFD_TYPE_RGBA;
        pfd.cColorBits = 32;
        pfd.cAlphaBits = 8;
        pfd.cDepthBits = 24;
        pfd.iLayerType = PFD_MAIN_PLANE;
    }

override:
    void update( float delta ) {
        input.clearQueue();
		
		MSG msg;

        foreach ( win; windows ) {
            while ( PeekMessage( &msg, win.hwnd, 0, 0, PM_REMOVE ) ) {
                TranslateMessage( &msg );
                DispatchMessage( &msg );
            }
        }
    }

    void destroy( ID id ) {
        destroyObject( id );
    }

    void input_init() {
        import engine.core : GSymbolDB;

        GSymbolDB.register!CWindowsInputBackend;
        input = newObject!CWindowsInputBackend();
    }

    ID window_create( String title, uint posx, uint posy, uint width, uint height ) {
        CWinWindow data = newObject!CWinWindow();

        data.title = title;
        data.cachePos = SVec2I( posx, posy );
        data.cacheSize = SVec2I( width, height );
        data.context = null;

        data.hwnd = CreateWindow(
            WIN_CLASS_NAME.toUTF16z,
            title.opCast!wchar.cstr,
            WS_OVERLAPPEDWINDOW,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            width,
            height,
            NULL,
            NULL,
            ghInstance,
            NULL
        );
    
        ShowWindow( data.hwnd, SW_SHOW );
        SetForegroundWindow( data.hwnd );
        SetFocus( data.hwnd );
        UpdateWindow( data.hwnd );

        SetWindowLongPtr( data.hwnd, GWLP_USERDATA, cast( LONG_PTR )( cast( void* )data ) );

        windows ~= data;

        return data.id;
    }

    void window_setEventCallback( ID id, SCallable callable ) {
        mixin( TGetWindowData!() );
        data.eventsCallback = callable;
    }

    bool window_isMinimized( ID id ) { return false; }
    void window_setMinimized( ID id, bool bVal ) {}

    bool window_isFocused( ID id ) { return true; }
    void window_setFocused( ID id, bool bVal ) {}

    SVec2I window_getPos( ID id ) { return SVec2I( 0 ); }
    void window_setPos( ID id, SVec2I pos ) {}

    SVec2I window_getSize( ID id ) {
        mixin( TGetWindowData!( "SVec2I( 0 )" ) );
        return data.cacheSize;
    }

    void window_setSize( ID id, SVec2I size ) {
        mixin( TGetWindowData!( "" ) );
        data.cacheSize = size;
    }

    String window_getTitle( ID id ) {
        mixin( TGetWindowData!( "String()" ) );
        return data.title;
    }

    void window_setTitle( ID id, String title ) {
        mixin( TGetWindowData!( "" ) );
        data.title = title;
    }

    void message( String title, String text, ushort flags ) {
        import std.utf;

        MessageBox( NULL, text.opCast!wchar.cstr, title.opCast!wchar.cstr, MB_OK | MB_ICONEXCLAMATION );
    }

    /*********** MONITORS ***********/
    int monitor_count() { return 2; }
    SMonitorInfo monitor_getInfo( uint idx ) { return SMonitorInfo(); }

    /*********** RENDER ***********/
    ID rc_create() {
        return newObject!CWinWindowContext().id;
    }

    ID window_getContext( ID id ) {
        mixin( TGetWindowData!( "ID_INVALID" ) );
        return data.context.id;
    }

    void window_setContext( ID id, ID contextId ) {
        mixin( TGetWindowData!( "" ) );
        CWinWindowContext context = getObjectByID!CWinWindowContext( contextId );
        assert( context );

        if ( data.context !is context ) {
            context.hdc = GetDC( data.hwnd );
            int pixelFormat = ChoosePixelFormat( context.hdc, &pfd );
            assert( pixelFormat, "Failed to find a suitable pixel format!" );
            assert(
                SetPixelFormat( context.hdc, pixelFormat, &pfd ),
                "Failed to set the pixel format!"
            );
            
            context.rcontext = wglCreateContext( context.hdc );
            assert( context.rcontext, "Failed to create OpenGL render context!" );

            data.context = context;

            RECT rect;
            GetClientRect( data.hwnd, &rect );
            data.cacheSize = SVec2I( rect.right - rect.left, rect.bottom - rect.top );
            sendWindowEvent( data, EDSWindowEvent.RESIZE, var( data.cacheSize ) );
        }

        wglMakeCurrent( context.hdc, context.rcontext );
    }

    void window_swapBuffers( ID id ) {
        mixin( TGetWindowData!( "" ) );
        assert( data.context );
        SwapBuffers( data.context.hdc );
    }
}

void sendWindowEvent( CWinWindow win, EDSWindowEvent event, SVariant data ) {
    assert( win );

    if ( !win.eventsCallback.isNull() ) {
        win.eventsCallback.call( event, data );
	}
}

extern( Windows )
LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
    import engine.modules;

    void* ptr = cast( void* )GetWindowLongPtr( hwnd, GWLP_USERDATA );
    CWinWindow window = ptr is null ? null : cast( CWinWindow )ptr;

    if ( !window ) {
        return DefWindowProc( hwnd, message, wParam, lParam );
    }

    CWinDisplayServer serv = Cast!CWinDisplayServer( GDisplayServer );
    assert( serv );

    CWindowsInputBackend input = serv.input;

    switch ( message ) {
    case WM_KEYDOWN:
		if ( !input ) break;
		
        CIKeyboardEvent event = newObject!CIKeyboardEvent;
		event.device = input.keyboard;
		
        event.key = getKeyboardEnum( wParam );
        event.type =  EIKeyboardKeyEventType.DOWN;

        input.addEvent( event );
        break;
    case WM_KEYUP:
		if ( !input ) break;
	
        CIKeyboardEvent event = newObject!CIKeyboardEvent;
		event.device = input.keyboard;
		
        event.key = getKeyboardEnum( wParam );
        event.type =  EIKeyboardKeyEventType.UP;

        input.addEvent( event );
        break;
		
	case WM_MOUSEMOVE:
		POINT point;
		GetCursorPos( &point );
		input.mouse.position = SVec2F(
			point.x,
			point.y
		);
		break;
		
	case WM_LBUTTONDOWN:
		input.mouse.buttons.set( EMouseButton.LEFT, false );
		break;
	case WM_LBUTTONUP:
		input.mouse.buttons.set( EMouseButton.LEFT, true );
		break;
	case WM_RBUTTONDOWN:
		input.mouse.buttons.set( EMouseButton.RIGHT, false );
		break;
	case WM_RBUTTONUP:
		input.mouse.buttons.set( EMouseButton.RIGHT, true );
		break;
		
    case WM_SIZE:
        RECT rect;
        GetClientRect( hwnd, &rect );
        window.cacheSize = SVec2I( rect.right - rect.left, rect.bottom - rect.top );
        sendWindowEvent( window, EDSWindowEvent.RESIZE, var( window.cacheSize ) );
        break;
    case WM_CLOSE:
		sendWindowEvent( window, EDSWindowEvent.CLOSED, var( null ) );
        GDisplayServer.destroy( window.id );
        break;
    case WM_QUIT:
        PostQuitMessage( 0 );
        return 0;
    default:
        break;
    }
	
    return DefWindowProc( hwnd, message, wParam, lParam );
}
