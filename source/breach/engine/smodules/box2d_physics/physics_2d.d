module engine.smodules.box2d_physics.physics_2d;

import engine.thirdparty.dbox;

import engine.core.log;
import engine.core.containers;

import engine.modules.physics_2d.physics_2d;

import engine.smodules.box2d_physics.render;

enum float PIXELS_IN_METER = 100;

b2Vec2 b2vec2( SVec2F vec ) {
    return b2Vec2( vec.x / PIXELS_IN_METER, -vec.y / PIXELS_IN_METER );
}

b2Vec2 b2vec2( float x, float y ) {
    return b2Vec2( x / PIXELS_IN_METER, -y / PIXELS_IN_METER );
}

SVec2F r_b2vec2( b2Vec2 vec ) {
    return SVec2F( vec.x * PIXELS_IN_METER, -vec.y * PIXELS_IN_METER );
}

struct SEndUpdateHandlerCall {
    EP2DBodyEventType type;
    ID from;
    ID to;
}

class b2CCollisionListener : b2ContactListener {
protected:
    b2CPhydics2D world;

public:
    this( b2CPhydics2D iworld ) {
        world = iworld;
    }

    override void BeginContact( b2Contact contact ) {
        b2CBody bodyA = Cast!b2CBody( contact.GetFixtureA().GetBody().GetUserData() );
        b2CBody bodyB = Cast!b2CBody( contact.GetFixtureB().GetBody().GetUserData() );
        b2CShape shapeA = Cast!b2CShape( contact.GetFixtureA().GetUserData() );
        b2CShape shapeB = Cast!b2CShape( contact.GetFixtureB().GetUserData() );

        if ( !IsValid( bodyA ) )  { log.warning( "Invalid contact A body!" ); return; }
        if ( !IsValid( bodyB ) )  { log.warning( "Invalid contact B body!" ); return; }
        if ( !IsValid( shapeA ) )  { log.warning( "Invalid contact A shape!" ); return; }
        if ( !IsValid( shapeB ) )  { log.warning( "Invalid contact B shape!" ); return; }

        ID idBodyA = bodyA.id;
        ID idBodyB = bodyB.id;
        ID idShapeA = shapeA.id;
        ID idShapeB = shapeB.id;

        bodyA.contactsNum++;
        shapeA.contactsNum++;

        if ( shapeA.isTrigger && shapeB.isTrigger ) return;

        EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_BEGIN;
        if ( shapeA.isTrigger ) {
            type = EP2DBodyEventType.TRIGGER_ENTER;
        }

        world.addCollisionEvent( type, bodyA, bodyB );

        type = EP2DBodyEventType.COLLIDE_BEGIN;
        if ( shapeB.isTrigger ) {
            type = EP2DBodyEventType.TRIGGER_ENTER;
        }

        world.addCollisionEvent( type, bodyB, bodyA );
    }

    override void EndContact( b2Contact contact ) {
        b2CBody bodyA = Cast!b2CBody( contact.GetFixtureA().GetBody().GetUserData() );
        b2CBody bodyB = Cast!b2CBody( contact.GetFixtureB().GetBody().GetUserData() );
        b2CShape shapeA = Cast!b2CShape( contact.GetFixtureA().GetUserData() );
        b2CShape shapeB = Cast!b2CShape( contact.GetFixtureB().GetUserData() );

        bodyA.contactsNum--;
        shapeA.contactsNum--;

        ID idBodyA = bodyA.id;
        ID idBodyB = bodyB.id;
        ID idShapeA = shapeA.id;
        ID idShapeB = shapeB.id;

        if ( shapeA.isTrigger && shapeB.isTrigger ) return;

        EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_END;
        if ( shapeA.isTrigger ) {
            type = EP2DBodyEventType.TRIGGER_OUT;
        }

        world.addCollisionEvent( type, bodyA, bodyB );

        type = EP2DBodyEventType.COLLIDE_END;
        if ( shapeB.isTrigger ) {
            type = EP2DBodyEventType.TRIGGER_OUT;
        }

        world.addCollisionEvent( type, bodyB, bodyA );
    }
}

