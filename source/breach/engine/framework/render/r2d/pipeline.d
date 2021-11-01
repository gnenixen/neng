module engine.framework.render.r2d.pipeline;

import engine.core.resource;

import engine.modules.render_device;

public:
import engine.framework.render.core;

class CR2D_View : ARenderView {
    mixin( TRegisterClass!CR2D_View );
public:
    SVec2F position = SVec2F( 0.0f );
    float scale = 1.0f;

    this( ID rt, uint iwidth, uint iheight ) {
        super( rt, iwidth, iheight );
    }

    this( uint iwidth, uint iheight ) {
        super( iwidth, iheight );
    }

    SMat4F projection() {
        return SMat4F.ortho(
            0.0f,
            lwidth * scale,
            0.0f,
            lheight * scale,
            -1.0f,
            1.0f
        );
    }
}

class CR2D_Context : ARenderContext {
    mixin( TRegisterClass!CR2D_Context );
public:
    SColorRGBA ambient = EColors.WHITE;

public:
    this() {
        super();

        env.material.shader = rdMakePipeline(
            rs!"res/framework/render_2d/vertex.shader",
            rs!"res/framework/render_2d/pixel.shader",
        );
    }
}

class CR2D_SceneProxy : CRenderSceneProxy {
    mixin( TRegisterClass!CR2D_SceneProxy );
public:
    Array!CR2D_Primitive base;
    Array!CR2D_Primitive lights;

    override void clear() {
        super.clear();

        base.free();
        lights.free();
    }

    auto opOpAssign( string op )( ARenderPrimitive elem )
    if ( op == "~" ) {
        if ( !IsValid( elem ) ) return this;

        if ( !Cast!CR2D_Primitive( elem ) ) return this;
        
        if ( Cast!CR2D_Light( elem ) ) {
            lights.appendUnique( Cast!CR2D_Light( elem ) );
        } else {
            base.appendUnique( Cast!CR2D_Primitive( elem ) );
        }
        
        return this;
    }
    
}

class CR2D_Primitive : ARenderPrimitive {
    mixin( TRegisterClass!CR2D_Primitive );
public:
    /** 
        For gui rendring, primitives with given
        var with true will render in front layer
        and will not move relative to the camera.
        In regular mean - some king of gui.
    */
    bool bRenderInCameraSpace = false;

    /**
        Renders on debug_pass, upside of whole
        render result
    */
    bool bDebug = false;

    bool bVisible = true;

    SColorRGBA modulate = SColorRGBA( 1.0f );
    
    CTexture texture;
    CTexture normal;
    CTexture selfIllumination;
    ID rtTexture;

    SRect scissors = SRect.rnull;

    Array!float vertices;
    Array!uint indices;

    ERDDrawMode mode = ERDDrawMode.TRIANGLE;
    SRGeometryDrawData raw;
    SRMaterial material;

protected:
    bool lbDirty = false;
    size_t verticesCount = 0;
    size_t indicesCount = 0;

    SVec2F lposition = SVec2F( 0.0f );
    SVec2F lscale = SVec2F( 1.0f );
    float langle = 0.0f;

public:
    this( ERDBufferUpdate updateType = ERDBufferUpdate.DYNAMIC ) {
        vertices.policity.bMemsetNullOnFree = false;
        indices.policity.bMemsetNullOnFree = false;

        raw.vbo = RD.buffer_create( ERDBufferType.VERTEX, updateType );
        raw.ibo = RD.buffer_create( ERDBufferType.INDEX, updateType );
    }

    ~this() {
        RD.destroy( raw.vd );
        RD.destroy( raw.vbo );
        RD.destroy( raw.ibo );
        RD.destroy( raw.vao );
    }

    void setup( VertexDescriptor descriptor ) {
        raw.vd = RD.vd_create( descriptor );
        raw.vao = RD.vao_create( raw.vd, raw.vbo, raw.ibo );
    }

