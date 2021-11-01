module game.gapi.characters.player.states.hitted;

import game.gapi.components.fsm;

class CPlayerState_Hitted : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Hitted );
protected:
    CTimer lexit;

    bool bWantToEnterBlock = false;

public:
    override void _enter() {
        lexit = execLater( 0.3f, &exit );
        bWantToEnterBlock = false;

        bLockDirection = true;
        

        movement.direction.x = 0;
        movement.forceStopHorizontal();

        moveCfg.maxMoveSpeed = 200;
        movement.direction.x = character.direction.x * -1;

        animation.play( "Damage", 0, false );
    }

    override void _leave() {
        lexit.stop();
    }

    override void _handle( CCharacterControllerCommand command ) {
        if ( command.isType!CBlockEnterCommand ) {
            bWantToEnterBlock = true;
        }

        if ( command.isType!CBlockOutCommand ) {
            bWantToEnterBlock = false;
        }
    }

    void exit() {
        if ( bWantToEnterBlock ) {
            transition( "block" );
        } else {
            transition( "base" );
        }
    }
}
