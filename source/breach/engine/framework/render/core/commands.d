module engine.framework.render.core.commands;

import engine.core.object : ID, ID_INVALID;
import engine.core.containers;
import engine.core.memory;
import engine.core.math;
import engine.core.utils.ustruct;

import engine.modules.render_device;

import engine.framework.render.core.low_level;

struct SRenderList {
    mixin( TRegisterStruct!SRenderList );
public:
    ID target = ID_INVALID;
    SRENV env;

    Array!IRenderCommand commands;

    T command( T, Args... )( Args args )
    if ( is( T : IRenderCommand ) ) {
        T com = allocate!T( args );
        commands ~= com;

        return com;
    }

    void execute() {
        foreach ( com; commands ) {
            com.exec( target, env );
            deallocate( com );
        }

        commands.free();
    }
}

interface IRenderCommand {
    void exec( ID target, SRENV env );
}

class CRC_Clear : IRenderCommand {
public:
    SColorRGBA color;

    this( SColorRGBA col ) {
        color = col;
    }

    void exec( ID target, SRENV env ) {
        SLowLevelRender.clear( target, color );
    }
}

class CRC_Draw : IRenderCommand {
public:
    Array!CRDrawRequest requests;

    ~this() {
        foreach ( req; requests ) {
            deallocate( req );
        }
        requests.free();
    }

    void exec( ID target, SRENV env ) {
        foreach ( req; requests ) {
            SLowLevelRender.render( target, env, req );
        }
    }

    CRDrawRequest request() {
        CRDrawRequest req = allocate!CRDrawRequest();
        requests ~= req;

        return req;
    }

    auto opOpAssign( string op )( CRDrawRequest req )
    if ( op == "~" ) {
        requests ~= req;
        return this;
    }
}

class CRC_BlitTwoTextures : IRenderCommand {
public:
    ID target2;

    this( ID itarget2 ) {
        target2 = itarget2;
    }

    void exec( ID target, SRENV env ) {}
}

class CRC_BlendOneTextures : IRenderCommand {
public:
    ID target1 = ID_INVALID;
    ID target2 = ID_INVALID;
    SRMaterial material;

    this( ID itarget1, ID itarget2, SRMaterial imaterial ) {
        target1 = itarget1;
        target2 = itarget2;
        material = imaterial;
    }

    void exec( ID target, SRENV env ) {
        RD.rt_set( target1 );
        RD.rs_set( env.rs );
        RD.dss_set( env.dss );
        
        Dict!(var, String) params;
        params["tex0"] = var( 0 );
        foreach ( k, v; material.params ) {
            params[k] = v;
        }

        RD.pipeline_set( material.shader, params );
        RD.texture_set( target2, 0 );
        RD.vao_set( SLowLevelRender.screenQuad.vao );
        RD.buffer_set( SLowLevelRender.screenQuad.ibo );

        RD.drawIndexed32( ERDDrawMode.TRIANGLE, SLowLevelRender.screenQuadDraw.offset, SLowLevelRender.screenQuadDraw.count, ERDDrawIndicesType.UINT );

        RD.rt_set();
    }
}

class CRC_BlendTwoTextures : IRenderCommand {
public:
    ID target1 = ID_INVALID;
    ID target2 = ID_INVALID;
    SRMaterial material;

    this( ID itarget1, ID itarget2, SRMaterial imaterial ) {
        target1 = itarget1;
        target2 = itarget2;
        material = imaterial;
    }

    void exec( ID target, SRENV env ) {
        RD.rt_set( target );
        RD.rs_set( env.rs );
        RD.dss_set( env.dss );

        Dict!(var, String) params;
        params["tex0"] = var( 0 );
        params["tex1"] = var( 2 );
        foreach ( k, v; material.params ) {
            params[k] = v;
        }
        
        RD.pipeline_set( material.shader, params );
        RD.texture_set( target1, 0 );
        RD.texture_set( target2, 2 );
        RD.vao_set( SLowLevelRender.screenQuad.vao );
        RD.buffer_set( SLowLevelRender.screenQuad.ibo );

        RD.drawIndexed32( ERDDrawMode.TRIANGLE, SLowLevelRender.screenQuadDraw.offset, SLowLevelRender.screenQuadDraw.count, ERDDrawIndicesType.UINT );

        RD.rt_set();
    }
}

class CRC_BlendThreeTextures : IRenderCommand {
public:
    ID target1 = ID_INVALID;
    ID target2 = ID_INVALID;
    ID target3 = ID_INVALID;
    SRMaterial material;

    this( ID itarget1, ID itarget2, ID itarget3, SRMaterial imaterial ) {
        target1 = itarget1;
        target2 = itarget2;
        target3 = itarget3;
        material = imaterial;
    }

    void exec( ID target, SRENV env ) {
        RD.rt_set( target );
        RD.rs_set( env.rs );
        RD.dss_set( env.dss );

        Dict!(var, String) params;
        params["tex0"] = var( 0 );
        params["tex1"] = var( 2 );
        params["tex2"] = var( 4 );
        foreach ( k, v; material.params ) {
            params[k] = v;
        }
        
        RD.pipeline_set( material.shader, params );
        RD.texture_set( target1, 0 );
        RD.texture_set( target2, 2 );
        RD.texture_set( target3, 4 );
        RD.vao_set( SLowLevelRender.screenQuad.vao );
        RD.buffer_set( SLowLevelRender.screenQuad.ibo );

        RD.drawIndexed32( ERDDrawMode.TRIANGLE, SLowLevelRender.screenQuadDraw.offset, SLowLevelRender.screenQuadDraw.count, ERDDrawIndicesType.UINT );

        RD.rt_set();
    }
}