class b2CWorld : CObject {
    mixin( TRegisterClass!b2CWorld );
public:
    b2World* b2world;
    alias b2world this;

    b2CCollisionListener listener;
    b2CDebugRender debugRenderer;

    SVec2F lgravity;

    Array!b2CBody bodies;
    Array!b2CShape shapes;
    Array!b2CJoint joints;

    this( b2CPhydics2D physics ) {
        lgravity = r_b2vec2( b2Vec2( 0, -9.8 * 2 ) );

        b2world = allocate!b2World( b2vec2( lgravity ) );
        listener = allocate!b2CCollisionListener( physics );
        debugRenderer = allocate!b2CDebugRender();

        b2world.SetContactListener( listener );
        b2world.SetDebugDraw( debugRenderer );

        debugRenderer.SetFlags(
            b2Draw.e_shapeBit |
            b2Draw.e_jointBit
        );
    }

    ~this() {
        deallocate( b2world );
        deallocate( debugRenderer );
    }

    @property {
        void gravity( SVec2F ngravity ) {
            lgravity = ngravity;
            b2world.SetGravity( b2vec2( ngravity ) );
        }

        SVec2F gravity() {
            return lgravity;
        }
    }
}

class b2CBody : CObject {
    mixin( TRegisterClass!b2CBody );
public:
    b2CWorld world;

    EP2DBodyType type;

    Array!b2CShape shapes;
    SCallable eventsHandler;

    b2BodyDef b2bodydef;
    b2Body* b2body;

    uint contactsNum = 0;
    Array!ID collidingBodies;
    Dict!( int, ID ) collidingBodiesInfo;

    this( EP2DBodyType itype, b2CWorld iworld ) {
        type = itype;
        world = iworld;

        switch ( type ) {
        case EP2DBodyType.STATIC:
            b2bodydef.type = b2_staticBody;
            break;
        case EP2DBodyType.DYNAMIC:
            b2bodydef.type = b2_dynamicBody;
            break;
        case EP2DBodyType.KINEMATIC:
            b2bodydef.type = b2_kinematicBody;
            break;

        default:
            assert( false );
        }

        b2bodydef.position.Set( 0, 0 );
        b2bodydef.angle = 0;

        b2body = world.CreateBody( &b2bodydef );
        b2body.SetUserData( cast( void* )this );
    }

    ~this() {
        foreach ( k, v; collidingBodiesInfo ) {
            b2CBody bd = GetObjectByID!b2CBody( k );
            if ( bd ) {
                bd.collidingBodiesInfo.remove( id );
                bd.collidingBodies.remove( id );
                bd.contactsNum--;
            }
        }

        world.DestroyBody( b2body );
    }

    void addShape( b2CShape shape ) {
        if ( !IsValid( shape ) ) {
            log.error( "Invalid shape" );
            return;
        }

        if ( shape.b2shape is null ) {
            log.error( "Non initialized shape" );
            return;
        }

        b2Fixture* fixture;
        if ( type != EP2DBodyType.STATIC ) {
            b2FixtureDef b2fixdef;
            b2fixdef.shape = shape.b2shape;
            b2fixdef.density = 10.0f;
            b2fixdef.friction = 0.0f;
            fixture = b2body.CreateFixture( &b2fixdef );
        } else {
            fixture = b2body.CreateFixture( shape.b2shape, 0.0f );
        }

        shape.body = this;
        shape.b2fixture = fixture;
        shape.b2fixture.SetUserData( cast( void* )shape );

        shapes ~= shape;
    }

    void removeShape( b2CShape shape ) {
        if ( !shapes.has( shape ) ) return;

        if ( shape.b2fixture ) {
            b2body.DestroyFixture( shape.b2fixture );
        }

        shapes.remove( shape );
        shape.b2fixture = null;
    }

