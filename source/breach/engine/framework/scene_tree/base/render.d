module engine.framework.scene_tree.base.render;

import engine.core.object;
import engine.core.string;

import engine.modules.physics_2d;

import engine.framework._debug;
import engine.framework.render.r2d;
import engine.framework.imgui;

class CSceneTreeRenderCamera : CObject {
    mixin( TRegisterClass!CSceneTreeRenderCamera );
public:
    String name;
    CR2D_View view;

    this( uint width, uint height ) {
        name = "main";
        view = newObject!CR2D_View( width, height );
    }

    ~this() {
        destroyObject( view );
    }
}

class CSceneTreeRender : CObject {
    mixin( TRegisterClass!CSceneTreeRender );
public:
    CR2D_Context context;

protected:
    CR2D_SceneProxy proxy;
    CRenderer2D pipeline;

    Array!CSceneTreeRenderCamera cameras;

public:
    this() {
        proxy = newObject!CR2D_SceneProxy();
        context = newObject!CR2D_Context();
        pipeline = newObject!CRenderer2D();

        //enum EC = 64.0f;
        //context.clearColor = SColorRGBA( EC / 256, EC / 256, EC / 256, 1.0f );
        context.clearColor = getColorFromHex( String( "#071018" ) );
    }

    ~this() {
        destroyObject( proxy );
        destroyObject( context );
        destroyObject( pipeline );
    }

    void registerCamera( CSceneTreeRenderCamera camera ) {
        cameras.append( camera );
    }
    
    void registerPrimitive( CR2D_Primitive primitive ) {
        proxy ~= primitive;
    }

    void preRender() {
        proxy.clear();
        cameras.free();
    }

    Dict!( CR2D_View, String ) render() {
        Dict!( CR2D_View, String ) ret;

        foreach ( camera; cameras ) {
            pipeline.render( proxy, context, camera.view );

            ret.set( camera.name, camera.view );
        }

        return ret;
    }

    void render( CR2D_View view ) {
        assert( view );

        pipeline.render( proxy, context, view );
    }

    void clear() {
        cameras.free();
    }
}
