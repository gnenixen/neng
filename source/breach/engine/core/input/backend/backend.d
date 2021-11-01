module engine.core.input.backend.backend;

public:
import engine.core.object;
import engine.core.callable;
import engine.core.containers;
import engine.core.input.backend.device;
import engine.core.input.backend.event;

enum EInputBackendMessageType {
    DEVICE_ADDED,
    DEVICE_DISCONNECTED,
    DEVICE_CONNECTED,
}

class AInputBackend : CObject {
    mixin( TRegisterClass!( AInputBackend, SingletonBackendable ) );
public:
    void setMessagesHandler( SCallable handler ) {}

    Array!ID devices() { return Array!ID(); }
    Array!AInputEvent queue() { return Array!AInputEvent(); }
    Array!AInputEvent device_queue( ID device ) { return Array!AInputEvent(); }
}

static __gshared pragma( inline, true ) {
    AInputBackend GInputBackend() { return AInputBackend.sig; }
}
