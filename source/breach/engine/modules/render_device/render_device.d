module engine.modules.render_device.render_device;

public {
    import engine.core.containers : Array, Dict;
    import engine.core.object;
    import engine.core.math;
    import engine.core.string;
    import engine.core.typedefs;
}

import engine.core.utils.ustruct;

alias VertexDescriptor = Array!SRDVertexElement;

enum ERDFace {
    FRONT,
    BACK,
    FRONT_AND_BACK,
}

enum ERDBufferUpdate {
    STATIC,
    DYNAMIC,
    STREAM,
}

enum ERDWinding {
    CW,
    CCW,
}

enum ERDRasterMode {
    POINT,
    LINE,
    FILL,
}

enum ERDCompare {
    NEVER,
    LESS,
    EQUAL,
    LEQUAL,
    GREATER,
    NOTEQUAL,
    GEQUAL,
    ALWAYS,
}

enum ERDStencilAction {
    KEEP,
    ZERO,
    REPLACE,
    INCR,
    INCR_WRAP,
    DECR,
    DECR_WRAP,
    INVERT,
}

enum ERDBufferType {
    VERTEX,
    INDEX,
}

enum ERDPrimitiveType {
    BYTE,
    SHORT,
    INT,

    UBYTE,
    USHORT,
    UINT,

    BYTE_NORMALIZED,
    SHORT_NORMALIZED,
    INT_NORMALIZED,

    UBYTE_NORMALIZED,
    USHORT_NORMALIZED,
    UINT_NORMALIZED,

    HALF_FLOAT,
    FLOAT,
    DOUBLE,
}

enum ERDDrawIndicesType {
    USHORT,
    UINT,
    UBYTE,
}

enum ERDTextureType {
    TT_1D,
    TT_2D,
    TT_3D,
}

enum ERDTextureDataFormat {
    R,
    G,
    B,
    RGB,
    RGBA,
    DEPTH_STENCIL,
}

enum ERDShaderType {
    VERTEX,
    PIXEL,
}

enum ERDDrawMode {
    POINT,
    LINE,
    TRIANGLE
}

struct SRDVertexElement {
public:
    uint index;
    ERDPrimitiveType type;
    int size;
    int stride;
    long offset;
}

struct SRDTextureData {
    mixin( TRegisterStruct!SRDTextureData );
private:
    // Simple converter for correct transaction to rd
    static ERDPrimitiveType[TypeInfo] TYPE_TO_PRIMITIVE_TYPE;

public:
    uint width;
    uint height;
    uint depth;
    Array!ubyte data;
    ERDTextureDataFormat format = ERDTextureDataFormat.RGBA;

    static this() {
        TYPE_TO_PRIMITIVE_TYPE[typeid( byte )] = ERDPrimitiveType.BYTE;
        TYPE_TO_PRIMITIVE_TYPE[typeid( short )] = ERDPrimitiveType.SHORT;
        TYPE_TO_PRIMITIVE_TYPE[typeid( int )] = ERDPrimitiveType.INT;
        
        TYPE_TO_PRIMITIVE_TYPE[typeid( ubyte )] = ERDPrimitiveType.UBYTE;
        TYPE_TO_PRIMITIVE_TYPE[typeid( ushort )] = ERDPrimitiveType.USHORT;
        TYPE_TO_PRIMITIVE_TYPE[typeid( uint )] = ERDPrimitiveType.UINT;

        TYPE_TO_PRIMITIVE_TYPE[typeid( float )] = ERDPrimitiveType.FLOAT;
    }

    this(
        uint width,
        uint height,
        uint depth,
        Array!ubyte idata,
        ERDTextureDataFormat format = ERDTextureDataFormat.RGBA
    ) {
        this.width = width;
        this.height = height;
        this.depth = depth;

        // Convert to variant data type for simplify
        // transfert and decoding of different format
        // values
        //data.reserve( idata.length );

        //foreach ( elem; idata ) {
            //data ~= var( elem );
        //}
        data = idata.copy();

        this.format = format;
    }

    /**
        Check first element of data and calc
        primitive type, if cannot find
        association - returns UBYTE
    */
    ERDPrimitiveType dataType() {
        // Somehow array isn't initialized
        //if ( !data.length ) {
            return ERDPrimitiveType.UBYTE;
        //}

        // In some cases we can get invalid data, 
        // so we just ingnore it and pass as ubyte
        //TypeInfo ti = !data[0].isEmpty() ? data[0].type : typeid( ubyte );

        //return ti in TYPE_TO_PRIMITIVE_TYPE ? TYPE_TO_PRIMITIVE_TYPE[ti] : ERDPrimitiveType.UBYTE;
    }

    //Array!T getDataAs( T )() {
    Array!ubyte getDataAs() {
        // Somehow array isn't initialized
        //if ( !data.length ) { return Array!T(); }

        //Array!T ret;
        //ret.reserve( data.length );
        //foreach ( elem; data ) {
            //ret ~= elem.as!T;
        //}

        //return ret;
        return data;
    }


    /**
        Check every element on empty,
        if everyone isn't empty - 
        data is valid
    */
    bool isValid() {
        // Somehow array isn't initialized
        //if ( !data.length ) { return false; }

        //foreach ( elem; data ) {
            //if ( elem.isEmpty() ) {
                //return false;
            //}
        //}

        return true;
    }
}

