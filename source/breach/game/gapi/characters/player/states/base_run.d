module game.gapi.characters.player.states.base_run;

import game.gapi.components.fsm;

class CPlayerState_BaseRun : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_BaseRun );
public:
    override void _enter() {
        animation.play( "Run", 0, true );

        movement.direction.x = character.controller.vdirection.x;
    }

    override void _ptick( float delta ) {
        if ( velocity.x == 0.0f ) {
            transition( "base" );
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
