module engine.framework.console;

import engine.core.object;
import engine.core.memory;
import engine.core.log;

import engine.framework.imgui;

alias ConsoleCommandFunction = void function( CConsole, Array!String args );

class CConsoleEngineLogger : ALogger {
protected:
    CConsole console;
    
public:
    this( CConsole con ) {
        console = con;
    }

    override void logImpl( ELogType type, String text ) {
        console.addLine( text );
    }
}

class CConsole : CObject {
    mixin( TRegisterClass!( CConsole, Singleton ) );
public:
    bool bAutoScroll = true;
    bool bOpen = false;

    Array!String history;

protected:
    bool bImgGuiOpen = true;
    CString inputBuffer;

    CConsoleEngineLogger logHandler;

    Dict!( ConsoleCommandFunction, String ) commands;

public:
    this() {
        logHandler = allocate!CConsoleEngineLogger( this );

        inputBuffer = "";
        inputBuffer.resize( 256 );

        log.addLogger( logHandler );

        commands["clear"] = &cmd_clear;
        commands["echo"] = &cmd_echo;
    }

    ~this() {
        deallocate( logHandler );
    }

    void register( String name, ConsoleCommandFunction func ) {
        assert( !commands.has( name ) );

        commands[name] = func;
    }

    void render() {
        if ( !bOpen ) return;

        if ( !GImGUI.begin( "Console", &bImgGuiOpen ) ) {
            GImGUI.end();
            return;
        }

        GImGUI.pushStyleVar( ImGuiStyleVar_ItemSpacing, SVec2I( 4, 1 ) );

        float footerHeightToReserve = GImGUI.getStyleItemSpacingY() + GImGUI.getFrameHeightWithSpacing();
        GImGUI.beginChild( "ScrollingRegion", SVec2I( 0, -footerHeightToReserve ), false, ImGuiWindowFlags_HorizontalScrollbar );

        GImGUI.logToClipboard();
        foreach ( line; history ) {
            GImGUI.textUnformatted( line );
        }

        if ( bAutoScroll && GImGUI.getScrollY() >= GImGUI.getScrollMaxY() ) {
            GImGUI.setScrollHereY( 1.0f );
        }

        GImGUI.logFinish();
        GImGUI.popStyleVar();
        GImGUI.endChild();
        GImGUI.separator();

        ImGuiInputTextFlags inputTextFlags = ImGuiInputTextFlags_EnterReturnsTrue | ImGuiInputTextFlags_CallbackCompletion | ImGuiInputTextFlags_CallbackHistory;
        if ( igInputText( String( "Input" ).c_str.cstr, cast(char*)inputBuffer.ptr, inputBuffer.length, inputTextFlags, &textEditCallback, cast( void* )this ) ) {
            execute();
            inputBuffer = "";
            inputBuffer.resize( 256 );
        }

        GImGUI.end();
    }

    void execute() {
        // Make new, clear string, because input from
        // imgui make its have non valid size
        String input = String( inputBuffer.cstr );

        addLine( String( "# ", input ) );

        if ( !input.length ) return;

        Array!String split = input.split( rs!" " );

        ConsoleCommandFunction cmd = commands.get( split[0], null );
        if ( !cmd ) {
            addLine( String( "Not found command: ", split[0] ) );
            return;
        }

        // Remove command name
        split.removeAt( 0 );

        cmd( this, split );
    }

    void addLine( String text ) {
        history ~= text;
    }

    extern( C )
    static int textEditCallback( ImGuiInputTextCallbackData* data ) {
        return 0;
    }
}

pragma( inline, true )
CConsole GConsole() {
    return CConsole.sig;
}

private {
    void cmd_clear( CConsole console, Array!String args ) {
        console.history.free();
    }

    void cmd_echo( CConsole console, Array!String args ) {
        foreach ( str; args ) {
            log.info( str );
        }
    }
}
