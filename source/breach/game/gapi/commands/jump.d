module game.gapi.commands.jump;

import game.gapi.components.controller;

class CJumpCommand : CCharacterControllerCommand {
public:
    override void execute() {
        character.movement.jump();
    }
}
