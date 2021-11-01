module game.gapi.characters.TEST.states.die;

import game.gapi.components.fsm;

class CTESTState_Die : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Die );
public:
    CTimer lstop;

    override void _enter() {
        animation.play( "Death", 0, false );
        animation.onEventReceived.connect( &onAnimationEvent );

        bLockDirection = true;

        moveCfg.maxMoveSpeed = 900;
        movement.direction.x = -character.direction.x;

        lstop = execLater( 0.3f, &stop );
    }

    override void _leave() {
        animation.onEventReceived.disconnect( &onAnimationEvent );
    }

    void onAnimationEvent( String name ) {
        if ( name == "spAnimationComplete" ) {
            movement.direction.x = 0;
            movement.forceStopHorizontal();
        }
    }

    void stop() {
        movement.direction.x = 0;
        movement.forceStopHorizontal();
    }
}