    @property {
        void isBullet( bool bVal ) {
            assert( b2body !is null );

            b2body.SetBullet( bVal );
        }

        bool isBullet() {
            assert( b2body !is null );

            return b2body.IsBullet();
        }

        void isFixedRotation( bool bVal ) {
            assert( b2body !is null );

            b2body.SetFixedRotation( bVal );
        }

        bool isFixedRotation() {
            assert( b2body !is null );

            return b2body.IsFixedRotation();
        }

        void mass( float nmass ) {}
        float mass() {
            assert( b2body !is null );

            return b2body.GetMass();
        }

        void position( SVec2F npos ) {
            assert( b2body !is null );

            b2body.SetTransform(
                b2vec2( npos ),
                b2body.GetAngle()
            );
        }

        SVec2F position() {
            assert( b2body !is null );

            return r_b2vec2( b2body.GetPosition() );
        }

        void rotation( float angle ) {
            assert( b2body !is null );

            b2body.SetTransform(
                b2body.GetPosition(),
                Math.degToRad( angle )
            );
        }

        float rotation() {
            assert( b2body !is null );

            return b2body.GetAngle();
        }

        void gravityScale( float scale ) {
            assert( b2body !is null );

            b2body.SetGravityScale( scale );
        }

        float gravityScale() {
            assert( b2body !is null );

            return b2body.GetGravityScale();
        }

        void filterData( SP2DFilterData ifilter ) {
            assert( b2body !is null );

            b2Filter filter;
            filter.categoryBits = ifilter.category;
            filter.maskBits = ifilter.mask;

            for ( b2Fixture* f = b2body.GetFixtureList(); f; f = f.GetNext() ) {
                filter.groupIndex = f.GetFilterData().groupIndex;
                f.SetFilterData( filter );
            }
        }

        SP2DFilterData filterData() {
            assert( b2body !is null );

            SP2DFilterData data;

            b2Filter filter = b2body.GetFixtureList().GetFilterData();
            data.category = filter.categoryBits;
            data.mask = filter.maskBits;

            return data;
        }

        void linearVelocity( SVec2F nvelocity ) {
            assert( b2body !is null );

            b2body.SetLinearVelocity( b2vec2( nvelocity ) );
        }

        SVec2F linearVelocity() {
            assert( b2body !is null );

            return r_b2vec2( b2body.GetLinearVelocity() );
        }

        void angularVelocity( float nvelocity ) {
            assert( b2body !is null );

            b2body.SetAngularVelocity( nvelocity );
        }

        float angularVelocity() {
            assert( b2body !is null );

            return b2body.GetAngularVelocity();
        }

        void angularDamping( float damping ) {
            assert( b2body !is null );

            b2body.SetAngularDamping( damping );
        }

        float angularDamping() {
            assert( b2body !is null );

            return b2body.GetAngularDamping();
        }
    }
}

class b2CShape : CObject {
    mixin( TRegisterClass!b2CShape );
public:
    b2CWorld world;

    EP2DShapeType type;
    bool bSensor = false;
    float angle = 0.0f;
    float lfriction = 0.0f;
    VArray data;
    SP2DFilterData lfilterData;

    b2CBody body;

    b2Shape b2shape;
    b2Fixture* b2fixture;
    b2Filter b2filter;

    uint contactsNum = 0;
    Array!ID collidingShapes;
    Dict!( int, ID ) collidingShapesInfo;

    this( EP2DShapeType itype, VArray idata ) {
        type = itype;
        data = idata;

        updateGeometryData( type, data );
    }

    ~this() {
        foreach ( k, v; collidingShapesInfo ) {
            b2CShape sh = GetObjectByID!b2CShape( k );
            if ( sh ) {
                sh.collidingShapesInfo.remove( id );
                if ( sh.collidingShapes.remove( id ) ) {
                    sh.contactsNum--;
                }
            }
        }

        if ( IsValid( body ) ) {
            body.b2body.DestroyFixture( b2fixture );
        }

        if ( b2shape ) {
            deallocate( b2shape );
        }
    }

