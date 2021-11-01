module engine.smodules.fmod.server;

import engine.core.os;
import engine.core.math;
import engine.core.log;

import engine.modules.sound;

import engine.thirdparty.derelict.fmod.fmod;

enum float PIXELS_IN_METER = 100;

class CFMODSoundHandler : CObject {
    mixin( TRegisterClass!CFMODSoundHandler );
public:
    FMOD_SOUND* handler;
    FMOD_CREATESOUNDEXINFO info;

    alias handler this;

    this( FMOD_SOUND* snd, FMOD_CREATESOUNDEXINFO iinfo ) {
        handler = snd;
        info = iinfo;
    }

    ~this() {
        FMOD_Sound_Release( handler );
    }
}

class CFMODSoundServer : ASoundServer {
    mixin( TRegisterClass!CFMODSoundServer );
public:
    FMOD_SYSTEM* system;
    SSoundListenerData listenerData;

protected:
    void check( FMOD_RESULT result, string at = "" ) {
        if ( result == FMOD_OK ) return;

        log.error( "FMOD has encountered an error: (", result, ") ", FMOD_ErrorString( result ), " at '", at, "'" );

        assert( false );
    }

    FMOD_VECTOR toFMOD( SVec3F vec ) {
        FMOD_VECTOR ret;
        ret.x = vec.x / PIXELS_IN_METER;
        ret.y = vec.y / PIXELS_IN_METER;
        ret.z = vec.z / PIXELS_IN_METER;

        return ret;
    }

    SVec3F fromFMOD( FMOD_VECTOR vec ) {
        SVec3F ret;
        ret.x = vec.x * PIXELS_IN_METER;
        ret.y = vec.y * PIXELS_IN_METER;
        ret.z = vec.z * PIXELS_IN_METER;

        return ret;
    }

public:
    this() {
        listenerData.position = SVec3F( 0.0f );
        listenerData.up = SVec3F( 0.0f );
        listenerData.forward = SVec3F( 0.0f );
        listenerData.velocity = SVec3F( 0.0f );
    }

    ~this() {
        FMOD_System_Close( system );
        FMOD_System_Release( system );
    }
    
override:
    void initialize( uint numOfChannels ) {
        DerelictFmod.load( CString( OS.env_get( "exec/path" ), "/libfmod.so" ) );

        auto res = FMOD_System_Create( &system, 0x00020203 );
        check( res, "Create system" );

        res = FMOD_System_Init( system, numOfChannels, FMOD_INIT_NORMAL, null );
        check( res, "Init system" );
    }

    void update() {
        FMOD_VECTOR lpos = toFMOD( listenerData.position );
        auto res = FMOD_System_Set3DListenerAttributes( system, 0, &lpos, null, null, null );
        check( res, "Set listener attributes" );

        FMOD_System_Update( system );
    }

    void destroy( ID id ) { DestroyObject( id ); }

    ID sound_create( Array!ubyte data ) {
        assert( data.length > 0 );

        FMOD_SOUND* snd;

        FMOD_CREATESOUNDEXINFO info;
        info.cbsize = FMOD_CREATESOUNDEXINFO.sizeof;
        info.length = cast( uint )data.length;

        auto res = FMOD_System_CreateSound( system, cast( char* )data.ptr, FMOD_OPENMEMORY | FMOD_3D, &info, &snd );
        check( res, "Create sound" );

        return NewObject!CFMODSoundHandler( snd, info ).id;
    }

    /**
        Play sound by given id
        Returns - channel id
    */
    ID sound_play( ID id ) {
        CFMODSoundHandler handler = GetObjectByID!CFMODSoundHandler( id );
        assert( handler );

        FMOD_CHANNEL* channel;

        auto res = FMOD_System_PlaySound( system, handler, null, false, &channel );
        check( res, "Sound play" );

        FMOD_Channel_SetMode( channel, FMOD_3D | FMOD_LOOP_NORMAL );

        return cast( ID )cast( void* )channel;
    }

    bool channel_setProperty( ID id, ESoundChannelProperty property, var value ) {
        FMOD_CHANNEL* channel = cast( FMOD_CHANNEL* )cast( void* )id;

        switch ( property ) {
        case ESoundChannelProperty.POSITION:
            SVec3F pos = value.as!SVec3F;
            FMOD_VECTOR vec = toFMOD( pos );

            FMOD_Channel_Set3DAttributes( channel, &vec, null, null );
            break;

        case ESoundChannelProperty.IS_LOOPED:
            FMOD_Channel_SetLoopCount( channel, value.as!bool ? -1 : 0 );
            break;

        default:
            assert( false );
        }

        return true;
    }

    var channel_getProperty( ID id, ESoundChannelProperty property ) {
        FMOD_CHANNEL* channel = cast( FMOD_CHANNEL* )cast( void* )id;
        
        var ret;

        switch ( property ) {
        case ESoundChannelProperty.POSITION:
            FMOD_VECTOR vec;
            FMOD_Channel_Get3DAttributes( channel, &vec, null, null );

            ret = fromFMOD( vec );
            break;

        case ESoundChannelProperty.IS_LOOPED:
            int loopsCount;
            FMOD_Channel_GetLoopCount( channel, &loopsCount );

            ret = loopsCount == -1;
            break;

        default:
            assert( false );
        }

        return ret;
    }

    @property {
        SSoundListenerData listener() { return listenerData; }
        void listener( SSoundListenerData data ) { listenerData = data; }
    }
}
