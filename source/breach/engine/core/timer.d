module engine.core.timer;

import engine.core.os;
import engine.core.signal;
import engine.core.typedefs;
import engine.core.object;
import engine.core.gengine;

enum ETimerState {
    STOP,
    PROCESS,
    PAUSED,
    END,
}

class CTimer : CObject {
    mixin( TRegisterClass!CTimer );
public:
    Signal!() timeout;
    Signal!( VArray ) vtimeout;
    Signal!( float ) process;

    VArray args;

private:
    ETimerState lstate = ETimerState.STOP;

    ulong startTime;
    ulong pausedTime;
    ulong currentTime;

    ulong lwaitTime = 0;

public:
    void start() {
        lstate = ETimerState.PROCESS;
        startTime = OS.time_get();
        currentTime = 0;
    }

    void stop() {
        lstate = ETimerState.STOP;
    }

    void pause() {
        if ( lstate == ETimerState.PROCESS ) {
            lstate = ETimerState.PAUSED;

            pausedTime = OS.time_get() - startTime;
            startTime = 0;
        }
    }

    void unpause() {
        if ( lstate == ETimerState.PAUSED ) {
            lstate = ETimerState.PROCESS;

            startTime = OS.time_get() - pausedTime;
            pausedTime = 0;
        }
    }

    void reset() {
        start();
    }

    void update( float delta = -1.0f ) {
        if ( lstate != ETimerState.PROCESS ) return;

        if ( delta < 0.0f ) {
            currentTime = OS.time_get() - startTime;
        } else {
            currentTime += cast( ulong )( delta * 1000.0f );
        }

        if ( currentTime < lwaitTime ) {
            process.emit( cast( float )( currentTime ) / lwaitTime );
        } else {
            timeout.emit();
            vtimeout.emit( args );
            process.emit( 1.0 );
            lstate = ETimerState.END;
        }
    }

    ETimerState state() {
        return lstate;
    }

    @property {
        void waitTime( float secs ) {
            assert( lstate != ETimerState.PROCESS );

            lwaitTime = cast( ulong )( secs * 1000.0f );
        }

        float waitTime() const {
            return cast( float )( lwaitTime / 1000.0f );
        }
    }
}