    void updateGeometryData( EP2DShapeType itype, VArray idata, SVec2F ipos = SVec2F( 0.0f ), float iangle = 0.0f ) {
        assert( itype == type );

        if ( iangle != float.nan ) {
            angle = iangle;
        }

        if ( body ) {
            b2filter = b2fixture.GetFilterData();
            body.b2body.DestroyFixture( b2fixture );
        }

        if ( b2shape ) {
            deallocate( b2shape );
        }

        createShapeFromData( idata, ipos );

        if ( body ) {
            b2FixtureDef b2fixdef;
            b2fixdef.shape = b2shape;
            b2fixdef.density = 1.0f;
            b2fixdef.friction = lfriction;
            b2fixdef.restitution = 0.0f;
            b2fixdef.isSensor = bSensor;
            b2fixdef.filter = b2filter;

            b2fixture = body.b2body.CreateFixture( &b2fixdef );
            b2fixture.SetUserData( cast( void* )this );
        }
    }

    @property {
        void isTrigger( bool bVal ) {
            assert( b2fixture !is null );
            bSensor = bVal;
            b2fixture.SetSensor( bVal );
        }

        bool isTrigger() {
            assert( b2fixture !is null );
            return bSensor;
        }

        void filterData( SP2DFilterData filter ) {
            assert( b2shape !is null );
            assert( b2fixture !is null );

            lfilterData = filter;

            b2fixture.GetFilterData().categoryBits = filter.category;
            b2fixture.GetFilterData().maskBits = filter.mask;
        }

        SP2DFilterData filterData() {
            return lfilterData;
        }

        void position( SVec2F npos ) {
            assert( b2shape !is null );

            VArray ldata = getShapeGeometryData();
            updateGeometryData( type, data, npos );
        }

        SVec2F position() {
            assert( b2shape !is null );

            SVec2F res = SVec2F( 0.0f );

            if ( b2PolygonShape sh = cast( b2PolygonShape )b2shape ) {
                res = r_b2vec2( sh.m_centroid );
            } else if ( b2CircleShape sh = cast( b2CircleShape )b2shape ) {
                res = r_b2vec2( sh.m_p );
            } else if( b2EdgeShape sh = cast( b2EdgeShape )b2shape ) {
                //res = r_b2vec2( sh. )
            }

            return res;
        }

        void rotation( float iangle ) {
            assert( b2shape !is null );

            VArray ldata = getShapeGeometryData();
            updateGeometryData( type, data, position, iangle );
        }

        float rotation() {
            return angle;
        }

        void friction( float ifriction ) {
            assert( b2shape !is null );
            lfriction = friction;
            b2fixture.SetFriction( lfriction );
        }

        float friction() {
            return lfriction;
        }
    }

protected:
    void createShapeFromData( VArray data, SVec2F pos = SVec2F( 0.0f ) ) {
        switch( type ) {
        case EP2DShapeType.BOX:
            b2PolygonShape sh = allocate!b2PolygonShape();
            float width = data[0].as!int / PIXELS_IN_METER;
            float height = data[1].as!int / PIXELS_IN_METER;

            sh.SetAsBox(
                width,
                height,
                b2vec2( pos.x, pos.y ),
                Math.degToRad( angle )
            );
            b2shape = sh;
            break;

        case EP2DShapeType.CIRCLE:
            b2CircleShape cs = allocate!b2CircleShape();
            b2Vec2 cpos = b2vec2( pos );
            cs.m_p.Set( cpos.x, cpos.y );
            cs.m_radius = data[0].as!int / PIXELS_IN_METER;
            b2shape = cs;
            break;

        case EP2DShapeType.EDGE:
            b2EdgeShape esh = allocate!b2EdgeShape();
            b2Vec2 vec0 = b2vec2( data[0].as!SVec2F );
            b2Vec2 vec3 = b2vec2( data[1].as!SVec2F );

            SVec2I delta = SVec2I( 0 );
            if ( vec0.x == vec3.x ) {
                delta.y = 1;
            } else if ( vec0.y == vec3.y ) {
                delta.x = 1;
            }

            esh.Set( vec0, vec3 );
            esh.m_vertex0.Set( vec0.x - delta.x, vec0.y + delta.y );
            esh.m_vertex3.Set( vec3.x + delta.x, vec3.y - delta.y );
            esh.m_hasVertex0 = true;
            esh.m_hasVertex3 = true;

            b2shape = esh;
            break;
        default:
            assert( false );
        }
    }

