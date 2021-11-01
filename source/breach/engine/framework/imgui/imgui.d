module engine.framework.imgui.imgui;

public:
import engine.thirdparty.derelict.imgui;

import engine.core.object;
import engine.core.memory;
import engine.core.math;
import engine.core.os;
import engine.core.input;
import engine.core.string;

import engine.framework.input;

private {
    enum IG_BACKSPACE = 1;
    enum IG_ENTER = 2;
    enum IG_A_UP = 3;
    enum IG_A_DOWN = 4;
    enum IG_A_LEFT = 5;
    enum IG_A_RIGHT = 6;
}

private extern( C ) static {
    void* imguiAlloc( size_t size, void* ud ) {
        return allocate( size );
    }

    void imguiFree( void* ptr, void* ud ) {
        deallocate( ptr );
    }
}

enum EImGUIWinFlags {
    NO_TITLE_BAR = ImGuiWindowFlags_NoTitleBar,
    NO_RESIZE = ImGuiWindowFlags_NoResize,
    ALWAYS_AUTO_RESIZE = ImGuiWindowFlags_AlwaysAutoResize,
    NO_MOVE = ImGuiWindowFlags_NoMove,
    NO_SAVED_SETTINGS = ImGuiWindowFlags_NoSavedSettings,
}

enum EImGUICond {
    ALWAYS = ImGuiCond_Always,
    FIRST_START = ImGuiCond_FirstUseEver,
}

class CImGUI : CObject {
    mixin( TRegisterClass!( CImGUI, Singleton ) );
private:
    ImGuiContext* context;

public:
    this() {
        version ( linux ) {
            DerelictImgui.load( CString( OS.env_get( "exec/path" ), "/cimgui.so" ) );
        } else {
            DerelictImgui.load();
        }
    
        igSetAllocatorFunctions( &imguiAlloc, &imguiFree );

        context = igCreateContext();

        ImGuiIO* io = igGetIO();
        igStyleColorsDark();

        io.KeyMap[ImGuiKey_Backspace] = IG_BACKSPACE;
        io.KeyMap[ImGuiKey_Enter] = IG_ENTER;
        io.KeyMap[ImGuiKey_UpArrow] = IG_A_UP;
        io.KeyMap[ImGuiKey_DownArrow] = IG_A_DOWN;
        io.KeyMap[ImGuiKey_RightArrow] = IG_A_RIGHT;
        io.KeyMap[ImGuiKey_LeftArrow] = IG_A_LEFT;
    }

    ~this() {
        igDestroyContext( context );
    }

    void newFrame( float delta, uint width, uint height ) {
        auto io = igGetIO();
        io.DisplaySize = ImVec2( width, height );
        io.DisplayFramebufferScale = ImVec2( 1, 1 );
        io.DeltaTime = delta;

        io.MouseDown[0] = GInput.mouse.buttons.get( EMouseButton.LEFT );
        io.MouseDown[1] = GInput.mouse.buttons.get( EMouseButton.MIDDLE );
        io.MouseDown[2] = GInput.mouse.buttons.get( EMouseButton.RIGHT );

        io.MousePos = ImVec2( GInput.mouse.position.x, GInput.mouse.position.y );

        igNewFrame();
    }

    void input( Array!AInputEvent events ) {
        auto io = igGetIO();

        foreach ( event; events ) {
            CIKeyboardEvent key = Cast!CIKeyboardEvent( event );
            if ( !key ) continue;

            if ( key.key == EKeyboard.BACKSPACE ) {
                io.KeysDown[IG_BACKSPACE] = key.type == EIKeyboardKeyEventType.DOWN;
            }

            if ( key.key == EKeyboard.ENTER ) {
                io.KeysDown[IG_ENTER] = key.type == EIKeyboardKeyEventType.DOWN;
            }

            if ( key.key == EKeyboard.SHIFT ) {
                io.KeyShift = key.type == EIKeyboardKeyEventType.DOWN;
            }

            if ( key.type != EIKeyboardKeyEventType.UP ) continue;
            if ( key.character == '\0' ) continue;

            io.AddInputCharacter( key.character );
        }
    }

    void endFrame() {
        igEndFrame();
    }

    ImDrawData* render() {
        igRender();
        return igGetDrawData();
    }

    void setNextWindowPos( SVec2I pos, int flags = 0, SVec2I pivot = SVec2I( 0, 0 ) ) {
        igSetNextWindowPos( ImVec2( pos.x, pos.y ), flags, ImVec2( pivot.x, pivot.y ) );
    }

    void setNextWindowSize( SVec2I size, int cond = 0 ) {
        igSetNextWindowSize( ImVec2( size.x, size.y ), cond );
    }