    void setup( ID descriptor ) {
        raw.vd = descriptor;
        raw.vao = RD.vao_create( raw.vd, raw.vbo, raw.ibo );
    }

    void rebuild() {
        lbDirty = false;
        lrebuild();
        meshUpdate();
    }

    void reset() {
        vertices.free();
        indices.free();

        lbDirty = true;
    }

    void fillDrawRequest( CRDrawRequest request, SVec2F cameraPos ) {
        if ( isDirty ) rebuild();

        // Setup some regular values for draw request
        SVec2F rposition = position;

        if ( !bRenderInCameraSpace ) {
            rposition -= cameraPos;
        }

        SMat4F model = SMat4F.identity;
        model.scale( scale.x, scale.y, 0.0f );
        model.translate( rposition.x, rposition.y, 0.0f );

        request.mode = mode;
        request.geometry.raw = raw.raw;
        request.geometry.offset = raw.offset;
        request.geometry.count = raw.count != 0 ? raw.count : cast( int )indices.length;

        request.scissors = scissors;

        // Don't fill texture, because only list knew what do they want from us

        request.material.shader = material.shader;
        request.material.params.set( rs!"model", var( model ) );
        request.material.params.set( rs!"modulate", var( modulate ) );

        foreach ( k, v; material.params ) {
            request.material.params.set( k, v );
        }
    }

protected:
    void markDirty() {
        lbDirty = true;
    }
    
    void meshUpdate() {
        RD.buffer_subData( raw.vbo, 0, vertices.length * float.sizeof, vertices.ptr );
        RD.buffer_subData( raw.ibo, 0, indices.length * uint.sizeof, indices.ptr);

        verticesCount = vertices.length;
        indicesCount = indices.length;
    }

    void lrebuild() {}

public @property pragma( inline, true ):
    bool isDirty() => lbDirty || verticesCount != vertices.length || indicesCount != indices.length;

    SVec2F position() => lposition;
    SVec2F scale() => lscale;
    float angle() => langle;

    void position( SVec2F npos ) { markDirty(); lposition = npos; }
    void scale( SVec2F nscale ) { markDirty(); lscale = nscale; }
    void angle( float nangle ) { markDirty(); langle = nangle; }
}

private {
    enum uint[] SPRITE_INDICES = [
        0, 1, 3,
        1, 2, 3
    ];

    enum float[] SPRITE_VERTICES = [
        1.0f, 0.0f,   1.0f, 0.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f,   1.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 1.0f,   0.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f,   0.0f, 0.0f,   1.0f, 1.0f, 1.0f, 1.0f,
    ];
}


class CR2D_Sprite : CR2D_Primitive {
    mixin( TRegisterClass!CR2D_Sprite );
public:
    this() {
        super( ERDBufferUpdate.STATIC );
        setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 2 * float.sizeof ),
            SRDVertexElement( 2, ERDPrimitiveType.FLOAT, 4, 8 * float.sizeof, 4 * float.sizeof )
        ) );

        foreach ( i; SPRITE_INDICES ) {
            indices ~= i;
        }

        foreach ( i; SPRITE_VERTICES ) {
            vertices ~= i;
        }

        rebuild();
    }

    override @property {
        SVec2F scale() {
            if ( !isResourceValid( texture ) ) {
                return lscale;
            } else {
                return SVec2F( lscale.x * texture.width, lscale.y * texture.height );
            }
        }

        void scale( SVec2F isc ) {
            super.scale = isc;
        }
    }
}

class CR2D_Light : CR2D_Sprite {
    mixin( TRegisterClass!CR2D_Light );
public:
    SColorRGBA color = EColors.WHITE;

public:
    this() {
        super();
    }
}

class CR2D_SelfIllumination : CR2D_Sprite {
    mixin( TRegisterClass!CR2D_SelfIllumination );
public:
    this() { super(); }
}

