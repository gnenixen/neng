module engine.framework.scene_tree.n2d.physics_shape;

import engine.modules.physics_2d;

import engine.framework.scene_tree.n2d.node_2d;

class CShape2D : CNode2D {
    mixin( TRegisterClass!CShape2D );
public:
    CP2DShape shape;
    alias shape this;

protected:
    SVec2F psyncWPos = SVec2F( 0.0f );

public:
    this() { super(); }

    ~this() {
        DestroyObject( shape );
    }

protected:
    override void ptick( float delta ) {
        SVec2F wpos = transform.pos;

        // Somewhere position was updated
        if ( wpos != psyncWPos ) {
            shape.position = wpos;
        }

        transform.pos = psyncWPos;
    }

    override void psync() {
        SVec2F wpos = Cast!CNode2D( parent ).worldTransform.pos;

        transform.pos = shape.position - wpos;

        psyncWPos = transform.pos;
    }
}

class CBoxShape2D : CShape2D {
    mixin( TRegisterClass!CBoxShape2D );
protected:
    uint lwidth;
    uint lheight;

public:
    this( uint iwidth = 0, uint iheight = 0 ) {
        super();

        lwidth = iwidth;
        lheight = iheight;

        shape = newObject!CP2DBoxShape();
        vshape.update( lwidth, lheight );
    }

private:
    CP2DBoxShape vshape() {
        return Cast!CP2DBoxShape( shape );
    }
}

class CCircleShape2D : CShape2D {
    mixin( TRegisterClass!CCircleShape2D );
protected:
    float lradius = 0.0f;

public:
    this( float iradius = 0.0f ) {
        super();

        lradius = iradius;

        shape = newObject!CP2DCircleShape();
        vshape.update( lradius );
    }

private:
    CP2DCircleShape vshape() {
        return Cast!CP2DCircleShape( shape );
    }
}

class CEdgeShape2D : CShape2D {
    mixin( TRegisterClass!CEdgeShape2D );
protected:
    SVec2F vec0;
    SVec2F vec3;

public:
    this( SVec2F ivec0, SVec2F ivec3 ) {
        super();

        vec0 = ivec0;
        vec3 = ivec3;

        shape = newObject!CP2DEdgeShape();
        vshape.update( vec0, vec3 );
    }

private:
    CP2DEdgeShape vshape() {
        return Cast!CP2DEdgeShape( shape );
    }
}
