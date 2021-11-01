module engine.framework.input.action;

import engine.core.object;
import engine.core.input;
import engine.core.utils.ustruct;

enum EInputActionType {
    BUTTON,
    AXIS
}

class CInputAction : CObject {
    mixin( TRegisterClass!CInputAction );
public:
    String name;
    EInputActionType type;
    Array!AInputEvent events;

    float value;

    bool isAction( String name ) { return this.name == name; }
    bool isActionPressed( String name ) { return this.name == name && value == 1.0f; }
    bool isActionReleased( String name ) { return this.name == name && value == 0.0f; }

    bool isPressed() { return value == 1.0f; }
    bool isReleased() { return value == 0.0f; }
}
