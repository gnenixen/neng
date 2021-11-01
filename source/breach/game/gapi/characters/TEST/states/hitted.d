module game.gapi.characters.TEST.states.hitted;

import game.gapi.components.fsm;

import game.gapi.characters.TEST;

class CTESTState_Hitted : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Hitted );
protected:
    CTimer lexit;
    CTimer lstop;

public:
    override void _enter() {
        lexit = execLater( 1.0f, &exit );
        lstop = execLater( 0.3f, &stop );

        animation.play( "Damage", 0, false );
        movement.direction.x = 0;
        movement.forceStopHorizontal();

        bLockDirection = true;

        CTEST test = Cast!CTEST( character );
        if ( test.lplayer.transform.pos.distance( test.transform.pos ) < 100.0f ) {
            moveCfg.maxMoveSpeed = 200;
            movement.direction.x = character.direction.x * -1;
        }
    }

    override void _leave() {
        lexit.stop();
        lstop.stop();

        movement.direction.x = 0;
        movement.forceStopHorizontal();
    }

    void exit() {
        transition( "base" );
    }

    void stop() {
        movement.direction.x = 0;
        movement.forceStopHorizontal();
    }
}