class CR2D_Shape : CR2D_Primitive {
    mixin( TRegisterClass!CR2D_Shape );
public:
    this() {
        super( ERDBufferUpdate.DYNAMIC );

        bDebug = true;
        modulate = EColors.GREEN;

        material.shader = rdMakePipeline(
            rs!"res/framework/render_2d/debug_vertex.shader",
            rs!"res/framework/render_2d/debug_pixel.shader" 
        );
    }
}

class CR2D_SLine : CR2D_Shape {
    mixin( TRegisterClass!CR2D_SLine );
private:
    SVec2F lstart;
    SVec2F lend;

public:
    this() {
        super();

        mode = ERDDrawMode.LINE;

        vertices.reserve( 6 );
        foreach ( i; 0..6 ) {
            vertices ~= 0.0f;
        }

        indices ~= 0;
        indices ~= 1;
        indices ~= 2;

        setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, 2 * float.sizeof, 0 ),
        ) );

        rebuild();
    }

protected:
    override void lrebuild() {
        vertices.free();

        vertices ~= lstart.x;
        vertices ~= lstart.y;

        vertices ~= lend.x;
        vertices ~= lend.y;

        vertices ~= lstart.x;
        vertices ~= lstart.y;
    }

public:
    @property {
        SVec2F start() { return lstart; }
        SVec2F end() { return lend; }

        void start( SVec2F point ) {
            lstart = point;
            markDirty();
        }

        void end( SVec2F point ) {
            lend = point;
            markDirty();
        }
    }
}

class CR2D_LineBatcher : CR2D_Primitive {
    mixin( TRegisterClass!CR2D_LineBatcher );
protected:
    uint count = 0;

public:
    this() {
        super( ERDBufferUpdate.STREAM );

        bDebug = true;
        mode = ERDDrawMode.LINE;
        modulate = EColors.GREEN;

        setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, 6 * float.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 4, 6 * float.sizeof, 2 * float.sizeof ),
        ) );

        material.shader = rdMakePipeline(
            rs!"res/framework/render_2d/debug_vertex.shader",
            rs!"res/framework/render_2d/debug_pixel.shader" 
        );
    }

    void begin() {
        vertices.free();
        indices.free();
        count = 0;
    }

    void end() {
        rebuild();
    }

    void line( SVec2F start, SVec2F end, SColorRGBA modulate ) {
        void appendColor() {
            vertices ~= modulate.r;
            vertices ~= modulate.g;
            vertices ~= modulate.b;
            vertices ~= modulate.a;
        }

        vertices ~= start.x;
        vertices ~= start.y;
        appendColor();

        vertices ~= end.x;
        vertices ~= end.y;
        appendColor();
        
        vertices ~= start.x;
        vertices ~= start.y;
        appendColor();
        
        vertices ~= end.x;
        vertices ~= end.y;
        appendColor();

        indices ~= 0 + 4 * count;
        indices ~= 1 + 4 * count;
        indices ~= 3 + 4 * count;
        indices ~= 1 + 4 * count;
        indices ~= 2 + 4 * count;
        indices ~= 3 + 4 * count;

        count++;
    }
}

class CRenderer2D : CRenderPipeline {
    mixin( TRegisterClass!CRenderer2D );
public:
    SRMaterial matLight;
    SRMaterial matBlur;
    SRMaterial matBloom;

protected:
    /* Basic render targets, that applys textures from proxy */
    ID rtBaseColor = ID_INVALID;
    ID rtNormal = ID_INVALID;
    ID rtSelfIllumination = ID_INVALID;
    ID rtLightMask = ID_INVALID;

    /* Blending/mixing targets */

    // For Gausian blur self illumination
    ID rtBlurTemp = ID_INVALID;

    // Applyed light to base color, based on rtLightMask and rtNormal
    ID rtApplyedLight = ID_INVALID;

    // Handle resolution for compare with new one render view
    SVec2I rtResolution = SVec2I( 1, 1 );

