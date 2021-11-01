module game.gapi.characters.TEST.states.fall;

import game.gapi.components.fsm;

class CTESTState_Fall : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Fall );
public:
    override void _enter() {
        animation.play( "Jump_idle", 0 );

        //moveCfg.impulceModificator = 0.1f;
        //moveCfg.fallofModificator = 0.95;
    }

    override void _ptick( float delta ) {
        if ( character.isOnFloor ) {
            transition( "base" );
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
