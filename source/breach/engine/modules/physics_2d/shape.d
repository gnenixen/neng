module engine.modules.physics_2d.shape;

import engine.core.object;
import engine.core.typedefs;

import engine.modules.physics_2d.physics_2d;
import engine.modules.physics_2d.basic;

class CP2DShape : CP2DObject {
    mixin( TRegisterClass!CP2DShape );
public:
    void move( SVec2F pos ) {
        GPhysics2D.shape_move( pId, pos );
    }

    @property {
        void bTrigger( bool bEnabled ) { GPhysics2D.shape_setProperty( pId, EP2DShapeProperty.IS_TRIGGER, var( bEnabled ) ); }
        bool bTrigger() { return GPhysics2D.shape_getProperty( pId, EP2DShapeProperty.IS_TRIGGER ).as!bool; }

        void position( SVec2F npos ) { GPhysics2D.shape_setProperty( pId, EP2DShapeProperty.POSITION, var( npos ) ); }
        SVec2F position() { return GPhysics2D.shape_getProperty( pId, EP2DShapeProperty.POSITION ).as!SVec2F; }
    
        void rotation( float angle ) { GPhysics2D.shape_setProperty( pId, EP2DShapeProperty.ROTATION, var( angle ) ); }
        float rotation() { return GPhysics2D.shape_getProperty( pId, EP2DShapeProperty.ROTATION ).as!float; }

        void friction( float frict ) { GPhysics2D.shape_setProperty( pId, EP2DShapeProperty.FRICTION, var( frict ) ); }
        float friction() { return GPhysics2D.shape_getProperty( pId, EP2DShapeProperty.FRICTION ).as!float; }

        uint collidingCount() { return GPhysics2D.shape_getProperty( pId, EP2DShapeProperty.COLLIDING_COUNT ).as!uint; }
    }
}

class CP2DBoxShape : CP2DShape {
    mixin( TRegisterClass!CP2DBoxShape );
public:
    int width;
    int height;

    this() {
        super();
    }

    void update( int iwidth, int iheight ) {
        width = iwidth;
        height = iheight;

        VArray data;
        data ~= SVariant( width );
        data ~= SVariant( height );
        if ( pId != ID_INVALID ) {
            GPhysics2D.shape_update( pId, EP2DShapeType.BOX, data );
        } else {
            pId = GPhysics2D.shape_create( EP2DShapeType.BOX, data );
        }
    }
}

class CP2DCircleShape : CP2DShape {
    mixin( TRegisterClass!CP2DCircleShape );
public:
    float radius;

    this() {
        super();
    }

    void update( float irad ) {
        radius = irad;

        VArray data;
        data ~= SVariant( radius );
        if ( pId != ID_INVALID ) {
            GPhysics2D.shape_update( pId, EP2DShapeType.CIRCLE, data );
        } else {
            pId = GPhysics2D.shape_create( EP2DShapeType.CIRCLE, data );
        }
    }
}

class CP2DEdgeShape : CP2DShape {
    mixin( TRegisterClass!CP2DEdgeShape );
public:
    SVec2F vec0;
    SVec2F vec3;

    this() {
        super();
    }

    void update( SVec2F ivec0, SVec2F ivec3 ) {
        vec0 = ivec0;
        vec3 = ivec3;

        VArray data;
        data ~= var( vec0 );
        data ~= var( vec3 );
        if ( pId != ID_INVALID ) {
            GPhysics2D.shape_update( pId, EP2DShapeType.EDGE, data );
        } else {
            pId = GPhysics2D.shape_create( EP2DShapeType.EDGE, data );
        }
    }
}