    // Basic render lists
    SRenderList rlBaseColor;
    SRenderList rlNormal;
    SRenderList rlLightMask;
    SRenderList rlSeflIllumination;

    SRenderList rlBlur;
    SRenderList rlApplyLight;
    SRenderList rlToView;

public:
    this() {
        super();

        matLight.shader = rdMakePipeline(
            rs!"res/framework/render/r2d/basic_vertex.shader",
            rs!"res/framework/render/r2d/light_pixel.shader",
        );

        matBlur.shader = rdMakePipeline(
            rs!"res/framework/render/r2d/basic_vertex.shader",
            rs!"res/framework/render/r2d/blur_pixel.shader",
        );

        matBloom.shader = rdMakePipeline(
            rs!"res/framework/render/r2d/basic_vertex.shader",
            rs!"res/framework/render/r2d/bloom_pixel.shader",
        );

        // Targets
        rtBaseColor = RD.rt_create( 1, 1 );
        rtNormal = RD.rt_create( 1, 1 );
        rtSelfIllumination = RD.rt_create( 1, 1 );
        rtLightMask = RD.rt_create( 1, 1 );

        rtBlurTemp = RD.rt_create( 1, 1 );
        rtApplyedLight = RD.rt_create( 1, 1 );

        // Lists
        rlBaseColor.target = rtBaseColor;
        rlNormal.target = rtNormal;
        rlSeflIllumination.target = rtSelfIllumination;
        rlLightMask.target = rtLightMask;

        rlBlur.target = rtBlurTemp;
        rlApplyLight.target = rtApplyedLight;
    }

