module game.gapi.characters.TEST.states.block;

import game.gapi.components.fsm;

class CTESTState_Block : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Block );
public:
    this() {
        super();

        bLockDirection = true;
    }

    override void _enter() {
        animation.play( "Block", 0 );

        character.health.bDamageResist = true;
    }

    override void _leave() {
        character.health.bDamageResist = false;
    }

    override void _ptick( float delta ) {
        if ( !character.isOnFloor ) {
            transition( "fall" );
        }
    }

    override void _handle( CCharacterControllerCommand command ) {
    }
}

