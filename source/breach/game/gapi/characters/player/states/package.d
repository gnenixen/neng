module game.gapi.characters.player.states;

public:
import game.gapi.characters.player.states.attack;
import game.gapi.characters.player.states.base;
import game.gapi.characters.player.states.base_run;
import game.gapi.characters.player.states.block;
import game.gapi.characters.player.states.fall;
import game.gapi.characters.player.states.jump;
import game.gapi.characters.player.states.hitted;
import game.gapi.characters.player.states.die;
import game.gapi.characters.player.states.dodge;

void player_states_register() {
    import engine.core.symboldb;

    GSymbolDB.register!CPlayerState_Base;
    GSymbolDB.register!CPlayerState_BaseRun;
    GSymbolDB.register!CPlayerState_Block;
    GSymbolDB.register!CPlayerState_Jump;
    GSymbolDB.register!CPlayerState_Fall;
    GSymbolDB.register!CPlayerState_Attack;
}
