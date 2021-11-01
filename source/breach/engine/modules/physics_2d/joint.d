module engine.modules.physics_2d.joint;

import engine.core.object;

import engine.modules.physics_2d.world;
import engine.modules.physics_2d.basic;
import engine.modules.physics_2d.body;

/*
class CP2DJoint : CP2DObject {
    mixin( TRegisterClass!CP2DJoint );
protected:
    EP2DJointType ltype;
    CP2DBody bodyA;
    CP2DBody bodyB;

public:
    this( EP2DJointType itype, CP2DBody ibodyA, CP2DBody ibodyB ) {
        assert( isValid( ibodyA ) && isValid( ibodyB ) );

        ltype = itype;
        bodyA = ibodyA;
        bodyB = ibodyB;

        pId = GPhysics2D.joint_create( itype, bodyA.pId, bodyB.pId );
    }
}

class CP2DMotorJoint : CP2DJoint {
    mixin( TRegisterClass!CP2DMotorJoint );
public:
    this( CP2DBody ibodyA, CP2DBody ibodyB ) {
        super( EP2DJointType.MOTOR, ibodyA, ibodyB );
    }
}

class CP2DRevoluteJoint : CP2DJoint {
    mixin( TRegisterClass!CP2DRevoluteJoint );
public:
    this( CP2DBody ibodyA, CP2DBody ibodyB ) {
        super( EP2DJointType.REVOLUTE, ibodyA, ibodyB );
    }

    void updateAnchors( SVec2F a, SVec2F b ) {
        GPhysics2D.joint_setAnchors( pId, a, b );
    }

    @property {
        void bIsMotorEnabled( bool bEnable ) { GPhysics2D.joint_revolute_enableMotor( pId, bEnable ); }
        bool bIsMotorEnabled() { return GPhysics2D.joint_revolute_isMotorEnabled( pId ); }

        void motorSpeed( float speed ) { GPhysics2D.joint_revolute_setMotorSpeed( pId, speed ); }
        float motorSpeed() { return GPhysics2D.joint_revolute_getMotorSpeed( pId ); }

        void maxMotorTorque( float torque ) { GPhysics2D.joint_revolute_setMaxMotorTorque( pId, torque ); }
        float maxMotorTorque() { return GPhysics2D.joint_revolute_getMaxMotorTorque( pId ); }
    }
}

class CP2DWheelJoint : CP2DJoint {
    mixin( TRegisterClass!CP2DWheelJoint );
public:
    this( CP2DBody ibodyA, CP2DBody ibodyB ) {
        super( EP2DJointType.WHEEL, ibodyA, ibodyB );
    }

    @property {
        void bIsMotorEnabled( bool bEnable ) { GPhysics2D.joint_revolute_enableMotor( pId, bEnable ); }
        bool bIsMotorEnabled() { return GPhysics2D.joint_revolute_isMotorEnabled( pId ); }

        void motorSpeed( float speed ) { GPhysics2D.joint_revolute_setMotorSpeed( pId, speed ); }
        float motorSpeed() { return GPhysics2D.joint_revolute_getMotorSpeed( pId ); }

        void maxMotorTorque( float torque ) { GPhysics2D.joint_revolute_setMaxMotorTorque( pId, torque ); }
        float maxMotorTorque() { return GPhysics2D.joint_revolute_getMaxMotorTorque( pId ); }
    }
}*/
