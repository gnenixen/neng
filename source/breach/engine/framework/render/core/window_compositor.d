module engine.framework.render.core.window_compositor;

import engine.core.math;
import engine.core.log;

import engine.modules.display_server;
import engine.modules.render_device;

import engine.framework.window;

private {
    enum uint[] WINCOM_RECT_INDICES = [
        0, 1, 3,
        1, 2, 3
    ];

    enum float[] WINCOM_RECT_VERTICES = [
         1.0f, -1.0f, 0.0f,   1.0f, 0.0f,
         1.0f,  1.0f, 0.0f,   1.0f, 1.0f,
        -1.0f,  1.0f, 0.0f,   0.0f, 1.0f,
        -1.0f, -1.0f, 0.0f,   0.0f, 0.0f
    ];
}

class CWindowCompositor : CObject {
    mixin( TRegisterClass!( CWindowCompositor, Singleton ) );
private:
    ID pipeline;
    ID vao;
    ID ibo;

public:
    this() {
        pipeline = rdMakePipeline(
            rs!"res/framework/render_core/wincom_vertex.shader",
            rs!"res/framework/render_core/wincom_pixel.shader"
        );

        VertexDescriptor descriptor;
        ID vbo;
        ID vd;

        descriptor ~= SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 3, 5 * float.sizeof, 0 );
        descriptor ~= SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, 5 * float.sizeof, 3 * float.sizeof );

        vbo = RD.buffer_create( ERDBufferType.VERTEX, ERDBufferUpdate.STATIC );
        ibo = RD.buffer_create( ERDBufferType.INDEX, ERDBufferUpdate.STATIC );

        RD.buffer_setData( vbo, WINCOM_RECT_VERTICES.length * float.sizeof, WINCOM_RECT_VERTICES.ptr );
        RD.buffer_setData( ibo, WINCOM_RECT_INDICES.length * float.sizeof, WINCOM_RECT_INDICES.ptr );

        vd = RD.vd_create( descriptor );
        vao = RD.vao_create( vd, vbo, ibo );
    }

    void drawToWindowInRect(
        CWindow win,
        ID framebuffer,
        SColorRGBA clear = EColors.BLACK,
        SRect rect = SRect()
    ) {
        if ( !IsValid( win ) ) {
            log.warning( "Passed invalid window!" );
            return;
        }

        SVec2I rpos = rect.pos.tov!int;
        SVec2I rsize = SVec2I( rect.width, rect.height );
        if ( rsize.x < 1 || rsize.y < 1 ) {
            rsize = win.size;
        }

        SVec2I fbSize = RD.rt_resolution( framebuffer );

        float deviceRatio = rsize.x / cast( float )rsize.y;
        float virtualRatio = fbSize.x / cast( float )fbSize.y;

        SVec2F scaleFactor = SVec2F( 1.0f );
        if ( virtualRatio > deviceRatio ) {
            scaleFactor.y = deviceRatio / virtualRatio;
        } else {
            scaleFactor.x = virtualRatio / deviceRatio;
        }

        Dict!( var, String ) params;
        params["scaleFactor"] = scaleFactor;

        win.makeContextCurrent();
            RD.viewport( rpos.x, rpos.y, rsize.x, rsize.y );
            RD.clear( clear );

            RD.texture_set( framebuffer );
            RD.pipeline_set( pipeline, params );
            RD.vao_set( vao );
            RD.buffer_set( ibo );

            RD.drawIndexed32( ERDDrawMode.TRIANGLE, 0, WINCOM_RECT_INDICES.length );
        win.swapBuffers();
    }

    void drawToFramebufferWithAspectRatio( ID view, ID frame, SColorRGBA clear = EColors.BLACK ) {
        SVec2I rsize = RD.rt_resolution( view );
        SVec2I fbSize = RD.rt_resolution( frame );

        float deviceRatio = rsize.x / cast( float )rsize.y;
        float virtualRatio = fbSize.x / cast( float )fbSize.y;

        SVec2F scaleFactor = SVec2F( 1.0f );
        if ( virtualRatio > deviceRatio ) {
            scaleFactor.y = deviceRatio / virtualRatio;
        } else {
            scaleFactor.x = virtualRatio / deviceRatio;
        }

        scaleFactor.y *= -1;

        Dict!( var, String ) params;
        params["scaleFactor"] = scaleFactor;

        RD.rt_set( view );
            RD.viewport( 0, 0, rsize.x, rsize.y );
            RD.clear( clear );

            RD.texture_set( frame );
            RD.pipeline_set( pipeline, params );
            RD.vao_set( vao );
            RD.buffer_set( ibo );

            RD.drawIndexed32( ERDDrawMode.TRIANGLE, 0, WINCOM_RECT_INDICES.length );
        RD.rt_set();
    }
}

static __gshared pragma( inline, true ) {
    CWindowCompositor GWindowCompositor() { return CWindowCompositor.sig; }
}
