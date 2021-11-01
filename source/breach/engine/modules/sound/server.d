module engine.modules.sound.server;

import engine.core.object;
import engine.core.math;
import engine.core.typedefs;

struct SSoundListenerData {
    SVec3F position;
    SVec3F velocity;
    SVec3F up;
    SVec3F forward;
}

enum ESoundChannelProperty {
    POSITION,     // SVec3F
    IS_LOOPED,    // bool
    VOLUME,       // float
}

abstract class ASoundServer : CObject {
    mixin( TRegisterClass!( ASoundServer, SingletonBackendable ) );
public:
    static CRSClass backend;

public:
    void initialize( uint numOfChannels );
    void update();
    void destroy( ID id );

    ID sound_create( RawData data );

    /**
        Play sound by given id
        Returns - channel id
    */
    ID sound_play( ID id );

    bool channel_setProperty( ID id, ESoundChannelProperty property, var value );
    var channel_getProperty( ID id, ESoundChannelProperty property );

    @property {
        SSoundListenerData listener();
        void listener( SSoundListenerData data );
    }
}

pragma( inline, true )
ASoundServer GSoundServer() { return ASoundServer.sig; }
