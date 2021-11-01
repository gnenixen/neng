module engine.core.eversion;

struct SVersion {
    uint major;
    uint minor;
    uint path;
}

enum ENGINE_CORE_VERSION = SVersion( 1, 0, 0 );