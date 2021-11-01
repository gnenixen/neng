module game.gapi.characters.player.states.fall;

import game.gapi.components.fsm;

class CPlayerState_Fall : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Fall );
public:
    override void _enter() {
        if ( animation.currentAnim != "Jump_idle" ) {
            animation.mix = 0.5f;
            animation.play( "Jump_idle", 0 );
        }

        //moveCfg.maxMoveSpeed = 400.0f;
        moveCfg.impulceModificator = 0.1f;
        moveCfg.fallofModificator = 0.95f;

        movement.direction.x = character.controller.vdirection.x;
    }

    override void _leave() {
        animation.mix = 0.1f;
    }

    override void _ptick( float delta ) {
        if ( character.isOnFloor ) {
            transition( "base" );
        }
    }

    override void _handle( CCharacterControllerCommand command ) {
        if (
            command.isType!CMoveCommand ||
            // In some situations may save some speedruns:)
            ( command.isType!CJumpCommand && character.isOnFloor )
        ) {
            command.execute();
        }
    }

}