    VArray getShapeGeometryData() {
        VArray ldata;

        if ( b2PolygonShape sh = cast( b2PolygonShape )b2shape ) {
            ldata ~= SVariant( sh.m_vertices[2].x * PIXELS_IN_METER );
            ldata ~= SVariant( sh.m_vertices[2].y * PIXELS_IN_METER );
        } else if ( b2CircleShape sh = cast( b2CircleShape )b2shape ) {
            ldata ~= SVariant( sh.m_radius * PIXELS_IN_METER );
        }

        return ldata;
    }
}

class b2CJoint : CObject {
    mixin( TRegisterClass!b2CJoint );
public:
    b2CWorld world;

    EP2DJointType type;
    b2CBody bodyA;
    b2CBody bodyB;

    b2Joint b2joint;
    b2JointDef b2jointdef;
}

class b2CQueryCallback : b2QueryCallback {
    Array!ID foundBodies;

    override bool ReportFixture( b2Fixture* fixture ) {
        b2CBody body = Cast!b2CBody( fixture.GetBody().GetUserData() );
        if ( body ) {
            foundBodies ~= body.eventsHandler.id;
        }

        return true;
    }
}

class b2CRayCastSingleCallback : b2RayCastCallback {
    SP2DFilterData filter;
    SP2DRayCastResult result;
    
    override float32 ReportFixture( b2Fixture* fixture, b2Vec2 point, b2Vec2 normal, float32 fraction ) {
        if ( (fixture.GetFilterData().categoryBits & filter.mask) == 0 ) return -1;

        b2CBody body = Cast!b2CBody( fixture.m_body.GetUserData() );
        if ( !IsValid( body ) ) return -1;
        if ( body.eventsHandler.isNull ) return -1;

        result = SP2DRayCastResult( body.eventsHandler.id, r_b2vec2( point ), r_b2vec2( normal ) );

        return 0.0f;
    }
}

class b2CRayCastMultiCallback : b2RayCastCallback {
    SP2DFilterData filter;
    Array!SP2DRayCastResult results;
    
    override float32 ReportFixture( b2Fixture* fixture, b2Vec2 point, b2Vec2 normal, float32 fraction ) {
        if ( (fixture.GetFilterData().categoryBits & filter.mask) != 0 ) {
            results ~= SP2DRayCastResult( (cast( b2CBody )fixture.m_body.GetUserData()).id, r_b2vec2( point ), r_b2vec2( normal ) );
        }

        return fraction;

        //return 1.0f;
    }
}

class b2CPhydics2D : APhysics2D {
    mixin( TRegisterClass!b2CPhydics2D );
protected:
    b2CWorld lworld;

    b2CRayCastSingleCallback callbackSingle;
    b2CRayCastMultiCallback callbackMulti;
    b2CQueryCallback callbackQueryAABB;

    Array!SEndUpdateHandlerCall endUpdateCalls;

public:
    this() {
        callbackSingle = allocate!b2CRayCastSingleCallback();
        callbackMulti = allocate!b2CRayCastMultiCallback();
        callbackQueryAABB = allocate!b2CQueryCallback();
    }
    
    void addCollisionEvent( EP2DBodyEventType type, b2CBody from, b2CBody to ) {
        endUpdateCalls ~= SEndUpdateHandlerCall( type, from.id, to.id );
    }

override:
    void destroy( ID id ) {
        DestroyObject( id );
    }

    void update( float delta ) {
        if ( !bSimulate ) return;

        lworld.Step( delta, 8, 8 );
    }

    void postUpdate() {
        foreach ( _call; endUpdateCalls ) {
            b2CBody from = GetObjectByID!b2CBody( _call.from );
            b2CBody to = GetObjectByID!b2CBody( _call.to );

            if ( !from || !to ) continue;

            VArray args;
            args.resize( 1 );

            args[0] = GetObjectByID( to.eventsHandler.id );
            from.eventsHandler.call( _call.type, args );
        }

        endUpdateCalls.free();
    }

