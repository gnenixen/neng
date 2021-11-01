module game.gapi.characters.TEST.states.base_run;

import game.gapi.components.fsm;

class CTESTState_BaseRun : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_BaseRun );
public:
    override void _enter() {
        animation.play( "Run", 0, true );
    }

    override void _ptick( float delta ) {
        if ( Math.abs( velocity.x ) == 0 ) {
            transition( "base" );
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
