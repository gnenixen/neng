module engine.modules.physics_2d.world;

import engine.modules.physics_2d.physics_2d;
import engine.modules.physics_2d.basic;

class CP2DWorld : CP2DObject {
    mixin( TRegisterClass!CP2DWorld );
public:
    this() {
        pId = GPhysics2D.world_create();
    }

    void makeCurrent() {
        GPhysics2D.world = pId;
    }

    @property {
        void gravity( SVec2F ngravity ) { GPhysics2D.world_setProperty( pId, EP2DWorldProperty.GRAVITY, var( ngravity ) ); }
        SVec2F gravity() { return GPhysics2D.world_getProperty( pId, EP2DWorldProperty.GRAVITY ).as!SVec2F; }
    }
}

/*
enum EP2DBodyType {
    STATIC,
    DYNAMIC,
    KINEMATIC,
}

enum EP2DShapeType {
    BOX,
    CIRCLE,
    EDGE,
}

enum EP2DJointType {
    WELD,
    MOTOR,
    WHEEL,
    REVOLUTE,
}

enum EP2DBodyEventType {
    COLLIDE_BEGIN,
    COLLIDE_END,
    TRIGGER_ENTER,
    TRIGGER_OUT,
}

struct SP2DDebugInfo {
    uint bodysCount;
    uint shapesCount;
}

struct SP2DFilterData {
    ushort category = 0x0001;
    ushort mask     = 0xFFFF;
}

struct SP2DRayCastInput {
    SVec2F start;
    SVec2F end;

    SP2DFilterData filter;
}

struct SP2DRayCastResult {
    ID body = ID_INVALID;
    SVec2F point = SVec2F( 0.0f );
    SVec2F normal = SVec2F( 0.0f );
}

abstract class AP2DDebugDraw : CObject {
    mixin( TRegisterClass!AP2DDebugDraw );
public:
    abstract void drawPolygon( Array!( SVec2F ) points, SColorRGBA color );
    abstract void drawCircle( SVec2F pos, SVec2F axis, float radius, SColorRGBA color );
    abstract void drawLine( SVec2F start, SVec2F end, SColorRGBA color );
}

abstract class APhysics2D : CObject {
    mixin( TRegisterClass!( APhysics2D, SingletonBackendable ) );
public:
    static CRSClass backend;

public:
    bool bSimulate = true;
    bool bDebugDraw = false;

protected:
    AP2DDebugDraw debugDraw;

public:
    SP2DRayCastResult raycast( SVec2F start, SVec2F end, SP2DFilterData filter = SP2DFilterData() ) {
        return raycast( SP2DRayCastInput( start, end, filter ) );
    }

abstract:

    void destroy( ID id );
    void update( float delta );
    void postUpdate();

    SP2DRayCastResult raycast( SP2DRayCastInput input );
    Array!ID query_aabb( SVec2F lower, SVec2F upper, SP2DFilterData filter = SP2DFilterData() );

    ID body_create( EP2DBodyType type );

    void body_setMass( ID id, float mass );
    float body_getMass( ID id );

    void body_setGravityEnabled( ID id, bool bEnabled );
    void body_setGravityScale( ID id, float scale );
    void body_setFilterData( ID id, SP2DFilterData filterData );
    SP2DFilterData body_getFilterData( ID id );

    void body_setIsBullet( ID id, bool bBullet );
    bool body_getIsBullet( ID id );

    void body_setFixedRotation( ID id, bool bVal );
    bool body_getFixedRotation( ID id );

    void body_setPosition( ID id, SVec2F pos );
    SVec2F body_getPosition( ID id );
    SVec2F body_getWorldCenter( ID id );

    void body_setRotation( ID id, float angle );
    float body_getRotation( ID id );

    void body_setLinearVelocity( ID id, SVec2F velocity );
    SVec2F body_getLinearVelocity( ID id );

    void body_setAngularVelocity( ID id, float velocity );
    float body_getAngularVelocity( ID id );
    void body_setAngularDamping( ID id, float damping );
    float body_getAngularDamping( ID id );

    void body_applyForce( ID id, SVec2F force, SVec2F pos );
    void body_applyLinearImpulce( ID id, SVec2F impulce, SVec2F pos );

    uint body_getCollidingCount( ID id );
    Array!ID body_getCollidingBodies( ID id );
    void body_connectHandler( ID id, SCallable handler );
    void body_addShapes( ID id, Array!ID shapes );
    void body_removeShapes( ID id, Array!ID shapes );

    ID shape_create( EP2DShapeType type, VArray data );
    void shape_update( ID id, EP2DShapeType type, VArray data );
    void shape_move( ID id, SVec2F pos );
    uint shape_getCollidingCount( ID id );

    void shape_setIsTrigger( ID id, bool bIsTrigger );
    bool shape_getIsTrigger( ID id );

    void shape_setPosition( ID id, SVec2F pos );
    SVec2F shape_getPosition( ID id );

    void shape_setRotation( ID id, float angle );
    float shape_getRotation( ID id );

    void shape_setFrition( ID id, float friction );
    float shape_getFriction( ID id );

    void shape_setFilterData( SP2DFilterData filter );

    ID joint_create( EP2DJointType type, ID bodyA, ID bodyB );
    void joint_setAnchors( ID id, SVec2F a, SVec2F b );

    // Revolute joint
    void joint_revolute_enableMotor( ID id, bool bEnabled );
    bool joint_revolute_isMotorEnabled( ID id );

    void joint_revolute_setMotorSpeed( ID id, float speed );
    float joint_revolute_getMotorSpeed( ID id );

    void joint_revolute_setMaxMotorTorque( ID id, float torque );
    float joint_revolute_getMaxMotorTorque( ID id );

    @property {
        void gravity( SVec2F vec );
        SVec2F gravity();
    }

    SP2DDebugInfo debug_getInfo();
    void debug_setDrawBackend( AP2DDebugDraw backend );
    void debug_redraw();
}

pragma( inline, true )
APhysics2D GPhysics2D() {
    return APhysics2D.sig;
}*/
