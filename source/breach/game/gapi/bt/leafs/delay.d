module game.gapi.bt.leafs.delay;

import engine.framework.bt;

class CBTLDelay : CBTLeaf {
    mixin( TRegisterClass!CBTLDelay );
private:
    float time;
    float ltime;

public:
    this( float itime ) {
        time = itime;
    }

protected:
    override void onInit() {
        time = ltime;
    }

    override EBTNodeStatus onProcess() {
        if ( blackboard.has( rs!"delta" ) ) return EBTNodeStatus.FAILURE;
        
        float delta = blackboard.get( rs!"delta" ).as!float;
        ltime -= delta;

        if ( ltime <= 0.0f ) return EBTNodeStatus.SUCCESS;

        return EBTNodeStatus.RUNNING;
    }
}


