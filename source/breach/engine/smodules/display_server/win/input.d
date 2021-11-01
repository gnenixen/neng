module engine.smodules.display_server.win.input;

version( Windows ):

import engine.core.input;

class CWindowsInputBackend : AInputBackend {
    mixin( TRegisterClass!CWindowsInputBackend );
private:
    Array!AInputEvent queueEvents;

public:
	CIKeyboard keyboard;
	CIMouse mouse;
	
	this() {
		keyboard = newObject!CIKeyboard();
		mouse = newObject!CIMouse();
	}
    void addEvent( AInputEvent event ) {
        queueEvents ~= event;
    }

    void clearQueue() {
        queueEvents.free(
            ( AInputEvent event ) {
                destroyObject( event );
            }
        );
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