    bool begin( String text, bool* bOpened = null, int flags = 0 ) {
        return igBegin( text.c_str.cstr, bOpened, flags );
    }

    void end() {
        igEnd();
    }

    void separator() {
        igSeparator();
    }

    // Lua and other languages may use "end" keyword
    void lend() {
        igEnd();
    }

    bool beginChild( String title, SVec2I size, bool bBorder = false, ImGuiWindowFlags flags = 0 ) {
        return igBeginChild( title.c_str.cstr, ImVec2( size.x, size.y ), bBorder, flags );
    }

    void endChild() {
        igEndChild();
    }

    float getFrameHeightWithSpacing() {
        return igGetFrameHeightWithSpacing();
    }

    float getStyleItemSpacingY() {
        return igGetStyle().ItemSpacing.y;
    }

    bool button( String text ) {
        return igButton( text.c_str.cstr );
    }

    void text( String text ) {
        igText( text.c_str.cstr );
    }

    void image( ID img, SVec2I size = SVec2I( -1 ) ) {
        import engine.modules.render_device;

        if ( size == SVec2I( -1 ) ) {
            size = RD.rt_resolution( img );
        }

        igImage( cast( void* )img, ImVec2( size.x, size.y ) );
    }

    bool checkbox( String text, bool* val ) {
        return igCheckbox( text.c_str.cstr, val );
    }

    bool sliderFloat( String label, float* v, float vmin, float vmax, float power = 1.0f ) {
        return igSliderFloat( label.c_str.cstr, v, vmin, vmax, "%.3f", power );
    }

    bool sliderInt( String label, int* v, int vmin, int vmax ) {
        return igSliderInt( label.c_str.cstr, v, vmin, vmax );
    }

    void sameLine() {
        igSameLine();
    }

    bool selectable( String label, bool bSelected = false ) {
        return igSelectable( label.c_str.cstr, bSelected );
    }

    bool listBox( String label, int* currItem, Array!String items, int heightInItems = -1 ) {
        assert( currItem, "Invalid list box handler!" );

        Array!( const(char)* ) narray;
        foreach ( elem; items ) {
            narray ~= elem.c_str.cstr;
        }

        return igListBoxStr_arr( label.c_str.cstr, currItem, narray.ptr, cast( int )items.length, heightInItems );
    }

    bool combo( String label, int* currItem, Array!String items, int heightInItems = -1 ) {
        assert( currItem, "Invalid combo box handler!" );

        Array!CString cstrs;
        foreach ( elem; items ) {
            cstrs ~= elem.c_str;
        }

        Array!( const(char)* ) narray;
        foreach ( elem; cstrs ) {
            narray ~= elem.cstr;
        }

        return igCombo( label.c_str.cstr, currItem, narray.ptr, cast( int )items.length, heightInItems );
    }

    //bool inputText( String label, char* buf, size_t bufSize, ImGuiInputTextFlags flags = 0, ImGuiInputTextCallback callback = null, void* udata = null ) {
        //return igInputText( label.c_str.cstr, buf, bufSize, flags, callback, udata );
    //}

    void pushStyleVar( ImGuiStyleVar idx, SVec2I value ) {
        igPushStyleVarVec2( idx, ImVec2( value.x, value.y ) );
    }

    void popStyleVar() {
        igPopStyleVar();
    }

    void popStyleColor() {
        igPopStyleColor();
    }

    void textUnformatted( String txt ) {
        igTextUnformatted( txt.c_str.cstr );
    }

    void logToClipboard() {
        igLogToClipboard();
    }

    void logFinish() {
        igLogFinish();
    }

    void setScrollHereY( float centerYRatio = 0.5f ) {
        igSetScrollHereY( centerYRatio );
    }

    float getScrollY() {
        return igGetScrollY();
    }

    float getScrollMaxY() {
        return igGetScrollMaxY();
    }

    bool colorPicker4( String label, SColorRGBA* color ) {
        bool bRet;
        float[4] data;

        data[0] = color.r;
        data[1] = color.g;
        data[2] = color.b;
        data[3] = color.a;

        bRet = igColorPicker4( label.c_str.cstr, data );

        color.r = data[0];
        color.g = data[1];
        color.b = data[2];
        color.a = data[3];

        return bRet;
    }

    //bool sliderFloat( String label, float* v, float v_min, float v_max, string format = "%.3f", float power = 1.0f ) {
        //return igSliderFloat( label.cstr, v, v_min, v_max, CString( format ).cstr, power );
    //}
}

pragma( inline, true )
CImGUI GImGUI() {
    return CImGUI.sig;
}
