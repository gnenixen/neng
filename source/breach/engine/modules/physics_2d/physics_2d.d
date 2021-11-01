module engine.modules.physics_2d.physics_2d;

public {
    import engine.core.containers.array;
    import engine.core.math;
    import engine.core.object;
    import engine.core.callable;
    import engine.core.typedefs;
}

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

enum EP2DWorldProperty {
    GRAVITY,            // SVec2F
}

enum EP2DBodyProperty {
    IS_GRAVITY_ENABLED, // bool
    IS_BULLET,          // bool
    IS_FIXED_ROTATION,  // bool

    MASS,               // float
    POSITION,           // SVec2F
    ROTATION,           // float
    WORLD_CENTER,       // SVec2F

    GRIVITY_SCALE,      // float
    FILTER_DATA,        // SP2DFilterData
    
    LINEAR_VELOCITY,    // SVec2F
    ANGULAR_VELOCITY,   // float
    ANGULAR_DAMPING,    // float

    COLLIDING_COUNT,    // uint
}

enum EP2DShapeProperty {
    IS_TRIGGER,         // bool

    FILTER_DATA,        // SP2DFilterData

    POSITION,           // SVec2F
    ROTATION,           // float
    FRICTION,           // float

    COLLIDING_COUNT     // uint
}

enum EP2DJointProperty {
    IS_MOTOR_ENABLED,   // bool
    MOTOR_SPEED,        // float
    MAX_MOTOR_TORQUE    // float
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

public:
    SP2DRayCastResult raycast( SVec2F start, SVec2F end, SP2DFilterData filter = SP2DFilterData() ) {
        return raycast( SP2DRayCastInput( start, end, filter ) );
    }

abstract:
    void destroy( ID id );
    void update( float delta );
    void postUpdate();

    @property {
        void world( ID newWorld );
        ID world();
    }

    /*********** QUERY AND RAYCASTS ***********/
    SP2DRayCastResult raycast( SP2DRayCastInput input );
    Array!SP2DRayCastResult raycast_multi( SP2DRayCastInput input );
    //Array!ID query_aabb( SVec2F lower, SVec2F upper, SP2DFilterData filter = SP2DFilterData() );

    /*********** BODY ***********/
    ID world_create();

    bool world_setProperty( ID id, EP2DWorldProperty property, var value );
    var world_getProperty( ID id, EP2DWorldProperty property );

    /*********** BODY ***********/
    ID body_create( EP2DBodyType type );

    bool body_setProperty( ID id, EP2DBodyProperty property, var value );
    var body_getProperty( ID id, EP2DBodyProperty property );

    void body_applyLinearImpulce( ID id, SVec2F impulce, SVec2F pos );
    void body_applyForce( ID id, SVec2F force, SVec2F pos );

    /**
        Send to handler informations about phys body
        position and angle
        Params:
            id - phys body id
            handler - handler for data send, must be a function like
            void function( EP2DBodyEventType type, VArray args )
    */
    void body_connectHandler( ID id, SCallable handler );
    void body_addShapes( ID id, Array!ID shapes );
    void body_removeShapes( ID id, Array!ID shapes );

    /*********** SHAPES ***********/
    ID shape_create( EP2DShapeType type, VArray data );

    bool shape_setProperty( ID id, EP2DShapeProperty property, var value );
    var shape_getProperty( ID id, EP2DShapeProperty property );

    /**
        Update shape geometry
        Params:
            id - shape id
            type - type of shape geometry basis
            data - data for update process
    */
    void shape_update( ID id, EP2DShapeType type, VArray data );

    /**
        Move shape around of his center based on
        body position
        Params
    */
    void shape_move( ID id, SVec2F pos );

    /*********** JOINTS ***********/
    /*ID joint_create( EP2DJointType type, ID bodyA, ID bodyB );

    bool joint_setProperty( ID id, EP2DJointProperty property, var value );
    var joint_getProperty( ID id, EP2DJointProperty property );

    void joint_setAnchors( ID id, SVec2F a, SVec2F b );*/

    /*********** DEBUG ***********/
    SP2DDebugInfo debug_getInfo();
    void debug_setDrawBackend( AP2DDebugDraw backend );
    void debug_redraw();
}

/**
    Only for autocompletion
*/
pragma( inline, true )
APhysics2D GPhysics2D() {
    return APhysics2D.sig;
}
