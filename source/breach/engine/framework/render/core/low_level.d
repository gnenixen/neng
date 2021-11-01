module engine.framework.render.core.low_level;

import engine.core.object : ID, ID_INVALID;
import engine.core.math;
import engine.core.log;
import engine.core.typedefs;
import engine.core.utils.ustruct;

import engine.modules.render_device;

struct SRGeometryRawData {
    ID vd = ID_INVALID;
    ID vbo = ID_INVALID;
    ID ibo = ID_INVALID;
    ID vao = ID_INVALID;
}

struct SRGeometryDrawData {
    SRGeometryRawData raw;
    alias raw this;

    long offset = 0;
    uint count = 0;
    ERDDrawIndicesType indtype = ERDDrawIndicesType.UINT;
}

struct SRMaterial {
    mixin( TRegisterStruct!SRMaterial );
public:
    ID shader = ID_INVALID;
    VDictT!String params;
}

struct SRENV {
    mixin( TRegisterStruct!SRENV );
public:
    SRDRasterState rs;
    SRDDepthStencilState dss;

    SRect viewport = SRect.rnull;

    // Default render material, and some
    // global for frame render params, like
    // view projection, time and more.
    // All params of this material will be
    // setted to every other material 
    // for SRDrawRequest
    SRMaterial material;
}

class CRDrawRequest {
public:
    ERDDrawMode mode = ERDDrawMode.TRIANGLE;
    // If is setted to SRect.rnull, then scrissors
    // will be disabled
    SRect scissors = SRect.rnull;

    Array!ID textures;
    SRMaterial material;
    SRGeometryDrawData geometry;
}

struct SRVertex2D {
    float x, y;
    float u, v;
    float r, g, b, a;
}

/*
   Some regular render function and global
   usable "constants", like vertex descriptor
*/
struct SLowLevelRender {
    enum uint[] SCREEN_QUAD_INDICES = [
        0, 1, 3,
        1, 2, 3
    ];

    enum float[] SCREEN_QUAD_VERTICES = [
        1.0f, -1.0f,   1.0f, 0.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f,   1.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f,   0.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        -1.0f, -1.0f,   0.0f, 0.0f,   1.0f, 1.0f, 1.0f, 1.0f,
    ];

    static {
        ID vd2d = ID_INVALID;
        SRGeometryRawData screenQuad;
        SRGeometryDrawData screenQuadDraw;

        ID blendShader = ID_INVALID;
    }

    static void initialize() {
        vd2d = RD.vd_create( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 2 * float.sizeof ),
            SRDVertexElement( 2, ERDPrimitiveType.FLOAT, 4, 8 * float.sizeof, 4 * float.sizeof )
        ) );

        screenQuad.vd = vd2d;
        screenQuad.vbo = RD.buffer_create( ERDBufferType.VERTEX, ERDBufferUpdate.STATIC );
        screenQuad.ibo = RD.buffer_create( ERDBufferType.INDEX, ERDBufferUpdate.STATIC );
        RD.buffer_subData( screenQuad.vbo, 0, SCREEN_QUAD_VERTICES.length * float.sizeof, SCREEN_QUAD_VERTICES.ptr );
        RD.buffer_subData( screenQuad.ibo, 0, SCREEN_QUAD_INDICES.length * float.sizeof, SCREEN_QUAD_INDICES.ptr );
        screenQuad.vao = RD.vao_create( screenQuad.vd, screenQuad.vbo, screenQuad.ibo );

        screenQuadDraw.raw = screenQuad;
        screenQuadDraw.count = SCREEN_QUAD_INDICES.length;

        blendShader = rdMakePipeline(
            rs!"res/framework/render_2d/blend_vertex.shader",
            rs!"res/framework/render_2d/blend_pixel.shader",
        );
    }

    static void clear( ID target, SColorRGBA color ) {
        RD.rt_set( target );
        RD.clear( color );
        RD.rt_set();
    }

    static void render( ID target, SRENV env, CRDrawRequest request ) {
        assert( request );

        RD.rt_set( target );
        RD.rs_set( env.rs );
        RD.dss_set( env.dss );

        if ( env.viewport == SRect.rnull ) {
            SVec2I targetRes = RD.rt_resolution( target );
            RD.viewport( 0, 0, targetRes.x, targetRes.y );
        } else {
            RD.viewport( cast( int )env.viewport.pos.x, cast( int )env.viewport.pos.y, cast( int )env.viewport.width, cast( int )env.viewport.height );
        }

        if ( request.geometry.vd == ID_INVALID ) {
            log.error( "Invalid VD for draw request!" );
            return;
        }

        if ( request.geometry.vbo == ID_INVALID ) {
            log.error( "Invalid VBO for draw request!" );
            return;
        }

        if ( request.geometry.ibo == ID_INVALID ) {
            log.error( "Invalid VAO for draw request!" );
            return;
        }

        if ( request.geometry.vao == ID_INVALID ) {
            log.error( "Invalid VAO for draw request!" );
            return;
        }

        ID material = request.material.shader != ID_INVALID ?
            request.material.shader :
            env.material.shader;
        SRGeometryDrawData geometry = request.geometry;

        foreach ( k, v; env.material.params ) {
            RD.pipeline_setParam( material, k, v );
        }

        foreach ( k, v; request.material.params ) {
            RD.pipeline_setParam( material, k, v );
        }

        RD.pipeline_set( material );
        foreach ( i, tex; request.textures ) {
            RD.texture_set( tex, cast( int )i );
        }
        RD.vao_set( geometry.vao );
        RD.buffer_set( geometry.ibo );

        if ( request.scissors != SRect.rnull ) {
            RD.scissor_enable( request.scissors );
        }

        RD.drawIndexed32( request.mode, geometry.offset, geometry.count, geometry.indtype );

        RD.rt_set();
        RD.rs_set();
        RD.dss_set();
        RD.scissor_disable();
    }
}
