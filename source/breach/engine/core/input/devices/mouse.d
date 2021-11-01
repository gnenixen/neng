module engine.core.input.devices.mouse;

import engine.core.math.vec;
import engine.core.input.backend;

enum EMouseButton {
    LEFT,
    MIDDLE,
    RIGHT
}

class CIMouseEvent : AInputEvent {
    mixin( TRegisterClass!CIMouseEvent );
public:
    EMouseButton button;
}

class CIMouseState : AInputState {
    mixin( TRegisterClass!CIMouseState );
public:
    SVec2F position;
    Dict!( bool, EMouseButton ) buttons;

    this() {
        buttons.set( EMouseButton.LEFT, false );
        buttons.set( EMouseButton.MIDDLE, false );
        buttons.set( EMouseButton.RIGHT, false );
    }
}

class CIMouse : AInputDevice {
    mixin( TRegisterClass!CIMouse );
    mixin( TRegisterInputDeviceStateType!CIMouseState );
public:
    ~this() {
        destroyState();
    }
}
