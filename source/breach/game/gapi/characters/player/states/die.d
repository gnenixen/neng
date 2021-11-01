module game.gapi.characters.player.states.die;

import game.gapi.components.fsm;

class CPlayerState_Die : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Die );
public:
    override void _enter() {
        animation.play( "Death", 0 );

        movement.direction.x = 0;
        movement.forceStopHorizontal();
    }
}

