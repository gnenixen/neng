module engine.smodules.display_server.x11.input;

version( linux ):
import engine.thirdparty.x11.X;
import engine.thirdparty.x11.Xlib;
import engine.thirdparty.x11.Xutil;
import engine.thirdparty.x11.Xtos;

import engine.core.input;
import engine.core.math;

import engine.smodules.display_server.x11.display_server;
import engine.smodules.display_server.x11.input_map;

class CX11InputBackend : AInputBackend {
    mixin( TRegisterClass!CX11InputBackend );
protected:
    Display* dsp;
    Array!AInputEvent queueEvents;

public:
    CIKeyboard keyboard;
    CIMouse mouse;

    this( Display* disp ) {
        dsp = disp;
        keyboard = newObject!CIKeyboard();
        mouse = newObject!CIMouse();

        setup_XII_KEYBOARD_MAPPING();
        setup_XKEYSYM_TO_UNICODE();
    }

    ~this() {
        destroyObject( keyboard );
    }

    void clearQueue() {
        queueEvents.free(
            ( event ) {
                destroyObject( event );
            }
        );
    }

    @NoReflection
    void processEvent( XEvent xevent ) {
        switch ( xevent.type ) {
        case KeyPress:
            CIKeyboardEvent event = newObject!CIKeyboardEvent;
            event.device = keyboard;
            
            KeySym sym = XKeycodeToKeysym( dsp, cast( ubyte )xevent.xkey.keycode, 0 );
            event.key = getKeyboardEnum( sym );
            event.character = keysymToUnicode( sym );
            event.type = EIKeyboardKeyEventType.DOWN;

            queueEvents ~= event;
            break;

        case KeyRelease:
            bool bIsRetriggered = false;

            if ( XEventsQueued( dsp, QueuedAfterReading ) ) {
                XEvent nev;
                XPeekEvent( dsp, &nev );

                if ( nev.type == KeyPress && nev.xkey.time == xevent.xkey.time && nev.xkey.keycode == xevent.xkey.keycode ) {
                    XNextEvent( dsp, &xevent );
                    bIsRetriggered = true;
                }
            }

            if ( bIsRetriggered ) break;

            CIKeyboardEvent event = newObject!CIKeyboardEvent;
            event.device = keyboard;
            
            KeySym sym = XKeycodeToKeysym( dsp, cast( ubyte )xevent.xkey.keycode, 0 );
            event.key = getKeyboardEnum( sym );
            event.character = keysymToUnicode( sym );
            event.type = EIKeyboardKeyEventType.UP;

            queueEvents ~= event;
            break;

        case ButtonPress:
            switch ( xevent.xbutton.button ) {
            case Button1:
                mouse.buttons.set( EMouseButton.LEFT, true );
                break;
            case Button2:
                mouse.buttons.set( EMouseButton.MIDDLE, true );
                break;
            case Button3:
                mouse.buttons.set( EMouseButton.RIGHT, true );
                break;

            default:
                break;
            }
            break;

        case ButtonRelease:
            switch ( xevent.xbutton.button ) {
            case Button1:
                mouse.buttons.set( EMouseButton.LEFT, false );
                break;
            case Button2:
                mouse.buttons.set( EMouseButton.MIDDLE, false );
                break;
            case Button3:
                mouse.buttons.set( EMouseButton.RIGHT, false );
                break;

            default:
                break;
            }
            break;

        case MotionNotify:
            mouse.position = SVec2F(
                xevent.xmotion.x,
                xevent.xmotion.y
            );
            break;

        default:
            break;
        }
    }

override:
    void setMessagesHandler( SCallable handler ) {}

    Array!ID devices() {
        return Array!ID( keyboard.id, mouse.id );
    }

    Array!AInputEvent queue() {
        return queueEvents;
    }

    Array!AInputEvent device_queue( ID device ) {
        return Array!AInputEvent();
    }
}
