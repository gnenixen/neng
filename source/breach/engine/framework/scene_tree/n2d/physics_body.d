module engine.framework.scene_tree.n2d.physics_body;

public:
import engine.modules.physics_2d;

import engine.framework.scene_tree.n2d.node_2d;
import engine.framework.scene_tree.n2d.physics_shape;

struct SFrameInterpolator( T ) {
    T nextData;
    T currentData;
    real timeAhead = 0.0;

    real speedFactor = 1.0;
    real lastInsertDeltaTime = 0.0;
    real lastRemainingTimeAtInsert = 0.0;

    real idealFramesAhea = 3.0;
    real speedFactorBounds = 0.2;
    real sigmoidFactor = 0.05;
    real speedup = 10.0;
    uint fallbackAmount = 10;

    void reset( T current ) {
        nextData = current;
        currentData = current;
        timeAhead = 0.0;
        lastInsertDeltaTime = 0.0;
        lastRemainingTimeAtInsert = 0.0;
    }

    void push( T data, real delta ) {
        nextData = data;
        lastInsertDeltaTime = delta;
        lastRemainingTimeAtInsert = timeAhead;
        timeAhead += delta;
    }

    T getNextFrameData( real delta ) {
        if ( timeAhead > 0.0 ) {
            if ( timeAhead > fallbackAmount * lastInsertDeltaTime ) {
                delta = timeAhead - (fallbackAmount * 0.2 * lastInsertDeltaTime);
            } else {
                real ideal = delta * idealFramesAhea;
                real deltaIdeal = lastRemainingTimeAtInsert - ideal;
                real sigmoid = Math.tanh((deltaIdeal / delta) * sigmoidFactor);
                real desiredSpeedFactor = 1.0 + sigmoid * speedFactorBounds;

                speedFactor = Math.lerp( speedFactor, desiredSpeedFactor, speedup * delta );
                speedFactor = Math.clamp( speedFactor, 1.0 - speedFactorBounds, 1.0 + speedFactorBounds );
            }

            real adjustedDelta = Math.min( delta * speedFactor, timeAhead );
            real interpolationDactor = adjustedDelta / timeAhead;
            timeAhead -= adjustedDelta;

            currentData = currentData.interpolateWith( nextData, interpolationDactor );
        } else {
            speedFactor -= speedup * delta;
            speedFactor = Math.max( speedFactor, 1.0f - speedFactorBounds );
        }

        return currentData;
    }
}

class CPhysicsBody2D : CNode2D {
    mixin( TRegisterClass!CPhysicsBody2D );
public:
    CP2DBody lbody;
    alias lbody this;

    SVec2F psyncWPos = SVec2F( 0.0f );

public:
    this() {
        super();

        newChild.connect( &newChildHandler );
    }

    ~this() {
        if ( IsValid( lbody ) ) {
            DestroyObject( lbody );
        }
    }

    override void postInit() {
        GPhysics2D.body_connectHandler( lbody.pId, SCallable( rs!"pHandler", id ) );
    }

    void applyLinearImpulse( SVec2F impulce ) {
        lbody.applyLinearImpulse( impulce, lbody.worldCenter );
    }

protected:
    override void ptick( float delta ) {
        SVec2F wpos = worldTransform.pos;

        // Somewhere position was updated
        if ( wpos != psyncWPos ) {
            lbody.position = wpos;
        }

        transform.pos = psyncWPos;
    }

    override void psync() {
        SVec2F wpos = Cast!CNode2D( parent ).worldTransform.pos;

        transform.pos = lbody.position - wpos;

        psyncWPos = worldTransform.pos;
    }

    void newChildHandler( CNode node ) {
        CShape2D shape = Cast!CShape2D( node );

        if ( shape ){
            lbody.addShape( shape.shape );
        }
    }

    void pHandler( EP2DBodyEventType type, VArray args ) {}
}

class CDynamicBody2D : CPhysicsBody2D {
    mixin( TRegisterClass!CDynamicBody2D );
public:
    this() {
        super();
        lbody = NewObject!CP2DBody( EP2DBodyType.DYNAMIC );
    }
}

class CStaticBody2D : CPhysicsBody2D {
    mixin( TRegisterClass!CDynamicBody2D );
public:
    this() {
        super();
        lbody = NewObject!CP2DBody( EP2DBodyType.STATIC );
    }
}
