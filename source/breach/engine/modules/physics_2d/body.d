module engine.modules.physics_2d.body;

import engine.core.math;
import engine.core.object;
import engine.core.signal;
import engine.core.log;

import engine.modules.physics_2d.physics_2d;
import engine.modules.physics_2d.basic;
import engine.modules.physics_2d.shape;

class CP2DBody : CP2DObject {
    mixin( TRegisterClass!CP2DBody );
protected:
    EP2DBodyType ltype;

    Array!ID shapes;

public:
    this( EP2DBodyType itype ) {
        ltype = itype;
        pId = GPhysics2D.body_create( ltype );
    }

    SVec2F worldCenter() {
        return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.WORLD_CENTER ).as!SVec2F;
    }

    void addShape( CP2DShape shape ) {
        if ( !IsValid( shape ) ) {
            log.warning( "Passed invalid shape!" );
            return;
        }

        shapes ~= shape.pId;
        GPhysics2D.body_addShapes( pId, toArray( shape.pId ) );
    }

    void removeShape( CP2DShape shape ) {
        if ( !IsValid( shape ) ) {
            log.warning( "Passed invalid shape!" );
            return;
        }

        if ( shapes.has( shape.pId ) ) {
            GPhysics2D.body_removeShapes( pId, toArray( shape.pId ) );
            shapes.remove( shape.pId );
        }
    }

    void applyLinearImpulse( SVec2F impulce, SVec2F pos ) {
        GPhysics2D.body_applyLinearImpulce( pId, impulce, pos );
    }

    void applyLinearImpulse( SVec2F impulce ) {
        GPhysics2D.body_applyLinearImpulce( pId, impulce, position );
    }

    void applyForce( SVec2F force, SVec2F pos ) {
        GPhysics2D.body_applyForce( pId, force, pos );
    }

    @property {
        void bFixedRotation( bool bEnabled ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.IS_FIXED_ROTATION, var( bEnabled ) ); }
        bool bFixedRotation() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.IS_FIXED_ROTATION ).as!bool; }

        void bIsBullet( bool bBullet ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.IS_BULLET, var( bBullet ) ); }
        bool bIsBullet() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.IS_BULLET ).as!bool; }

        void position( SVec2F npos ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.POSITION, var( npos ) ); }
        SVec2F position() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.POSITION ).as!SVec2F; }
        
        void rotation( float angle ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.ROTATION, var( angle ) ); }
        float rotation() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.ROTATION ).as!float; }

        void filterData( SP2DFilterData fdata ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.FILTER_DATA, var( fdata ) ); }
        SP2DFilterData filterData() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.FILTER_DATA ).as!SP2DFilterData; }

        void linearVelocity( SVec2F velocity ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.LINEAR_VELOCITY, var( velocity ) ); }
        SVec2F linearVelocity() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.LINEAR_VELOCITY ).as!SVec2F; }
    
        void mass( float nmass ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.MASS, var( nmass ) ); }
        float mass() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.MASS ).as!float; }

        void gravityScale( float scale ) { GPhysics2D.body_setProperty( pId, EP2DBodyProperty.GRIVITY_SCALE, var( scale ) ); }

        uint collidingCount() { return GPhysics2D.body_getProperty( pId, EP2DBodyProperty.COLLIDING_COUNT ).as!uint; }
    }
}
