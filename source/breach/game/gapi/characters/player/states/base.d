module game.gapi.characters.player.states.base;

import game.gapi.components.fsm;

class CPlayerState_Base : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Base );
public:
    override void _enter() {
        animation.play( "Idle", 0, true );
    }

    override void _ptick( float delta ) {
        if ( Math.abs( velocity.x ) > movement.cfg.minMoveSpeed ) {
            transition( "base_run" );
        }

        if ( !character.isOnFloor ) {
            if ( velocity.y < 0 ) {
                transition( "jump" );
            } else {
                transition( "fall" );
            }
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

        if ( command.isType!CBlockEnterCommand ) {
            transition( "block" );
        }

        if ( command.isType!CDodgeCommand && character.stamina.isCanMin( 2 ) ) {
            transition( "dodge" );
        }
    }
}
