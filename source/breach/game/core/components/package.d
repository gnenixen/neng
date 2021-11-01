module game.core.components;

public:
import game.core.components.combat;
import game.core.components.effects;
import game.core.components.fsm;
import game.core.components.health;
import game.core.components.movement;
import game.core.components.physics;
import game.core.components.spine;
import game.core.components.stamina;
import game.core.components.timer;

void register_game_core_components() {
    import engine.core.symboldb;

    GSymbolDB.register!CEffect;
    GSymbolDB.register!CEffectsComponent;
    GSymbolDB.register!CCombatComponent;
    GSymbolDB.register!CFSMComponent;
    GSymbolDB.register!CHealthCompnent;
    GSymbolDB.register!CMovementComponent;
    GSymbolDB.register!CPhysicsComponent;
    GSymbolDB.register!CSpineComponent;
    GSymbolDB.register!CStaminaComponent;
    GSymbolDB.register!CTimerComponent;
}
