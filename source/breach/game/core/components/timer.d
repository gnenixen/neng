module game.core.components.timer;

public:
import engine.core.timer;

import game.core.base.component;

class CTimerComponent : CComponent {
    mixin( TRegisterClass!CTimerComponent );
protected:
    Array!CTimer ltimers;

public:
    this() {}

    ~this() {
        ltimers.free(
            ( timer ) { destroyObject( timer ); }
        );
    }

    override void _tick( float delta ) {
        foreach ( timer; ltimers ) {
            timer.update( delta );
        }
    }

    CTimer execLater( float time, void delegate() del ) {
        VArray args = toVArray( del );

        CTimer timer = getTimer();
        timer.waitTime = time;
        timer.args = args;

        timer.start();

        return timer;
    }
    
protected:
    CTimer getTimer() {
        CTimer ret;

        foreach ( timer; ltimers ) {
            if ( timer.state == ETimerState.END || timer.state == ETimerState.STOP ) {
                ret = timer;
                break;
            }
        }

        if ( !ret ) {
            ret = newObject!CTimer();
            ret.vtimeout.connect( &endTimerHandler );
            ltimers ~= ret;
        }

        return ret;
    }

    void endTimerHandler( VArray args ) {
        void delegate() del = args[0].as!( void delegate() );
        if ( del ) {
            del();
        }
    }
}
