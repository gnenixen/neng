module engine.modules.physics_2d;

public:
import engine.modules.physics_2d.world;
import engine.modules.physics_2d.physics_2d;
import engine.modules.physics_2d.body;
import engine.modules.physics_2d.shape;
import engine.modules.physics_2d.joint;
import engine.modules.physics_2d.basic;

private {
    import engine.core.object;
    import engine.core.config;
    import engine.core.symboldb;
    import engine.modules.module_decl;
}

class CMD_physics_2d : AModuleDeclaration {
    mixin( TRegisterClass!CMD_physics_2d );
public:
    this() {
        name = "Physics2D";
        initPhase = EModuleInitPhase.NORMAL;
    }

    override void initialize() {
        //GSymbolDB.register!APhysics2D;
        GSymbolDB.register!CP2DObject;
        GSymbolDB.register!CP2DBody;
        GSymbolDB.register!CP2DShape;
        GSymbolDB.register!CP2DBoxShape;
        GSymbolDB.register!CP2DCircleShape;
        //GSymbolDB.register!CP2DJoint;
        //GSymbolDB.register!CP2DMotorJoint;
        //GSymbolDB.register!CP2DRevoluteJoint;
        //GSymbolDB.register!CP2DWheelJoint;

        assert( APhysics2D.backend );
        newObjectR!APhysics2D( APhysics2D.backend );
    }

    override void update( float delta ) {
        //GPhysics2D.update( delta );
    }
}
