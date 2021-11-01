module engine.framework.scene_tree.n2d.physics_joint;

import engine.modules.physics_2d;

import engine.framework.scene_tree.n2d.node_2d;
import engine.framework.scene_tree.n2d.physics_body;

/*
class CJoint2D : CNode2D {
    mixin( TRegisterClass!CJoint2D );
public:
    CP2DJoint ljoint;

public:
    this() {
        super();

        newChild.connect( &newChildHandler );
    }

    this( CPhysicsBody2D a, CPhysicsBody2D b ) {
        super();

        newChild.connect( &newChildHandler );
    
        if ( a !is null && b !is null ) {
            ljoint = createJoint( a, b );
        }
    }

    ~this() {
        destroyObject( ljoint );
    }

protected:
    abstract CP2DJoint createJoint( CPhysicsBody2D bodyA, CPhysicsBody2D bodyB );
    
    void newChildHandler( CNode node ) {
        assert( lchildren.length <= 2 );
        assert( Cast!CPhysicsBody2D( node ) );

        if ( ljoint ) return;

        if ( lchildren.length == 2 ) {
            CPhysicsBody2D bodyA = Cast!CPhysicsBody2D( lchildren[0] );
            CPhysicsBody2D bodyB = Cast!CPhysicsBody2D( lchildren[1] );

            ljoint = createJoint( bodyA, bodyB );
        }
    }
}

class CRevoluteJoint2D : CJoint2D {
    mixin( TRegisterClass!CRevoluteJoint2D );
protected:
    override CP2DJoint createJoint( CPhysicsBody2D bodyA, CPhysicsBody2D bodyB ) {
        return newObject!CP2DRevoluteJoint( bodyA.lbody, bodyB.lbody );
    }

public:
    this( CPhysicsBody2D a = null, CPhysicsBody2D b = null ) {
        super( a, b );
    }

    void updateAnchors( SVec2F a, SVec2F b ) {
        vjoint.updateAnchors( a, b );
    }

protected:
    CP2DRevoluteJoint vjoint() {
        return Cast!CP2DRevoluteJoint( ljoint );
    }
}*/
