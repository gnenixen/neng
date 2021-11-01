module game.gapi.characters.player.states.jump;

import game.gapi.components.fsm;

class CPlayerState_Jump : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Jump );
public:
    override void _enter() {
        animation.play( "Jump_up", 0 );

        //moveCfg.maxMoveSpeed = 300.0f;
        moveCfg.impulceModificator = 0.1f;
        moveCfg.fallofModificator = 0.95f;

        movement.direction.x = character.controller.vdirection.x;
    }

    override void _ptick( float delta ) {
        if ( velocity.y > 0 ) {
            transition( "fall" );
        }
    }

    override void _handle( CCharacterControllerCommand command ) {
        if (
            command.isType!CMoveCommand
        ) {
            command.execute();
        }
    }

}
