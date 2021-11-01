module engine.framework.scene_tree.base.timer;

import engine.core.timer;

import engine.framework.scene_tree.base.node;

class CNTimer : CNode {
    mixin( TRegisterClass!CNTimer );
public:
    Signal!() timeout;

protected:
    CTimer ltimer;

public:
    this() {
        ltimer = newObject!CTimer();
        ltimer.timeout.connect( &_timeout );
    }

    ~this() {
        destroyObject( ltimer );
    }

    void start() { ltimer.start(); }
    void stop() { ltimer.stop(); }

    void pause() { ltimer.pause(); }
    void unpause() { ltimer.unpause(); }

    @property {
        void waitTime( float time ) { ltimer.waitTime = time; }
        float waitTime() { return ltimer.waitTime; }
    }

protected:
    override void tick( float delta ) {
        ltimer.update( delta );
    }

    void _timeout() {
        timeout.emit();
    }
}
