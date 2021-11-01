module game.gapi.characters.TEST.states.base;

import game.gapi.components.fsm;

class CTESTState_Base : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Base );
public:
    override void _enter() {
        animation.play( "Idle", 0, true );
    }

    override void _ptick( float delta ) {
        if ( Math.abs( velocity.x ) != 0 ) {
            transition( "base_run" );
        }

        if ( !character.isOnFloor ) {
            transition( "fall" );
        }
    }

    override void _handle( CCharacterControllerCommand command ) {
        if (
            command.isType!CJumpCommand ||
            command.isType!CMoveCommand
        ) {
            command.execute();
        }

        if ( command.isType!CAttackCommand && character.stamina.isCanMin( 2 ) ) {
            transition( "attack" );
        }
    }
}