struct SRDRasterState {
    bool bCullEnable = false;
    ERDWinding frontFace = ERDWinding.CCW;
    ERDFace face = ERDFace.BACK;
    ERDRasterMode mode = ERDRasterMode.FILL;
}

struct SRDDepthStencilState {
    bool bDepthEnable = true;
    bool bDepthWriteEnable = true;
    float depthNear = 0;
    float depthFar = 1;
    ERDCompare depthCompare = ERDCompare.LESS;

    bool bFrontFaceStencilEnable = false;
    ERDCompare frontFaceStencilCompare = ERDCompare.ALWAYS;
    ERDStencilAction frontFaceStencilFail = ERDStencilAction.KEEP;
    ERDStencilAction frontFaceStencilPass = ERDStencilAction.KEEP;
    ERDStencilAction frontFaceDepthFail = ERDStencilAction.KEEP;
    int frontFaceRef = 0;
    uint frontFaceReadMask = 0xFFFFFFFF;
    uint frontFaceWriteMask = 0xFFFFFFFF;

    bool bBackFaceStencilEnable = false;
    ERDCompare backFaceStencilCompare = ERDCompare.ALWAYS;
    ERDStencilAction backFaceStencilFail = ERDStencilAction.KEEP;
    ERDStencilAction backFaceStencilPass = ERDStencilAction.KEEP;
    ERDStencilAction backFaceDepthFail = ERDStencilAction.KEEP;
    int backFaceRef = 0;
    uint backFaceReadMask = 0xFFFFFFFF;
    uint backFaceWriteMask = 0xFFFFFFFF;
}

abstract class ARenderDevice : CObject {
    mixin( TRegisterClass!( ARenderDevice, SingletonBackendable ) );
public:
    static CRSClass backend;

    void destroy( ID id );

    /*
       For sometimes this method exists only for
       OpenGL driver call gl_checkErrors,
       since i not found better way to do this,
       because i am in burn of some situations and debugging
    */
    void update( float delta );

    /*********** TEXTURE ***********/
    ID texture_create( ERDTextureType type, SRDTextureData data );
    void texture_set( ID id = ID_INVALID, uint slot = 0 );
    //ERDTextureType texture_type( ID id );
    //SVec3I texture_resolution( ID id );

    /*********** SHADER ***********/
    ID shader_create( ERDShaderType type, String code );

    /*********** RENDER TARGET ***********/
    ID rt_create( uint width, uint height );
    void rt_set( ID id = ID_INVALID );
    bool rt_copy( ID src, ID dst );
    SVec2I rt_resolution( ID id );

    /*********** PIPELINE ***********/
    ID pipeline_create( ID vertexShader, ID pixelShader );
    void pipeline_set( ID id );
    void pipeline_set( ID id, Dict!(var, String) params );
    Array!String pipeline_getParamsNames( ID id );
    void pipeline_setParam( ID id, String name, var val );

    /*********** RASTER STATE ***********/
    void rs_set( SRDRasterState state = SRDRasterState() ) {}
    SRDRasterState rs_get() { return SRDRasterState(); }

    /*********** DEPTH STENCIL STATE ***********/
    void dss_set( SRDDepthStencilState state = SRDDepthStencilState() ) {}
    SRDDepthStencilState dss_get() { return SRDDepthStencilState(); }

    /*********** BUFFERS ***********/
    ID buffer_create( ERDBufferType type, ERDBufferUpdate dataType );
    void buffer_set( ID id );
    void buffer_setData( ID id, long size, void* data );
    void buffer_subData( ID id, long offset, long size, void* data );
    void buffer_clear( ID id );
    void buffer_copy( ID dst, ID src );

    /*********** VERTEX DESCRIPTION ***********/
    ID vd_create( Array!SRDVertexElement elements );
    
    /*********** VERTEX_ARRAY ***********/
    ID vao_create( ID vd, ID vbo, ID ibo );
    void vao_set( ID id );

    /*********** DRAW ***********/
    void clear( float r = 0.0f, float g = 0.0f, float b = 0.0f, float a = 1.0f, float depth = 1.0f, int stencil = 0 );
    void draw( ERDDrawMode mode, int offset, int count );
    void drawIndexed32( ERDDrawMode mode, long offset, int count, ERDDrawIndicesType type = ERDDrawIndicesType.UINT );

    void scissor_enable( SRect rect );
    void scissor_disable();

    /*********** UTILS ***********/
    void viewport( uint x, uint y, uint iwidth, uint iheight );

    /*******************************/
    /*********** HELPERS ***********/
    /*******************************/

    void clear( SColorRGBA color, float depth = 1.0f, int stencil = 0 ) {
        clear( color.r, color.g, color.b, color.a, depth, stencil );
    }

    bool rt_resize( ref ID src, uint width, uint height ) {
        SVec2I oldSize = RD.rt_resolution( src );
        if ( oldSize == SVec2I( width, height ) ) return true;

        /* 
            Copy old framebuffer data to new,
            for some situations when we still
            use infomation about old frame,
            like get color of some pixel.
            
            Or if framebuDescriptionrendering process and
            we steel need to handle old rendered
            data.
        */
        ID dst = rt_create( width, height );
        //bool bSuccess = rt_copy( src, dst );
        bool bSuccess = true;

        destroy( src );
        
        src = dst;

        return bSuccess;
    }
}

pragma( inline, true )
ARenderDevice RD() { return ARenderDevice.sig; }
