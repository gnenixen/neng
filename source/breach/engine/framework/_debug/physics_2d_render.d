module engine.framework._debug.physics_2d_render;

import engine.modules.physics_2d;

import engine.framework.render.r2d;

class CP2DDebugRenderBackRD : AP2DDebugDraw {
    mixin( TRegisterClass!CP2DDebugRenderBackRD );
private:
    Array!CR2D_SLine lines;
    uint pos;

    CR2D_SceneProxy proxy;
    CR2D_Context context;
    CDebugRenderer2D pipeline;
    CR2D_LineBatcher batcher;

public:
    this() {
        proxy = newObject!CR2D_SceneProxy();
        context = newObject!CR2D_Context();
        pipeline = newObject!CDebugRenderer2D();
        batcher = newObject!CR2D_LineBatcher();

        proxy ~= batcher;
    }

    ~this() {
        destroyObject( proxy );
        destroyObject( context );
        destroyObject( pipeline );
        destroyObject( batcher );
    }

    public void render( CR2D_View view ) {
        batcher.end();
        pipeline.render( proxy, context, view );
        batcher.begin();
    }

private:
    void addRenderLine( SVec2F start, SVec2F end, SColorRGBA color ) {
        batcher.line( start, end, color );
    }

public:
override:
    void drawPolygon( Array!( SVec2F ) points, SColorRGBA color ) {
        if ( points.length == 0 ) { return; }
        
        foreach ( i; 0..points.length - 1 ) {
            addRenderLine( points[i], points[i + 1], color );
        }

        addRenderLine( points[points.length - 1], points[0], color );
    }

    void drawCircle( SVec2F pos, SVec2F axis, float radius, SColorRGBA color ) {
        enum FRAGMENTS = 50;
        Array!( SVec2F, FRAGMENTS ) points;

        float increment = 2.0f * PI / FRAGMENTS;
        for ( float currAngle = 0.0f; currAngle < 2.0f * PI; currAngle += increment ) {
            points ~= SVec2F(
                radius * Math.cos( currAngle ) + pos.x,
                radius * Math.sin( currAngle ) + pos.y
            );
        }

        foreach ( i; 0..FRAGMENTS - 1 ) {
            addRenderLine( points[i], points[i + 1], color );
        }

        addRenderLine( points[FRAGMENTS - 1], points[0], color );
        addRenderLine( pos, pos + axis * radius, color );
    }

    void drawLine( SVec2F start, SVec2F end, SColorRGBA color ) {
        addRenderLine( start, end, color );
    }
}
