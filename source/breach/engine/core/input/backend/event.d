module engine.core.input.backend.event;

import engine.core.object;

import engine.core.input.backend.device;

abstract class AInputEvent : CObject {
    mixin( TRegisterClass!AInputEvent );
public:
    AInputDevice device;

    float strength() { return 0.0f; }
}
