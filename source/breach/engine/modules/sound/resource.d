module engine.modules.sound.sound_resource;

import engine.core.memory;
import engine.core.math;
import engine.core.resource;
import engine.core.utils.profile;
import engine.core.log;

import engine.modules.sound.server;

/**
    Wrapper for sound server calls to channel API,
    nothing really interestring
*/
struct SSoundChannel {
public:
    ID sChannelId = ID_INVALID;

public:
    @property {
        void bLoop( bool bVal ) {
            GSoundServer.channel_setProperty( sChannelId, ESoundChannelProperty.IS_LOOPED, var( bVal ) );
        }

        bool bLoop() {
            return GSoundServer.channel_getProperty( sChannelId, ESoundChannelProperty.IS_LOOPED ).as!bool;
        }

        void position( SVec3F pos ) {
            GSoundServer.channel_setProperty( sChannelId, ESoundChannelProperty.POSITION, var( pos ) );
        }

        SVec3F position() {
            return GSoundServer.channel_getProperty( sChannelId, ESoundChannelProperty.POSITION ).as!SVec3F;
        }
    }
}

class CSound : CResource {
    mixin( TRegisterClass!CSound );
public:
    ID sId = ID_INVALID;

    alias sId this;

public:
    ~this() {
        GSoundServer.destroy( sId );
    }

    SSoundChannel play( SVec3F position = SVec3F( 0.0f ) ) {
        ID sChannelId = GSoundServer.sound_play( sId );

        SSoundChannel channel = SSoundChannel( sChannelId );

        channel.position = position;

        return channel;
    }

    SSoundChannel playLooped( SVec3F position = SVec3F( 0.0f ) ) {
        SSoundChannel channel = play( position );

        channel.bLoop = true;

        return channel;
    }
}

class CSoundOperator : AResourceOperator {
    mixin( TRegisterClass!CSoundOperator );
public:
override:
    void load( CResource res, String path ) {
        CSound sound = Cast!CSound( res );
        SFileRef file = GFileSystem.file( path );

        RawData data = file.readAsRawData();
        if ( !data.length ) {
            log.warning( "Invalid file data!" );
            res.loadPhase = EResourceLoadPhase.FAILED;
            return;
        }

        sound.sId = GSoundServer.sound_create( data );
        sound.loadPhase = EResourceLoadPhase.SUCCESS;
    }

    void hrSwap( CResource o, CResource n ) {}

    CResource newPreloadInstance() { return NewObject!CSound(); }

    Array!String extensions() { return Array!String( String( "ogg" ) ); }
}