    SP2DRayCastResult raycast( SP2DRayCastInput input ) {
        assert( lworld !is null );

        callbackSingle.filter = input.filter;
        callbackSingle.result = SP2DRayCastResult();

        lworld.b2world.RayCast( callbackSingle, b2vec2( input.start ), b2vec2( input.end ) );
        return callbackSingle.result;
    }

    Array!SP2DRayCastResult raycast_multi( SP2DRayCastInput input ) {
        assert( lworld !is null );

        callbackMulti.filter = input.filter;
        callbackMulti.results.free();

        lworld.b2world.RayCast( callbackMulti, b2vec2( input.start ), b2vec2( input.end ) );
        return callbackMulti.results;
    }

    @property {
        void world( ID newWorld ) {
            b2CWorld nworld = GetObjectByID!b2CWorld( newWorld );
            assert( nworld );

            lworld = nworld;
        }

        ID world() {
            assert( lworld );

            return lworld.id;
        }
    }

    ID world_create() {
        return NewObject!b2CWorld( this ).id;
    }

    bool world_setProperty( ID id, EP2DWorldProperty property, var value ) {
        b2CWorld world = GetObjectByID!b2CWorld( id );
        assert( world );

        switch ( property ) {
        case EP2DWorldProperty.GRAVITY:
            world.gravity = value.as!SVec2F;
            break;

        default:
            log.error( "Not implemented world set property: ", property );
            return false;
        }

        return true;
    }

    var world_getProperty( ID id, EP2DWorldProperty property ) {
        b2CWorld world = GetObjectByID!b2CWorld( id );
        assert( world );

        switch ( property ) {
        case EP2DWorldProperty.GRAVITY:
            return var( world.gravity );

        default:
            log.error( "Not implemented world get property: ", property );
        }

        return var();
    }

    ID body_create( EP2DBodyType type ) {
        return NewObject!b2CBody( type, lworld ).id;
    }

    bool body_setProperty( ID id, EP2DBodyProperty property, var value ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        switch ( property ) {
        case EP2DBodyProperty.IS_BULLET:
            body.isBullet = value.as!bool;
            break;

        case EP2DBodyProperty.IS_FIXED_ROTATION:
            body.isFixedRotation = value.as!bool;
            break;

        case EP2DBodyProperty.MASS:
            body.mass = value.as!float;
            break;

        case EP2DBodyProperty.POSITION:
            body.position = value.as!SVec2F;
            break;

        case EP2DBodyProperty.ROTATION:
            body.rotation = value.as!float;
            break;

        case EP2DBodyProperty.GRIVITY_SCALE:
            body.gravityScale = value.as!float;
            break;

        case EP2DBodyProperty.FILTER_DATA:
            body.filterData = value.as!SP2DFilterData;
            break;

        case EP2DBodyProperty.LINEAR_VELOCITY:
            body.linearVelocity = value.as!SVec2F;
            break;

        case EP2DBodyProperty.ANGULAR_VELOCITY:
            body.angularVelocity = value.as!float;
            break;

        case EP2DBodyProperty.ANGULAR_DAMPING:
            body.angularDamping = value.as!float;
            break;

        default:
            log.error( "Not implemented body set property: ", property );
            return false;
        }

        return true;
    }

    var body_getProperty( ID id, EP2DBodyProperty property ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        switch ( property ) {
        case EP2DBodyProperty.IS_BULLET:
            return var( body.isBullet );

        case EP2DBodyProperty.IS_FIXED_ROTATION:
            return var( body.isFixedRotation );

        case EP2DBodyProperty.MASS:
            return var( body.mass );

        case EP2DBodyProperty.POSITION:
            return var( body.position );

        case EP2DBodyProperty.ROTATION:
            return var( body.rotation );

        case EP2DBodyProperty.GRIVITY_SCALE:
            return var( body.gravityScale );

        case EP2DBodyProperty.FILTER_DATA:
            return var( body.filterData );

        case EP2DBodyProperty.LINEAR_VELOCITY:
            return var( body.linearVelocity );

        case EP2DBodyProperty.ANGULAR_VELOCITY:
            return var( body.angularVelocity );

        case EP2DBodyProperty.ANGULAR_DAMPING:
            return var( body.angularDamping );

        case EP2DBodyProperty.COLLIDING_COUNT:
            return var( body.contactsNum );

        default:
            log.error( "Not implemented body get property: ", property );
        }

        return var();
    }

