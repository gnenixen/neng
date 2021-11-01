module game.core;

public:
import game.core.base;
import game.core.components;
import game.core.effects;
import game.core.objects;

import game.core.actions;
import game.core.world;
import game.core.state;
import game.core.character;

void register_game_core() {
    register_game_core_components();
}