    override void render( CRenderSceneProxy proxy, ARenderContext context, ARenderView view ) {
        CR2D_SceneProxy proxy2D = Cast!CR2D_SceneProxy( proxy );
        CR2D_Context context2D = Cast!CR2D_Context( context );
        CR2D_View view2D = Cast!CR2D_View( view );

        assert( proxy2D );
        assert( context2D );
        assert( view2D );

        SVec2I resolution = SVec2I( view.width, view.height );

        resizeTargets( resolution );
        setupTargets( context2D.env.material.shader, view2D.projection, view2D.framebuffer, resolution );

        rlBaseColor.command!CRC_Clear( context.clearColor );
        CRC_Draw rlBaseColorDrawCMD = rlBaseColor.command!CRC_Draw();
        fillDrawCommand(
            rlBaseColorDrawCMD, view2D.position, proxy2D.base,
            ( CR2D_Primitive primitive ) { return isResourceValid( primitive.texture ) || primitive.rtTexture; },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {
                request.textures ~= primitive.texture !is null ? primitive.texture : primitive.rtTexture;
            }
        );

        rlNormal.command!CRC_Clear( SColorRGBA( 0.5, 0.5, 1.0, 1.0 ) );
        CRC_Draw rlNormalDrawCMD = rlNormal.command!CRC_Draw();
        fillDrawCommand(
            rlNormalDrawCMD, view2D.position, proxy2D.base,
            ( CR2D_Primitive primitive ) { return isResourceValid( primitive.normal ); },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {
                request.textures ~= primitive.normal;
            }
        );

        rlSeflIllumination.command!CRC_Clear( context.clearColor );
        CRC_Draw rlSelfIlluminationDrawCMD = rlSeflIllumination.command!CRC_Draw();
        fillDrawCommand(
            rlSelfIlluminationDrawCMD, view2D.position, proxy2D.base,
            ( CR2D_Primitive primitive ) { return isResourceValid( primitive.selfIllumination ); },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {
                request.textures ~= primitive.selfIllumination;
            }
        );

        rlLightMask.command!CRC_Clear( context.clearColor );
        CRC_Draw rlLightMaskDrawCMD = rlLightMask.command!CRC_Draw();
        fillDrawCommand(
            rlLightMaskDrawCMD, view2D.position, proxy2D.lights,
            ( CR2D_Primitive primitive ) { return isResourceValid( primitive.texture ) || primitive.rtTexture; },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {
                request.textures ~= primitive.texture !is null ? primitive.texture : primitive.rtTexture;
            }
        );

        rlBlur.command!CRC_BlendOneTextures( rtBlurTemp, rtSelfIllumination, matBlur );
        rlApplyLight.command!CRC_BlendThreeTextures( rtBaseColor, rtNormal, rtLightMask, matLight );
        rlToView.command!CRC_BlendTwoTextures( rtApplyedLight, rtBlurTemp, matBloom );

        foreach ( i, _light; proxy2D.lights ) {
            CR2D_Light light = Cast!CR2D_Light( _light );

            String paramPosName = String( "lPoses[", i, "]" );
            String paramColorName = String( "lColors[", i, "]" );

            matLight.params[paramPosName] = var( light.position );
            matLight.params[paramColorName] = var( light.color );
        }

        matLight.params["lNum"] = var( cast( int )proxy2D.lights.length );
        matLight.params["ambient"] = var( context2D.ambient );

        /* Render every base target */
        rlBaseColor.execute();
        rlNormal.execute();
        rlSeflIllumination.execute();
        rlLightMask.execute();

        /* Blend everything */
        rlBlur.execute();
        rlApplyLight.execute();
        rlToView.execute();
    }

protected:
    void resizeTargets( SVec2I nsize ) {
        if ( rtResolution == nsize ) return;
        
        rtResolution = nsize;

        RD.rt_resize( rtBaseColor, nsize.x, nsize.y );
        RD.rt_resize( rtNormal, nsize.x, nsize.y );
        RD.rt_resize( rtSelfIllumination, nsize.x, nsize.y );
        RD.rt_resize( rtLightMask, nsize.x, nsize.y );

        RD.rt_resize( rtBlurTemp, nsize.x, nsize.y );
        RD.rt_resize( rtApplyedLight, nsize.x, nsize.y );

        rlBaseColor.target = rtBaseColor;
        rlNormal.target = rtNormal;
        rlSeflIllumination.target = rtSelfIllumination;
        rlLightMask.target = rtLightMask;

        rlBlur.target = rtBlurTemp;
        rlApplyLight.target = rtApplyedLight;
    }

    void setupTargets( ID shader, SMat4F projection, ID viewRT, SVec2I resolution ) {
        rlToView.target = viewRT;

        rlBaseColor.env.material.shader = shader;
        rlNormal.env.material.shader = shader;
        rlLightMask.env.material.shader = shader;
        rlSeflIllumination.env.material.shader = shader;

        rlBaseColor.env.material.params.set( rs!"projection", var( projection ) );
        rlNormal.env.material.params.set( rs!"projection", var( projection ) );
        rlLightMask.env.material.params.set( rs!"projection", var( projection ) );
        rlSeflIllumination.env.material.params.set( rs!"projection", var( projection ) );

        rlBaseColor.env.material.params.set( rs!"resolution", var( resolution ) );
        rlNormal.env.material.params.set( rs!"resolution", var( resolution ) );
        rlLightMask.env.material.params.set( rs!"resolution", var( resolution ) );
        rlSeflIllumination.env.material.params.set( rs!"resolution", var( resolution ) );
    }

    void fillDrawCommand( T )( CRC_Draw cmd, SVec2F camPos, Array!T primitives, bool function( CR2D_Primitive ) checkIsValid, void function( CRDrawRequest, CR2D_Primitive ) subSetup )
    if ( is( T : CR2D_Primitive ) ) {
        foreach ( prim; primitives ) {
            if ( !prim.bVisible || prim.bDebug ) continue;

            if ( checkIsValid( prim ) ) {
                CRDrawRequest req = cmd.request();
                prim.fillDrawRequest( req, camPos );

                subSetup( req, prim );
            }
        }
    }
}

