module engine.framework.render.core.renderer;

public:
import engine.core.object;
import engine.core.containers;

import engine.modules.render_device;

import engine.framework.render.core.low_level;

/**
    Handler for custom scene proxy data,
*/
abstract class ARenderPrimitive : CObject {
    mixin( TRegisterClass!ARenderPrimitive );
}

/**
    Full information about rendering scene,
    handle primitives
*/
class CRenderSceneProxy : CObject {
    mixin( TRegisterClass!CRenderSceneProxy );
protected:
    Array!ARenderPrimitive lprimitives;

public:
    this() {}

    ~this() {
        /**
            Proxy is already outside of object pool,
            so "remove" call from primitive destructor
            doesn't exists
        */
        //clear();
    }

    void clear() {
        lprimitives.free(
            //( p ) {
                //destroyObject( p );
            //}
        );
    }

    void remove( ARenderPrimitive prim ) {
        lprimitives.remove( prim );
    }

    @property {
        Array!ARenderPrimitive primitives() {
            return lprimitives;
        }
    }

    auto opOpAssign( string op )( ARenderPrimitive elem )
    if ( op == "~" ) {
        if ( !isValid( elem ) ) {
            return this;
        }

        lprimitives.appendUnique( elem );
        
        return this;
    }

    int opApply( scope int delegate( ref ARenderPrimitive ) dg ) {
        return lprimitives.opApply( dg );
    }
}

/**
    Information about render position and
    local properties.

    Think this is some king of camera.
*/
class ARenderView : CObject {
    mixin( TRegisterClass!ARenderView );
public:
    // Render result image
    ID framebuffer;

protected:
    bool bExternalRenderTarget = false;

    uint lwidth;
    uint lheight;

public:
    this( ID rt, uint iwidth, uint iheight ) {
        framebuffer = rt;
        lwidth = iwidth;
        lheight = iheight;

        bExternalRenderTarget = true;
    }

    this( uint iwidth, uint iheight ) {
        lwidth = iwidth;
        lheight = iheight;

        framebuffer = RD.rt_create( lwidth, lheight );
    }

    ~this() {
        if ( !bExternalRenderTarget ) {
            RD.destroy( framebuffer );
        }
    }

    @property {
        void width( uint ival ) {
            if ( lwidth != ival ) {
                lwidth = ival;

                lupdateFramebufferResolution();
            }
        }

        uint width() {
            return lwidth;
        }

        void height( uint ival ) {
            if ( lheight != ival ) {
                lheight = ival;

                lupdateFramebufferResolution();
            }
        }

        uint height() {
            return lheight;
        }

        void resolution( SVec2I nsize ) {
            assert( nsize.x > 0 && nsize.y > 0 );

            if ( lwidth != nsize.x || lheight != nsize.y ) {
                lwidth = nsize.x;
                lheight = nsize.y;

                lupdateFramebufferResolution();
            }
        }

        SVec2I resolution() {
            return SVec2I( lwidth, lheight );
        }
    }

protected:
    void lupdateFramebufferResolution() {
        RD.rt_resize( framebuffer, lwidth, lheight );
    }
}

/**
    Information about rendering enviroment
*/
abstract class ARenderContext : CObject {
    mixin( TRegisterClass!ARenderContext );
public:
    SRENV env;

    SColorRGBA clearColor = EColors.BLACK;
    float depth = 1.0f;
    int stencil = 0;
}

/**
    Full rendering pipeline, handle all render passes
*/
class CRenderPipeline : CObject {
    mixin( TRegisterClass!CRenderPipeline );
public:
    void render( CRenderSceneProxy proxy, ARenderContext context, ARenderView view ) {}
}

