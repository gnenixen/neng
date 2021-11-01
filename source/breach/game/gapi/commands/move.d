module game.gapi.commands.move;

import game.gapi.components.controller;

class CMoveCommand : CCharacterControllerCommand {
public:
    SVec2I direction;

public:
    this( SVec2I dir ) {
        direction = dir;
    }

    override void execute() {
        character.movement.direction = direction;
    }
}
