module engine.smodules.box2d_physics.world;

import engine.thirdparty.dbox;

import engine.core.memory;
import engine.core.containers;
import engine.core.log;

import engine.modules.physics_2d;

import engine.smodules.box2d_physics.render;

/*
//Enum for sometimes...
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

class b2CCollisionListener : b2ContactListener {
protected:
    b2CPhysWorld world;

public:
    this( b2CPhysWorld iworld ) {
        world = iworld;
    }
    override void BeginContact( b2Contact contact ) {
        ID idBodyA = Cast!ID( contact.GetFixtureA().GetBody().GetUserData() );
        ID idBodyB = Cast!ID( contact.GetFixtureB().GetBody().GetUserData() );
        ID idShapeA = Cast!ID( contact.GetFixtureA().GetUserData() );
        ID idShapeB = Cast!ID( contact.GetFixtureB().GetUserData() );

        b2CBody bodyA = getObjectByID!b2CBody( idBodyA );
        b2CBody bodyB = getObjectByID!b2CBody( idBodyB );
        b2CShape shapeA = getObjectByID!b2CShape( idShapeA );
        b2CShape shapeB = getObjectByID!b2CShape( idShapeB );

        if ( !isValid( bodyA ) )  { log.warning( "Invalid contact A body!" ); return; }
        if ( !isValid( bodyB ) )  { log.warning( "Invalid contact B body!" ); return; }
        if ( !isValid( shapeA ) )  { log.warning( "Invalid contact A shape!" ); return; }
        if ( !isValid( shapeB ) )  { log.warning( "Invalid contact B shape!" ); return; }

        bodyA.collidingBodiesInfo.set( idBodyB, bodyA.collidingBodiesInfo.get( idBodyB, 0 ) + 1 );
        shapeA.collidingShapesInfo.set( idShapeB, shapeA.collidingShapesInfo.get( idShapeB, 0 ) + 1 );
        bodyB.collidingBodiesInfo.set( idBodyA, bodyB.collidingBodiesInfo.get( idBodyA, 0 ) + 1 );
        shapeB.collidingShapesInfo.set( idShapeA, shapeB.collidingShapesInfo.get( idShapeA, 0 ) + 1 );

        if ( shapeA.collidingShapes.appendUnique( idShapeB ) ) {
            shapeA.contactsNum++;
        }
        
        if ( shapeB.collidingShapes.appendUnique( idShapeA ) ) {
            shapeB.contactsNum++;
        }

        if (
            bodyA.collidingBodies.appendUnique( idBodyB )
        ) {
            bodyA.contactsNum++;

            if ( bodyA.handler.id == ID_INVALID || bodyB.handler.id == ID_INVALID ) return;
            if ( shapeB.bSensor ) return;

            EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_BEGIN;
            if ( shapeA.bSensor ) {
                type = EP2DBodyEventType.TRIGGER_ENTER;
            }

            world.addCollisionEvent( type, bodyA, bodyB );
        }

        if (
            bodyB.collidingBodies.appendUnique( idBodyA )
        ) {
            bodyB.contactsNum++;

            if ( bodyA.handler.id == ID_INVALID || bodyB.handler.id == ID_INVALID ) return;
            if ( shapeA.bSensor ) return;

            EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_BEGIN;
            if ( shapeB.bSensor ) {
                type = EP2DBodyEventType.TRIGGER_ENTER;
            }

            world.addCollisionEvent( type, bodyB, bodyA );
        }
    }

    override void EndContact( b2Contact contact ) {
        ID idBodyA = Cast!ID( contact.GetFixtureA().GetBody().GetUserData() );
        ID idBodyB = Cast!ID( contact.GetFixtureB().GetBody().GetUserData() );
        ID idShapeA = Cast!ID( contact.GetFixtureA().GetUserData() );
        ID idShapeB = Cast!ID( contact.GetFixtureB().GetUserData() );

        b2CBody bodyA = getObjectByID!b2CBody( idBodyA );
        b2CBody bodyB = getObjectByID!b2CBody( idBodyB );
        b2CShape shapeA = getObjectByID!b2CShape( idShapeA );
        b2CShape shapeB = getObjectByID!b2CShape( idShapeB );

        if ( !isValid( bodyA ) ) {
            bodyB.collidingBodiesInfo.remove( idBodyA );
            bodyB.collidingBodies.remove( idBodyA );
        }

        if ( !isValid( bodyB ) ) {
            bodyA.collidingBodiesInfo.remove( idBodyB );
            bodyA.collidingBodies.remove( idBodyB );
        }

        if ( !isValid( shapeA ) )  {
            shapeB.collidingShapesInfo.remove( idShapeA );
            if ( shapeB.collidingShapes.remove( idShapeA ) ) {
                shapeB.contactsNum--;
            }
        }

        if ( !isValid( shapeB ) )  {
            shapeA.collidingShapesInfo.remove( idShapeB );
            if ( shapeA.collidingShapes.remove( idShapeB ) ) {
                shapeA.contactsNum--;
            }
        }

        if ( !isValid( bodyA ) || !isValid( bodyB ) || !isValid( shapeA ) || !isValid( shapeB ) ) return;

        uint collideCountBodyAtoB = bodyA.collidingBodiesInfo.get( idBodyB, 0 );
        uint collideCountShapeAtoB = shapeA.collidingShapesInfo.get( idShapeB, 0 );
        uint collideCountBodyBtoA = bodyB.collidingBodiesInfo.get( idBodyA, 0 );
        uint collideCountShapeBtoA = shapeB.collidingShapesInfo.get( idShapeA, 0 );

        assert( collideCountBodyAtoB != 0 );
        assert( collideCountShapeAtoB != 0 );
        assert( collideCountBodyBtoA != 0 );
        assert( collideCountShapeBtoA != 0 );

        bodyA.collidingBodiesInfo.set( idBodyB, collideCountBodyAtoB - 1 );
        shapeA.collidingShapesInfo.set( idShapeB, collideCountShapeAtoB - 1 );
        bodyB.collidingBodiesInfo.set( idBodyA, collideCountBodyBtoA - 1 );
        shapeB.collidingShapesInfo.set( idShapeA, collideCountShapeBtoA - 1 );

        collideCountBodyAtoB = bodyA.collidingBodiesInfo.get( idBodyB, 0 );
        collideCountShapeAtoB = shapeA.collidingShapesInfo.get( idShapeB, 0 );
        collideCountBodyBtoA = bodyB.collidingBodiesInfo.get( idBodyA, 0 );
        collideCountShapeBtoA = shapeB.collidingShapesInfo.get( idShapeA, 0 );

        if ( collideCountShapeAtoB == 0 ) {
            shapeA.collidingShapesInfo.remove( idShapeB );
            shapeA.collidingShapes.remove( idShapeB );
            shapeA.contactsNum--;
        }

        if ( collideCountShapeBtoA == 0 ) {
            shapeB.collidingShapesInfo.remove( idShapeA );
            shapeB.collidingShapes.remove( idShapeA );
            shapeB.contactsNum--;
        }
 
        if ( collideCountBodyAtoB != 0 ) return;
        else {
            bodyA.collidingBodiesInfo.remove( idBodyB );
        }

        if ( collideCountBodyBtoA != 0 ) return;
        else {
            bodyB.collidingBodiesInfo.remove( idBodyA );
        }

        if (
            bodyA.collidingBodies.remove( idBodyB )
        ) {
            bodyA.contactsNum--;

            if ( bodyA.handler.id == ID_INVALID || bodyB.handler.id == ID_INVALID ) return;
            if ( shapeB.bSensor ) return;

            EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_END;
            if ( shapeA.bSensor ) {
                type = EP2DBodyEventType.TRIGGER_OUT;
            }

            world.addCollisionEvent( type, bodyA, bodyB );
        }

        if (
            bodyB.collidingBodies.remove( idBodyA )
        ) {
            bodyB.contactsNum--;

            if ( bodyA.handler.id == ID_INVALID || bodyB.handler.id == ID_INVALID ) return;
            if ( shapeA.bSensor ) return;

            EP2DBodyEventType type = EP2DBodyEventType.COLLIDE_END;
            if ( shapeB.bSensor ) {
                type = EP2DBodyEventType.TRIGGER_OUT;
            }

            world.addCollisionEvent( type, bodyB, bodyA );
        }
    }
}

class b2CRayCastSingleCallback : b2RayCastCallback {
    SP2DFilterData filter;
    SP2DRayCastResult result;
    
    override float32 ReportFixture( b2Fixture* fixture, b2Vec2 point, b2Vec2 normal, float32 fraction ) {
        if ( (fixture.GetFilterData().categoryBits & filter.mask) == 0 ) return -1;

        b2CBody body = getObjectByID!b2CBody(cast(ID)fixture.m_body.GetUserData());
        if ( !isValid( body ) ) return -1;
        if ( body.handler.isNull ) return -1;

        result = SP2DRayCastResult( body.handler.id, r_b2vec2( point ), r_b2vec2( normal ) );

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
        assert( false );

        //return 1.0f;
    }
}

class b2CBody : CObject {
    mixin( TRegisterClass!b2CBody );
public:
    EP2DBodyType type;

    b2World* world;
    SVec2F pos;
    b2BodyDef b2bodydef;
    b2Body* b2body;
    Array!b2CShape shapes;
    Array!b2CJoint joints;
    SCallable handler;

    uint contactsNum = 0;
    Array!ID collidingBodies;
    Dict!( int, ID ) collidingBodiesInfo;

    this( EP2DBodyType itype, b2World* iworld ) {
        type = itype;
        world = iworld;

        switch( type ) {
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
    }

    ~this() {
        //shapes.free(
            //( sh ) { removeShape( sh ); }
        //);

        foreach ( k, v; collidingBodiesInfo ) {
            b2CBody bd = getObjectByID!b2CBody( k );
            if ( bd ) {
                bd.collidingBodiesInfo.remove( id );
                bd.collidingBodies.remove( id );
            }
        }

        joints.free(
            ( joint ) { destroyObject( joint ); }
        );
        
        world.DestroyBody( b2body );
    }

    override void postInit() {
        b2body.SetUserData( cast( void* )id );
    }

    void updateHandlers() {
        foreach ( hid; handlers ) {
            hid.call( r_b2vec2( b2body.GetPosition() ), Math.radToDeg( b2body.GetAngle() ) );
        }
    }

    void addShape( b2CShape shape ) {
        if ( !isValid( shape ) ) {
            log.error( "Invalid shape" );
            return;
        }

        if ( shape.shape is null ) {
            log.error( "Passed null b2Shape" );
            return;
        }

        b2Fixture* fixture;
        if ( type != EP2DBodyType.STATIC ) {
            b2FixtureDef b2fixdef;
            b2fixdef.shape = shape.shape;
            b2fixdef.density = 10.0f;
            b2fixdef.friction = 0.0f;
            fixture = b2body.CreateFixture( &b2fixdef );
        } else {
            //Static body density need to be 0
            fixture = b2body.CreateFixture( shape.shape, 0.0f );
        }

        shape.body = this;
        shape.fixture = fixture;
        shape.fixture.SetUserData( cast( void* )shape.id );

        shapes ~= shape;
    }

    void removeShape( b2CShape shape ) {
        if ( !shapes.has( shape ) ) return;

        if ( shape.fixture ) {
            b2body.DestroyFixture( shape.fixture );
        }
        shapes.remove( shape );
        shape.fixture = null;
    }

    void addJoint( b2CJoint ijoint ) {
        scope ( failure ) return;
            SError.msg( isValid( ijoint ), "Passed invalid joint" );
            SError.msg( !joints.has( ijoint ), "Passed joint already in joints of body" );
            SError.msg( ijoint.bodyA is this || ijoint.bodyB is this, "Passed joint not connected to this body" );

        joints ~= ijoint;
    }

    void removeJoint( b2CJoint ijoint ) {
        scope ( failure ) return;
            SError.msg( isValid( ijoint ), "Passed invalid joint" );
            SError.msg( joints.has( ijoint ), "Passed joint not in joints of body" );
            SError.msg( ijoint.bodyA is this || ijoint.bodyB is this, "Passed joint not connected to this body" );

        joints.remove( ijoint );
    }

    void addHandler( SCallable ihandler ) {
        handler = ihandler;
    }

    void onCollideBegin( b2CBody ibody ) {}
    void onCollideEnd( b2CBody ibody ) {}
}

class b2CShape : CObject {
    mixin( TRegisterClass!b2CShape );
public:
    EP2DShapeType type;
    b2CBody body;
    b2Shape shape;
    b2Fixture* fixture;
    float lastAngle = 0.0f;
    bool bSensor = false;
    b2Filter filter;

    uint contactsNum = 0;
    Array!ID collidingShapes;
    Dict!( int, ID ) collidingShapesInfo;
    VArray ldata;

    this( EP2DShapeType itype, VArray data ) {
        type = itype;
        ldata = data;
    }

    ~this() {
        foreach ( k, v; collidingShapesInfo ) {
            b2CShape sh = getObjectByID!b2CShape( k );
            if ( sh ) {
                sh.collidingShapesInfo.remove( id );
                if ( sh.collidingShapes.remove( id ) ) {
                    sh.contactsNum--;
                }
            }
        }

        if ( isValid( body ) ) { body.b2body.DestroyFixture( fixture ); }
        if ( shape ) { deallocate( shape ); }
    }

    override void postInit() {
        update( type, ldata );
    }

    void update( EP2DShapeType itype, VArray data, SVec2F pos = SVec2F( 0.0f ), float angle = 0.0f ) {
        assert( itype == type );

        if ( angle == float.nan ) {
            angle = lastAngle;
        } else {
            lastAngle = angle;
        }

        if ( body ) {
            filter = fixture.GetFilterData();
            body.b2body.DestroyFixture( fixture );
        }

        if ( shape ) {
            deallocate( shape );
        }

        createBox2DShape( data, pos, angle );

        if ( body ) {
            b2FixtureDef b2fixdef;
            b2fixdef.shape = shape;
            b2fixdef.density = 1.0f;
            b2fixdef.friction = 0.0f;
            b2fixdef.restitution = 0.0f;
            b2fixdef.isSensor = bSensor;
            b2fixdef.filter = filter;

            fixture = body.b2body.CreateFixture( &b2fixdef );
            fixture.SetUserData( cast( void* )id );
        }
    }

    void setPosition( SVec2F pos ) {
        assert( shape !is null );

        VArray data = getShapeData();
        update( type, data, pos );
        data.free();
    }

    SVec2F getPosition() {
        assert( shape !is null );

        SVec2F res = SVec2F( 0.0f );

        if ( b2PolygonShape sh = cast( b2PolygonShape )shape ) {
            res = r_b2vec2( sh.m_centroid );
        } else if ( b2CircleShape sh = cast( b2CircleShape )shape ) {
            res = r_b2vec2( sh.m_p );
        } else if( b2EdgeShape sh = cast( b2EdgeShape )shape ) {
            //res = r_b2vec2( sh. )
        }

        return res;
    }

    void rotate( float angle ) {
        if ( shape is null ) {
            return;
        }

        VArray data = getShapeData();
        update( type, data, getPosition(), angle );
        data.free();
    }

protected:
    void createBox2DShape( VArray data, SVec2F pos = SVec2F( 0.0f ), float angle = 0.0f ) {
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
            shape = sh;
            break;

        case EP2DShapeType.CIRCLE:
            b2CircleShape cs = allocate!b2CircleShape();
            b2Vec2 cpos = b2vec2( pos );
            cs.m_p.Set( cpos.x, cpos.y );
            cs.m_radius = data[0].as!int / PIXELS_IN_METER;
            shape = cs;
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

            shape = esh;
            break;
        default:
            assert( false );
        }
    }

    VArray getShapeData() {
        VArray data;

        if ( b2PolygonShape sh = cast( b2PolygonShape )shape ) {
            data ~= SVariant( sh.m_vertices[2].x * PIXELS_IN_METER );
            data ~= SVariant( sh.m_vertices[2].y * PIXELS_IN_METER );
        } else if ( b2CircleShape sh = cast( b2CircleShape )shape ) {
            data ~= SVariant( sh.m_radius * PIXELS_IN_METER );
        }

        return data;
    }
}

class b2CJoint : CObject {
    mixin( TRegisterClass!b2CJoint );
public:
    EP2DJointType type;
    b2CBody bodyA;
    b2CBody bodyB;

    b2World* world;
    b2Joint b2joint;
    b2JointDef gdef;

    this( b2World* iworld, EP2DJointType itype, b2CBody ia, b2CBody ib ) {
        world = iworld;
        type = itype;
        bodyA = ia;
        bodyB = ib;

        switch ( type ) {
        case EP2DJointType.MOTOR:
            b2MotorJointDef def = allocate!b2MotorJointDef();
            def.bodyA = bodyA.b2body;
            def.bodyB = bodyB.b2body;
            def.collideConnected = false;
            gdef = def;
            break;
        case EP2DJointType.REVOLUTE:
            b2RevoluteJointDef def = allocate!b2RevoluteJointDef();
            def.Initialize( bodyA.b2body, bodyB.b2body, bodyA.b2body.GetWorldCenter() );
            def.collideConnected = false;
            gdef = def;
            break;
        case EP2DJointType.WHEEL:
            b2WheelJointDef def = allocate!b2WheelJointDef();
            def.Initialize( bodyA.b2body, bodyB.b2body, bodyB.b2body.GetWorldCenter(), b2Vec2( 0.0f, 1.0f ) );
            //def.enableMotor = true;
            //def.motorSpeed = 0;
            //def.maxMotorTorque = 20;
            //def.frequencyHz = 4.0f;
            //def.dampingRatio = 0.7f;
            gdef = def;
            break;
        default:
            assert( false );
        }

        assert( gdef );
        b2joint = iworld.CreateJoint( gdef );
    }

    ~this() {
        bool bValidA = isValid( bodyA );
        bool bValidB = isValid( bodyB );

        if ( bValidA ) {
            bodyA.removeJoint( this );
        }

        if ( bValidB ) {
            bodyB.removeJoint( this );
        }

        world.DestroyJoint( b2joint );
        deallocate( gdef );
    }

    override void postInit() {
        bodyA.addJoint( this );
        bodyB.addJoint( this );
    }

    void updateAnchors( SVec2F a, SVec2F b ) {
        world.DestroyJoint( b2joint );

        switch ( type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJointDef def = cast( b2RevoluteJointDef )gdef;
            def.localAnchorA.Set( a.x / PIXELS_IN_METER, -a.y / PIXELS_IN_METER );
            def.localAnchorB.Set( b.x / PIXELS_IN_METER, -b.y / PIXELS_IN_METER );
            break;
        default:
            break;
        }

        b2joint = world.CreateJoint( gdef );
    }
}

class b2CQueryCallabck : b2QueryCallback {
    Array!ID foundBodies;

    override bool ReportFixture( b2Fixture* fixture ) {
        b2CBody body = getObjectByID!b2CBody(cast(ID)fixture.GetBody().GetUserData());
        if ( body ) {
            foundBodies ~= body.handler.id;
        }

        return true;
    }
}

struct SEndUpdateHandlerCall {
    EP2DBodyEventType type;
    ID from;
    ID to;
}

class b2CPhysWorld : APhysics2D {
private:
    b2Vec2 lgravity = b2Vec2( 0.0f, -9.8f * 2 );
    b2World* world;
    b2CCollisionListener listener;
    b2CDebugRender debugRender;

    b2CRayCastSingleCallback callbackSingle;
    b2CRayCastMultiCallback callbackMulti;
    b2CQueryCallabck callbackQueryAABB;

    Array!SEndUpdateHandlerCall endUpdateCalls;

public:
    this() {
        world = allocate!b2World( lgravity );
        listener = allocate!b2CCollisionListener( this );
        debugRender = allocate!b2CDebugRender();

        world.SetContactListener( listener );
        world.SetDebugDraw( debugRender );

        debugRender.SetFlags( b2Draw.e_shapeBit | b2Draw.e_jointBit );

        callbackSingle = allocate!b2CRayCastSingleCallback;
        callbackMulti = allocate!b2CRayCastMultiCallback;
        callbackQueryAABB = allocate!b2CQueryCallabck;
    }

    ~this() {
        deallocate( listener );
        deallocate( world );
    }

private:
    T uGetObject( T )( ID id ) {
        T obj = getObjectByID!T( id );
        if ( !obj ) {
            log.warning( "Invalid physics object id!" );
        }

        return obj;
    }

public:
    void addCollisionEvent( EP2DBodyEventType type, b2CBody from, b2CBody to ) {
        endUpdateCalls ~= SEndUpdateHandlerCall( type, from.id, to.id );
    }

override:
    void destroy( ID id ) {
        destroyObject( id );
    }

    void update( float delta ) {
        if ( !bSimulate ) {
            return;
        }

        world.Step( delta, 8, 8 );
    }

    void postUpdate() {
        foreach ( _call; endUpdateCalls ) {
            b2CBody from = getObjectByID!b2CBody( _call.from );
            b2CBody to = getObjectByID!b2CBody( _call.to );

            if ( !from || !to ) continue;

            VArray args;
            args.resize( 1 );

            args[0] = getObjectByID( to.handler.id );
            from.handler.call( _call.type, args );
        }

        endUpdateCalls.free();
    }

    SP2DRayCastResult raycast( SP2DRayCastInput input ) {
        callbackSingle.filter = input.filter;
        callbackSingle.result = SP2DRayCastResult();

        world.RayCast( callbackSingle, b2vec2( input.start ), b2vec2( input.end ) );
        return callbackSingle.result;
    }

    Array!SP2DRayCastResult raycast_multi( SVec2F start, SVec2F end ) {
        world.RayCast( callbackMulti, b2vec2( start ), b2vec2( end ) );
        return callbackMulti.result;
    }

    Array!ID query_aabb( SVec2F lower, SVec2F upper, SP2DFilterData filter = SP2DFilterData() ) {
        callbackQueryAABB.foundBodies.free();

        b2AABB aabb;
        aabb.lowerBound = b2vec2( lower );
        aabb.upperBound = b2vec2( upper );
        world.QueryAABB( callbackQueryAABB, aabb );

        return callbackQueryAABB.foundBodies;
    }

    ID body_create( EP2DBodyType type ) {
        b2CBody lbody = newObject!b2CBody( type, world );

        return lbody.id;
    }

    void body_setFilterData( ID id, SP2DFilterData filterData ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;
        
        b2Filter filter;
        filter.categoryBits = filterData.category;
        filter.maskBits = filterData.mask;

        for ( b2Fixture* f = lbody.b2body.GetFixtureList(); f; f = f.GetNext() ) {
            filter.groupIndex = f.GetFilterData().groupIndex;
            f.SetFilterData( filter );
        }
    }

    SP2DFilterData body_getFilterData( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return SP2DFilterData();

        SP2DFilterData data;

        b2Filter filter = lbody.b2body.GetFixtureList().GetFilterData();
        data.category = filter.categoryBits;
        data.mask = filter.maskBits;

        return data;
    }

    void body_setMass( ID id, float mass ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        lbody.b2body.SetMass( mass );
        assert( false );
    }

    float body_getMass( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return 0.0f;

        return lbody.b2body.GetMass();
    }

    void body_setGravityEnabled( ID id, bool bEnabled ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;
        
        return lbody.b2body.SetGravityScale( bEnabled ? 1.0f : 0.0f );
    }

    void body_setGravityScale( ID id, float scale ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        return lbody.b2body.SetGravityScale( scale );
    }

    void body_setIsBullet( ID id, bool bBullet ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        return lbody.b2body.SetBullet( bBullet );
    }
    
    bool body_getIsBullet( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return false;

        return lbody.b2body.IsBullet();
    }

    void body_setFixedRotation( ID id, bool bVal ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        lbody.b2body.SetFixedRotation( bVal );
    }
    
    bool body_getFixedRotation( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return false;

        return lbody.b2body.IsFixedRotation();
    }

    void body_setPosition( ID id, SVec2F pos ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        lbody.b2body.SetTransform(
            b2vec2( pos ),
            lbody.b2body.GetAngle()
        );
    }

    SVec2F body_getPosition( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return SVec2F( 0.0f );

        return r_b2vec2( lbody.b2body.GetPosition() );
    }

    SVec2F body_getWorldCenter( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return SVec2F( 0.0f );

        return r_b2vec2( lbody.b2body.GetWorldCenter() );
    }

    void body_setLinearVelocity( ID id, SVec2F velocity ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        lbody.b2body.SetLinearVelocity( b2vec2( velocity ) );
    }

    SVec2F body_getLinearVelocity( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return SVec2F( 0.0f );

        return r_b2vec2( lbody.b2body.GetLinearVelocity() );
    }

    void body_setAngularVelocity( ID id, float velocity ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        lbody.b2body.SetAngularVelocity( velocity * Math.PI );
    }

    float body_getAngularVelocity( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return 0.0f;

        return lbody.b2body.GetAngularVelocity();
    }

    void body_setAngularDamping( ID id, float damping ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        lbody.b2body.SetAngularDamping( damping );
    }

    float body_getAngularDamping( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return 0.0f;

        return lbody.b2body.GetAngularDamping();
    }

    void body_applyLinearImpulce( ID id, SVec2F impulce, SVec2F pos ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        lbody.b2body.ApplyLinearImpulse( b2vec2( impulce ), b2vec2( pos ), true );
    }

    void body_applyForce( ID id, SVec2F force, SVec2F pos ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return;

        lbody.b2body.ApplyForce( b2vec2( force ), b2vec2( pos ), true );
    }

    void body_setRotation( ID id, float angle ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        lbody.b2body.SetTransform( lbody.b2body.GetPosition(), SMath.degToRad( angle ) );
    }

    float body_getRotation( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return 0.0f;

        return 0.0f;//lbody.b2body.GetRotation();
    }

    uint body_getCollidingCount( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return 0;

        return lbody.contactsNum;
    }

    Array!ID body_getCollidingBodies( ID id ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) return Array!ID();

        return lbody.collidingBodies;
    }

    void body_connectHandler( ID id, SCallable handler ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        lbody.addHandler( handler );
    }

    void body_addShapes( ID id, Array!ID shapes ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        foreach ( shapeId; shapes ) {
            b2CShape shape = getObjectByID!b2CShape( shapeId );
            if ( !shape ) {
                continue;
            }

            lbody.addShape( shape );
        }
    }

    void body_removeShapes( ID id, Array!ID shapes ) {
        b2CBody lbody = uGetObject!b2CBody( id );
        if ( !lbody ) { return; }

        foreach ( shapeId; shapes ) {
            b2CShape shape = getObjectByID!b2CShape( shapeId );
            if ( !shape ) {
                continue;
            }

            lbody.removeShape( shape );
        }
    }



    ID shape_create( EP2DShapeType type, VArray data ) {
        return newObject!b2CShape( type, data ).id;
    }

    void shape_update( ID id, EP2DShapeType type, VArray data ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) { return; }

        shape.update( type, data );
    }

    void shape_setIsTrigger( ID id, bool bIsTrigger ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return;

        shape.bSensor = bIsTrigger;
        shape.fixture.SetSensor( bIsTrigger );
    }

    bool shape_getIsTrigger( ID id ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return false;

        return shape.bSensor;
    }

    void shape_setFrition( ID id, float friction ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return;

        assert( shape.fixture );

        shape.fixture.SetFriction( friction );
    }

    float shape_getFriction( ID id ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return 0.0f;

        return shape.fixture.GetFriction();
    }

    void shape_move( ID id, SVec2F pos ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) { return; }

        shape.setPosition( shape.getPosition() + pos );
    }

    uint shape_getCollidingCount( ID id ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) { return 0; }

        foreach ( sh; shape.collidingShapes ) {
            b2CShape osh = getObjectByID!b2CShape( sh );
            if ( !isValid( osh ) ) {
                shape.collidingShapesInfo.remove( sh );
                shape.collidingShapes.remove( sh );
                shape.contactsNum--;
            }
        }

        return shape.contactsNum;
    }

    void shape_setPosition( ID id, SVec2F pos ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) { return; }

        shape.setPosition( pos );
    }

    SVec2F shape_getPosition( ID id ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return SVec2F( 0.0f );

        return shape.getPosition();
    }

    void shape_setRotation( ID id, float angle ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return;

        shape.rotate( angle );
    }

    float shape_getRotation( ID id ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return 0.0f;

        return 0.0f;
    }

    void shape_setFilterData( SP2DFilterData filter ) {
        b2CShape shape = uGetObject!b2CShape( id );
        if ( !shape ) return;

        shape.fixture.GetFilterData().categoryBits = filter.category;
        shape.fixture.GetFilterData().maskBits = filter.mask;
    }



    ID joint_create( EP2DJointType type, ID bodyA, ID bodyB ) {
        b2CBody lbodyA = uGetObject!b2CBody( bodyA );
        b2CBody lbodyB = uGetObject!b2CBody( bodyB );
        if ( !lbodyA || !lbodyB ) { return ID_INVALID; }

        return newObject!b2CJoint( world, type, lbodyA, lbodyB ).id;
    }

    void joint_setAnchors( ID id, SVec2F a, SVec2F b ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) return;

        joint.updateAnchors( a, b );
    }

    void joint_revolute_enableMotor( ID id, bool bEnabled ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            j.EnableMotor( bEnabled );
            break;
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            j.EnableMotor( bEnabled );
            break;
        default:
            break;
        }
    }

    bool joint_revolute_isMotorEnabled( ID id ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return false; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            return j.IsMotorEnabled();
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            return j.IsMotorEnabled();
        default:
            break;
        }

        return false;
    }

    void joint_revolute_setMotorSpeed( ID id, float speed ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            j.SetMotorSpeed( speed );
            break;
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            j.SetMotorSpeed( speed );
            break;
        default:
            log.warning( "Invalid joint type!" );
            break;    
        }
    }

    float joint_revolute_getMotorSpeed( ID id ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return 0.0f; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            return j.GetMotorSpeed();
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            return j.GetMotorSpeed();
        default:
            break;    
        }

        return 0;
    }

    void joint_revolute_setMaxMotorTorque( ID id, float torque ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            j.SetMaxMotorTorque( torque );
            break;
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            j.SetMaxMotorTorque( torque );
            break;
        default:
            break;    
        }
    }

    float joint_revolute_getMaxMotorTorque( ID id ) {
        b2CJoint joint = uGetObject!b2CJoint( id );
        if ( !joint ) { return 0.0f; }

        switch ( joint.type ) {
        case EP2DJointType.REVOLUTE:
            b2RevoluteJoint j = cast( b2RevoluteJoint )joint.b2joint;
            return j.GetMaxMotorTorque();
        case EP2DJointType.WHEEL:
            b2WheelJoint j = cast( b2WheelJoint )joint.b2joint;
            return j.GetMaxMotorTorque();
        default:
            break;    
        }

        return 0.0f;
    }

    @property {
        void gravity( SVec2F vec ) {
            lgravity = b2vec2( vec );
            world.SetGravity( lgravity );
        }

        SVec2F gravity() {
            return r_b2vec2( lgravity );
        }
    }

    SP2DDebugInfo debug_getInfo() {
        return SP2DDebugInfo();
    }

    void debug_setDrawBackend( AP2DDebugDraw backend ) {
        debugRender.debugDrawBack = backend;
        debugDraw = backend;
    }

    void debug_redraw() {
        if ( bDebugDraw ) {
            world.DrawDebugData();
        }
    }
}*/
