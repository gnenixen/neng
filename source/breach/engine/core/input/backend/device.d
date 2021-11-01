module engine.core.input.backend.device;

public {
    import engine.core.object;

    import engine.core.input.backend.state;
    import engine.core.input.backend.event;
}

template TRegisterInputDeviceStateType( T ) {
    import std.string;

    enum TRegisterInputDeviceStateType = format(
        "
        private %1$s lstate;

        public alias state this;

        public %1$s state() {
            if ( !IsValid( lstate ) ) {
                lstate = NewObject!%1$s();
                lstate.device = id;
            }

            return lstate;
        }

        private void destroyState() {
            DestroyObject( lstate );
        }
        ",
        T.stringof
    );
}

abstract class AInputDevice : CObject {
    mixin( TRegisterClass!AInputDevice );
public:
}
