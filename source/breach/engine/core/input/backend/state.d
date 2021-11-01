module engine.core.input.backend.state;

import engine.core.object;

abstract class AInputState : CObject {
    mixin( TRegisterClass!AInputState );
public:
    ID device;
}