class CGUIRenderer2D : CRenderPipeline {
    mixin( TRegisterClass!CGUIRenderer2D );
protected:
    SRenderList rlBaseColor;

public:
    this() {
        super();
    }

    override void render( CRenderSceneProxy proxy, ARenderContext context, ARenderView view ) {
        CR2D_SceneProxy proxy2D = Cast!CR2D_SceneProxy( proxy );
        CR2D_Context context2D = Cast!CR2D_Context( context );
        CR2D_View view2D = Cast!CR2D_View( view );

        assert( proxy2D );
        assert( context2D );
        assert( view2D );

        rlBaseColor.target = view2D.framebuffer;
        rlBaseColor.env.material.shader = context2D.env.material.shader;
        rlBaseColor.env.material.params.set( rs!"projection", var( view2D.projection ) );

        CRC_Draw rlBaseColorDrawCMD = rlBaseColor.command!CRC_Draw();
        fillDrawCommand(
            rlBaseColorDrawCMD, view2D.position, proxy2D.base,
            ( CR2D_Primitive primitive ) { return isResourceValid( primitive.texture ) || primitive.rtTexture; },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {
                request.textures ~= primitive.texture !is null ? primitive.texture : primitive.rtTexture;
            }
        );

        rlBaseColor.execute();
    }

protected:
    void fillDrawCommand( T )( CRC_Draw cmd, SVec2F camPos, Array!T primitives, bool function( CR2D_Primitive ) checkIsValid, void function( CRDrawRequest, CR2D_Primitive ) subSetup )
    if ( is( T : CR2D_Primitive ) ) {
        foreach ( prim; primitives ) {
            if ( !prim.bVisible || prim.bDebug ) continue;

            if ( checkIsValid( prim ) ) {
                CRDrawRequest req = cmd.request();
                prim.fillDrawRequest( req, camPos );

                subSetup( req, prim );
            }
        }
    }
}

class CDebugRenderer2D : CRenderPipeline {
    mixin( TRegisterClass!CDebugRenderer2D );
protected:
    SRenderList rlBaseColor;

public:
    this() {
        super();
    }

    override void render( CRenderSceneProxy proxy, ARenderContext context, ARenderView view ) {
        CR2D_SceneProxy proxy2D = Cast!CR2D_SceneProxy( proxy );
        CR2D_Context context2D = Cast!CR2D_Context( context );
        CR2D_View view2D = Cast!CR2D_View( view );

        assert( proxy2D );
        assert( context2D );
        assert( view2D );

        rlBaseColor.target = view2D.framebuffer;
        rlBaseColor.env.rs = SRDRasterState( false, ERDWinding.CCW, ERDFace.BACK, ERDRasterMode.LINE );
        rlBaseColor.env.material.shader = context2D.env.material.shader;
        rlBaseColor.env.material.params.set( rs!"projection", var( view2D.projection ) );

        CRC_Draw rlBaseColorDrawCMD = rlBaseColor.command!CRC_Draw();
        fillDrawCommand(
            rlBaseColorDrawCMD, view2D.position, proxy2D.base,
            ( CR2D_Primitive primitive ) { return true; },
            ( CRDrawRequest request, CR2D_Primitive primitive ) {}
        );

        rlBaseColor.execute();
    }

protected:
    void fillDrawCommand( T )( CRC_Draw cmd, SVec2F camPos, Array!T primitives, bool function( CR2D_Primitive ) checkIsValid, void function( CRDrawRequest, CR2D_Primitive ) subSetup )
    if ( is( T : CR2D_Primitive ) ) {
        foreach ( prim; primitives ) {
            if ( !prim.bVisible ) continue;

            if ( checkIsValid( prim ) ) {
                CRDrawRequest req = cmd.request();
                prim.fillDrawRequest( req, camPos );

                subSetup( req, prim );
            }
        }
    }
}
