module game.gapi.character;

public:
import game.core.character;

import game.gapi.components.controller;
import game.gapi.components.fsm;

class CGAPICharacter : CBaseCharacter {
    mixin( TRegisterClass!CGAPICharacter );
public:
    CCharacterController controller;

public:
    this() {
        super();

        controller = newComponent!CCharacterController();
    }

    void changeController( CCharacterController ncontroller ) {
        assert( ncontroller );

        removeComponent( controller );
        addComponent( ncontroller );

        controller = ncontroller;
    }

    void handleControllerCommand( CCharacterControllerCommand command ) {
        CGAPICharacterState state = Cast!CGAPICharacterState( fsm.current );
        if ( state ) {
            state._handle( command );
        }
    }
}
