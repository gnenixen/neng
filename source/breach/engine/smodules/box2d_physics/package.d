module engine.smodules.box2d_physics;

public:
import engine.smodules.box2d_physics.physics_2d;

void box2d_physics__register() {
    import engine.core : GSymbolDB;
    import engine.modules.physics_2d : APhysics2D;

    APhysics2D.backend = GSymbolDB.register!b2CPhydics2D;
}

void box2d_physics__unregister() {}