    void body_applyLinearImpulce( ID id, SVec2F impulce, SVec2F pos ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        body.b2body.ApplyLinearImpulse( b2vec2( impulce ), b2vec2( pos ), true );
    }

    void body_applyForce( ID id, SVec2F force, SVec2F pos ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        body.b2body.ApplyForce( b2vec2( force ), b2vec2( pos ), true );
    }

    void body_connectHandler( ID id, SCallable handler ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        body.eventsHandler = handler;
    }

    void body_addShapes( ID id, Array!ID shapes ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        foreach ( sid; shapes ) {
            b2CShape shape = GetObjectByID!b2CShape( sid );
            assert( shape );

            body.addShape( shape );
        }
    }

    void body_removeShapes( ID id, Array!ID shapes ) {
        b2CBody body = GetObjectByID!b2CBody( id );
        assert( body );

        foreach ( sid; shapes ) {
            b2CShape shape = GetObjectByID!b2CShape( sid );
            assert( shape );

            body.removeShape( shape );
        }
    }

    ID shape_create( EP2DShapeType type, VArray data ) {
        return NewObject!b2CShape( type, data ).id;
    }

    bool shape_setProperty( ID id, EP2DShapeProperty property, var value ) {
        b2CShape shape = GetObjectByID!b2CShape( id );
        assert( shape );

        switch ( property ) {
        case EP2DShapeProperty.IS_TRIGGER:
            shape.isTrigger = value.as!bool;
            break;

        case EP2DShapeProperty.FILTER_DATA:
            shape.filterData = value.as!SP2DFilterData;
            break;

        case EP2DShapeProperty.POSITION:
            shape.position = value.as!SVec2F;
            break;

        case EP2DShapeProperty.ROTATION:
            shape.rotation = value.as!float;
            break;

        case EP2DShapeProperty.FRICTION:
            shape.friction = value.as!float;
            break;

        default:
            log.error( "Not implemented shape set property: ", property );
            return false;
        }

        return true;
    }

    var shape_getProperty( ID id, EP2DShapeProperty property ) {
        b2CShape shape = GetObjectByID!b2CShape( id );
        assert( shape );

        switch ( property ) {
        case EP2DShapeProperty.IS_TRIGGER:
            return var( shape.isTrigger );

        case EP2DShapeProperty.FILTER_DATA:
            return var( shape.filterData );

        case EP2DShapeProperty.POSITION:
            return var( shape.position );

        case EP2DShapeProperty.ROTATION:
            return var( shape.rotation );

        case EP2DShapeProperty.FRICTION:
            return var( shape.friction );

        case EP2DShapeProperty.COLLIDING_COUNT:
            return var( shape.contactsNum );

        default:
            log.error( "Not implemented shape get property: ", property );
        }

        return var();
    }

    void shape_update( ID id, EP2DShapeType type, VArray data ) {
        b2CShape shape = GetObjectByID!b2CShape( id );
        assert( shape );

        shape.updateGeometryData( type, data );
    }

    void shape_move( ID id, SVec2F pos ) {
        b2CShape shape = GetObjectByID!b2CShape( id );
        assert( shape );

        shape.position = shape.position + pos;
    }

    SP2DDebugInfo debug_getInfo() { return SP2DDebugInfo(); }

    void debug_setDrawBackend( AP2DDebugDraw backend ) {
        lworld.debugRenderer.debugDrawBack = backend;
    }

    void debug_redraw() {
        if ( bDebugDraw ) {
            lworld.b2world.DrawDebugData();
        }
    }
}
