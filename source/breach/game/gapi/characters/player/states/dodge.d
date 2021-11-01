module game.gapi.characters.player.states.dodge;

import game.gapi.components.fsm;

class CPlayerState_Dodge : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Dodge );
public:
    CTimer lexit;

    override void _enter() {
        character.health.bDamageResist = true;
        bLockDirection = true;

        movement.direction.x = -character.direction.x;
        moveCfg.maxMoveSpeed = 700;

        animation.play( "Dodge", 0 );
        animation.speed = 1.0f;

        animation.onEventReceived.connect( &onAnimationEvent );

        lexit = execLater( 0.25, &exit );

        character.stamina.min( 2 );
    }

    override void _leave() {
        character.health.bDamageResist = false;
        movement.direction.x = 0;
        animation.speed = 1.3f;

        animation.onEventReceived.disconnect( &onAnimationEvent );

        lexit.stop();
    }

    override void _ptick( float delta ) {
        if ( !character.isOnFloor ) {
            transition( "fall" );
        }
    }

    void onAnimationEvent( String name ) {
        if ( name == "spAnimationComplete" ) {
            //transition( "base" );
        }
    }

    void exit() {
        transition( "base" );
    }
}

