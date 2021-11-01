module engine.framework.postprocess;

import engine.framework.render.r2d;

class CRPP_Pipeline : CRenderPipeline {
    mixin( TRegisterClass!CRPP_Pipeline );
public:
    CR2D_View lview;

protected:
    CR2D_Sprite sprite;

public:
    this() {
        lview = newObject!CR2D_View( 1920, 1080 );
        sprite = newObject!CR2D_Sprite();
    }

    override void render( CRenderSceneProxy proxy, ARenderContext context, ARenderView view ) {
        CRPP_Context rppContext = Cast!CRPP_Context( context );

        lview.resolution = view.resolution;

        ARenderView last = view;
        foreach ( i, shader; rppContext.shaders ) {
            rppContext.views[i].resolution = view.resolution;
            RD.rt_set( rppContext.views[i].framebuffer );

            RD.pipeline_set( shader );
            RD.pipeline_setParam( shader, rs!"resolution", var( view.resolution ) );
            foreach ( name, value; rppContext.params ) {
                RD.pipeline_setParam( shader, name, value );
            }

            RD.texture_set( last.framebuffer );
            RD.vao_set( sprite.raw.vao );
            RD.buffer_set( sprite.raw.ibo );

            RD.drawIndexed32( ERDDrawMode.TRIANGLE, 0, 6, ERDDrawIndicesType.UINT );
            RD.rt_set();

            last = rppContext.views[i];
        }

        lview = rppContext.views[rppContext.views.length - 1];
    }
}

class CRPP_Context : ARenderContext {
    mixin( TRegisterClass!CRPP_Context );
public:
    Array!ID shaders;
    Array!CR2D_View views;
    Dict!( var, String ) params;
}

class CPostProcess : CObject {
    mixin( TRegisterClass!CPostProcess );
protected:
    CRPP_Pipeline pipeline;
    CRPP_Context context;

public:
    this() {
        pipeline = newObject!CRPP_Pipeline();
        context = newObject!CRPP_Context();
    }

    void add( ID shader ) {
        context.shaders ~= shader;
        context.views ~= newObject!CR2D_View( 1920, 1080 );
    }

    void set( String param, var value ) {
        context.params.set( param, value );
    }

    CR2D_View render( ARenderView iview ) {
        pipeline.render( null, context, iview );
        return pipeline.lview;
    }
}

