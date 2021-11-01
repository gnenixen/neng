module game.gapi.characters.player.states.block;

import game.gapi.components.fsm;

class CPlayerState_Block : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Block );
public:
    override void _enter() {
        character.health.bDamageResist = true;

        movement.direction.x = 0;
        movement.forceStopHorizontal();

        animation.play( "Block", 0 );
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
        if (
            command.isType!CBlockOutCommand()
        ) {
            transition( "base" );
        }
    }
}
