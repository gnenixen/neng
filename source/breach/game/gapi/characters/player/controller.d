module game.gapi.characters.player.controller;

import engine.framework.input;

import game.core.actions;

import game.gapi.components.controller;
import game.gapi.commands;

class CPlayerController : CCharacterController {
    mixin( TRegisterClass!CPlayerController );
public:
    override void _ptick( float delta ) {
        vdirection = getInputDirection();
        if ( vdirection != character.movement.direction ) {
            newCommand!CMoveCommand( vdirection );
        }

        super._ptick( delta );
    }

    override void _input( CInputAction action ) {
        if ( action.isActionPressed( EGameInputActions.JUMP ) ) {
            newCommand!CJumpCommand();

            character.movement.bJumpActive = true;
        }
        else if ( action.isActionReleased( EGameInputActions.JUMP ) ) {
            character.movement.bJumpActive = false;
        }

        if ( action.isActionPressed( EGameInputActions.ATTACK ) ) {
            newCommand!CAttackCommand();
        }

        if ( action.isAction( EGameInputActions.BLOCK ) ) {
            if ( action.isPressed() ) {
                newCommand!CBlockEnterCommand();
            } else {
                newCommand!CBlockOutCommand();
            }
        }

        if ( action.isActionPressed( EGameInputActions.DODGE ) ) {
            newCommand!CDodgeCommand();
        }
    }

protected:
    SVec2I getInputDirection() {
        SVec2I result = SVec2I( 0 );

        if ( GInput.isActionPressed( EGameInputActions.MOVE_RIGHT ) ) {
            result.x = 1;
        }

        if ( GInput.isActionPressed( EGameInputActions.MOVE_LEFT ) ) {
            result.x = ( (result.x == 1) ? 0 : -1 );
        }

        return result;
    }
}
