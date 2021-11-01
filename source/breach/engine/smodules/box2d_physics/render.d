module engine.smodules.box2d_physics.render;

import engine.thirdparty.dbox.common;
import engine.thirdparty.dbox.common.b2math;

import engine.core.math;

import engine.modules.physics_2d;

import engine.smodules.box2d_physics.physics_2d;

//Enum for sometimes...
enum float PIXELS_IN_METER = 100;

class b2CDebugRender : b2Draw {
public:
    AP2DDebugDraw debugDrawBack;

private:
    SVec2F tovec( b2Vec2 vec ) {
        return SVec2F( vec.x * PIXELS_IN_METER, -vec.y * PIXELS_IN_METER );
    }

    SColorRGBA torgba( b2Color color ) {
        return SColorRGBA( color.r, color.g, color.b, color.a );
    }

public:
override:
    void DrawPolygon( const(b2Vec2)* vertices, int32 vertexCount, b2Color color ) {
        if ( !debugDrawBack ) return;
        
        Array!SVec2F points;
        foreach ( i; 0..vertexCount ) {
            points ~= tovec( vertices[i] );
        }

        debugDrawBack.drawPolygon( points, torgba( color ) );
    }

    void DrawSolidPolygon( const(b2Vec2)* vertices, int32 vertexCount, b2Color color ) {
        DrawPolygon( vertices, vertexCount, color );
    }

    void DrawCircle( b2Vec2 center, float32 radius, b2Color color ) {
        if ( !debugDrawBack ) { return; }

        debugDrawBack.drawCircle( tovec( center ), SVec2F( 0.0f ), radius * PIXELS_IN_METER, torgba( color ) );
    }

    void DrawSolidCircle( b2Vec2 center, float32 radius, b2Vec2 axis, b2Color color ) {
        if ( !debugDrawBack ) { return; }

        debugDrawBack.drawCircle( tovec( center ), SVec2F( axis.x, axis.y ), radius * PIXELS_IN_METER, torgba( color ) );
    }

    void DrawSegment( b2Vec2 p1, b2Vec2 p2, b2Color color ) {
        if ( !debugDrawBack ) { return; }

        debugDrawBack.drawLine( tovec( p1 ), tovec( p2 ), torgba( color ) );
    }

    void DrawTransform( b2Transform xf ) {}
}

/*
class b2CDebugRender : b2Draw {
private:
    Array!CRender2D_SLine lines;
    uint pos = 0;

    CRender2D_SceneProxy proxy;
    CRender2D_View view;
    CRender2D_Context context;
    CRender2D_Pipeline pipeline;

public:
    this() {
        proxy = newObject!CRender2D_SceneProxy;
        view = newObject!CRender2D_View;
        context = newObject!CRender2D_Context;
        pipeline = newObject!CRender2D_Pipeline;
    
        context.clearColor = SColorRGBA( 0.0f, 0.0f, 0.0f, 0.0f );
    }

    ~this() {
        destroyObject( proxy );
        destroyObject( view );
        destroyObject( context );
        destroyObject( pipeline );
    }

    ID render( uint width, uint height ) {
        view.resolution = SVec2I( width, height );
        pipeline.render( proxy, context, view );
        
        foreach ( line; lines ) {
            line.bVisible = false;
        }

        pos = 0;

        return view.framebuffer;
    }

private:
    void addRenderLine( b2Vec2 start, b2Vec2 end, b2Color color ) {
        if ( pos >= lines.length ) {
            lines.reserve( 32, true );
            foreach ( i; 0..32 ) {
                CRender2D_SLine line = newObject!CRender2D_SLine;
                lines ~= line;
                proxy ~= line;                
            }
        }

        CRender2D_SLine line = lines[pos];
        line.bVisible = true;
        line.move(
            SVec2F( start.x * PIXELS_IN_METER, start.y * PIXELS_IN_METER ),
            SVec2F( end.x * PIXELS_IN_METER, end.y * PIXELS_IN_METER )
        );
        line.modulate = SColorRGBA( color.r, color.g, color.b, color.a );

        pos++;
    }

public:
override:
    void DrawPolygon( const(b2Vec2)* vertices, int32 vertexCount, b2Color color ) {
        foreach ( i; 0..vertexCount - 1 ) {
            addRenderLine( vertices[i], vertices[i + 1], color );
        }

        addRenderLine( vertices[vertexCount - 1], vertices[0], color );
    }

    void DrawSolidPolygon( const(b2Vec2)* vertices, int32 vertexCount, b2Color color ) {
        DrawPolygon( vertices, vertexCount, color );
    }

    void DrawCircle( b2Vec2 center, float32 radius, b2Color color ) {
        enum FRAGMENTS = 50;
        Array!( b2Vec2, FRAGMENTS ) points;

        float increment = 2.0f * PI / FRAGMENTS;
        for ( float currAngle = 0.0f; currAngle < 2.0f * PI; currAngle += increment ) {
            points ~= b2Vec2(
                radius * Math.cos( currAngle ) + center.x,
                radius * Math.sin( currAngle ) + center.y
            );
        }

        foreach ( i; 0..FRAGMENTS - 1 ) {
            addRenderLine( points[i], points[i + 1], color );
        }

        addRenderLine( points[FRAGMENTS - 1], points[0], color );
    }

    void DrawSolidCircle( b2Vec2 center, float32 radius, b2Vec2 axis, b2Color color ) {
        DrawCircle( center, radius, color );
    }

    void DrawSegment( b2Vec2 p1, b2Vec2 p2, b2Color color ) {
        addRenderLine( p1, p2, color );
    }

    void DrawTransform( b2Transform xf ) {}
}*/
