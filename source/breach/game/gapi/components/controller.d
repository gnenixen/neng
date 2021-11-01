module game.gapi.components.controller;

public:
import engine.core.object;
import engine.core.containers;

import game.gapi.character;

class CCharacterControllerCommand {
public:
    CGAPICharacter character;

public:
    void execute() {}
}

class CCharacterController : CComponent {
    mixin( TRegisterClass!CCharacterController );
public:
    /* 
        "Virtual" direction, represents
        the direction where character wants
        to move.

        For PLAYER, for example, it reflects
        raw input from move actions
    */
    SVec2I vdirection;

protected:
    Array!CCharacterControllerCommand commands;
    CGAPICharacter character;

public:
    override void setup( CGameObject obj ) {
        object = obj;
        character = Cast!CGAPICharacter( obj );
        assert( character );
    }

    override void _ptick( float delta ) {
        foreach ( com; commands ) {
            character.handleControllerCommand( com );
        }

        commands.free(
            ( com ) {
                deallocate( com );
            }
        );
    }

    void addCommand( CCharacterControllerCommand command ) {
        command.character = character;

        commands ~= command;
    }

    void newCommand( T, Args... )( Args args )
    if ( is ( T : CCharacterControllerCommand ) ) {
        T command = allocate!T( args );
        command.character = character;

        commands ~= command;
    }
}
