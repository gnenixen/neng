module engine.smodules.rd_ogl.render;

import std.string;

import engine.thirdparty.derelict.opengl;

import engine.core.memory;
import engine.core.config;
import engine.core.log;
import engine.core.string;

import engine.modules.render_device.render_device;

enum GL_MAX_VERSION = GLVersion.gl32;
enum GL_SUPPORT_DEPREATED = false;

static if ( !GL_SUPPORT_DEPREATED ) {
    mixin( glImports );
} else {
    mixin( gl_depImports );
}

mixin glDecls!( GL_MAX_VERSION, GL_SUPPORT_DEPREATED );

private
static void gl_checkErrors() {
    GLenum errcode;
    while ( ( errcode = glGetError() ) != GL_NO_ERROR ) {
        String errstr;
        switch ( errcode ) {
            case GL_INVALID_ENUM: errstr = "INVALID_ENUM"; break;
            case GL_INVALID_VALUE: errstr = "INVALID_VALUE"; break;
            case GL_INVALID_OPERATION: errstr = "INVALID_OPERATION"; break;
            //case GL_STACK_OVERFLOW: errstr = "STACK_OVERFLOW"; break;
            //case GL_STACK_UNDERFLOW: errstr = "STACK_UNDERFLOW"; break;
            case GL_OUT_OF_MEMORY: errstr = "OUT_OF_MEMORY"; break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: errstr = "INVALID_FRAMEBUFFER_OPERATION"; break;

            default: break;
        }

        log.error( "OpenGL error: ", errstr, "(", errcode, ")" );
    }
}

class COGLBuffer : CObject {
    mixin( TRegisterClass!COGLBuffer );
public:
    ERDBufferType type;
    ERDBufferUpdate dataType;

    uint glID;
    uint typed;

    uint glType;

    this( ERDBufferType type, ERDBufferUpdate dataType ) {
        this.type = type;
        this.dataType = dataType;

        auto dt = GL_STATIC_DRAW;
        glType = GL_ARRAY_BUFFER;

        switch ( dataType ) {
        case ERDBufferUpdate.STATIC:
            dt = GL_STATIC_DRAW;
            break;
        case ERDBufferUpdate.DYNAMIC:
            dt = GL_DYNAMIC_DRAW;
            break;
        case ERDBufferUpdate.STREAM:
            dt = GL_STREAM_DRAW;
            break;

        default:
            assert( false );
        }

        switch ( type ) {
        case ERDBufferType.VERTEX:
            glType = GL_ARRAY_BUFFER;
            break;
        case ERDBufferType.INDEX:
            glType = GL_ELEMENT_ARRAY_BUFFER;
            break;
        
        default:
            assert( false );
        }

        glGenBuffers( 1, &glID );
        typed = dt;
    }

    ~this() {
        glDeleteBuffers( 1, &glID );
    }

    void setData( long offset, long size, const void* data ) {
        glBindBuffer( glType, glID );
        if ( offset == 0 ) {
            glBufferData( glType, size, data, typed );
        } else {
            glBufferSubData( glType, offset, size, data );
        }
        glBindBuffer( glType, 0 );
    }
}

class COGLVertexDescription : CObject {
    mixin( TRegisterClass!COGLVertexDescription );
public:
    struct SOGLVertexElement {
        GLuint index;
        GLint size;
        GLenum type;
        GLboolean normalized;
        GLsizei stride;
        GLvoid* pointer;
    }

    static enum GLenum[] TO_OGL_TYPE = [
        GL_BYTE,
        GL_SHORT,
        GL_INT,
        GL_UNSIGNED_BYTE,
        GL_UNSIGNED_SHORT,
        GL_UNSIGNED_INT,
		GL_BYTE,
        GL_SHORT,
        GL_INT,
        GL_UNSIGNED_BYTE,
        GL_UNSIGNED_SHORT,
        GL_UNSIGNED_INT,
        GL_HALF_FLOAT, 
        GL_FLOAT,
        GL_DOUBLE
    ];

    static enum GLboolean[] TO_OGL_NORMALIZED = [
        GL_FALSE,
        GL_FALSE,
        GL_FALSE,
        GL_FALSE,
        GL_FALSE,
        GL_FALSE,
	    GL_TRUE,
        GL_TRUE,
        GL_TRUE,
        GL_TRUE, 
        GL_TRUE,
        GL_TRUE,
        GL_FALSE,
        GL_FALSE,
        GL_FALSE
    ];

    Array!SOGLVertexElement elements;

    this( Array!SRDVertexElement vertexElements ) {
        foreach ( el; vertexElements ) {
            SOGLVertexElement oglel;
            oglel.index = el.index;
            oglel.size = el.size;
            oglel.type = TO_OGL_TYPE[el.type];
            oglel.normalized = TO_OGL_NORMALIZED[el.type];
            oglel.stride = el.stride;
            oglel.pointer = cast( void* )el.offset;
            elements ~= oglel;
        }
    }

    ~this() {
        elements.free();
    }
}

class COGLVertexArray : CObject {
    mixin( TRegisterClass!COGLVertexArray );
public:
    uint VAO = 0;

    this( COGLVertexDescription vd, COGLBuffer vbo, COGLBuffer ibo ) {
        glGenVertexArrays( 1, &VAO );
        glBindVertexArray( VAO );
            glBindBuffer( GL_ARRAY_BUFFER, vbo.glID );
            glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, ibo.glID );

            foreach ( lvd; vd.elements ) {
                glEnableVertexAttribArray( lvd.index );
                glVertexAttribPointer(
                    lvd.index,
                    lvd.size,
                    lvd.type,
                    lvd.normalized,
                    lvd.stride,
                    lvd.pointer
                );
            }
        glBindVertexArray( 0 );
    }

    ~this() {
        glDeleteVertexArrays( 1, &VAO );
    }
}

class SOGLDepthStencilState {
    static immutable GLenum[] COMPARE_MAP = [
        GL_NEVER,
        GL_LESS,
        GL_EQUAL,
        GL_LEQUAL,
        GL_GREATER,
        GL_NOTEQUAL,
        GL_GEQUAL,
        GL_ALWAYS,
    ];

    static immutable GLenum[] STENCIL_MAP = [
        GL_KEEP,
        GL_ZERO,
        GL_REPLACE,
        GL_INCR,
        GL_INCR_WRAP,
        GL_DECR,
        GL_DECR_WRAP, 
        GL_INVERT
    ];

    bool bDepthEnabled;
    bool bDepthWriteEnabled;
    float depthNear;
    float depthFar;
    GLenum depthFunc;

    bool bFrontFaceStencilEnabled;
    GLenum frontStencilFunc;
    GLenum frontFaceStencilFail;
    GLenum frontFaceStencilPass;
    GLenum frontFaceDepthFail;
    GLint frontFaceRef;
    GLuint frontFaceReadMask;
    GLuint frontFaceWriteMask;

    bool bBackFaceStencilEnabled;
    GLenum backStencilFunc;
    GLenum backFaceStencilFail;
    GLenum backFaceStencilPass;
    GLenum backFaceDepthFail;
    GLint backFaceRef;
    GLuint backFaceReadMask;
    GLuint backFaceWriteMask;

    this(
        bool ibDepthEnabled = true,
        bool ibDepthWriteEnable = true,
        float idepthNear = 0,
        float idepthFar = 1,
        ERDCompare idepthCompare = ERDCompare.LESS,

        bool ibFrontFaceStencilEnable = false,
        ERDCompare ifrontFaceStencilCompare = ERDCompare.ALWAYS,
        ERDStencilAction ifrontFaceStencilFail = ERDStencilAction.KEEP,
        ERDStencilAction ifrontFaceStencilPass = ERDStencilAction.KEEP,
        ERDStencilAction ifrontFaceDepthFail = ERDStencilAction.KEEP,
        int ifrontFaceRef = 0,
        uint ifrontFaceReadMask = 0xFFFFFFFF,
        uint ifrontFaceWriteMask = 0xFFFFFFFF,

        bool ibBackFaceStencilEnable = false,
        ERDCompare ibackFaceStencilCompare = ERDCompare.ALWAYS,
        ERDStencilAction ibackFaceStencilFail = ERDStencilAction.KEEP,
        ERDStencilAction ibackFaceStencilPass = ERDStencilAction.KEEP,
        ERDStencilAction ibackFaceDepthFail = ERDStencilAction.KEEP,
        int ibackFaceRef = 0,
        uint ibackFaceReadMask = 0xFFFFFFFF,
        uint ibackFaceWriteMask = 0xFFFFFFFF
    ) {
        bDepthEnabled = ibDepthEnabled;
        bDepthWriteEnabled = ibDepthWriteEnable;
        depthNear = idepthNear;
        depthFar = idepthFar;
        depthFunc = COMPARE_MAP[idepthCompare];

        bFrontFaceStencilEnabled = ibFrontFaceStencilEnable;
        frontStencilFunc = COMPARE_MAP[ifrontFaceStencilCompare];
        frontFaceStencilFail = STENCIL_MAP[ifrontFaceStencilFail];
        frontFaceStencilPass = STENCIL_MAP[ifrontFaceStencilPass];
        frontFaceDepthFail = STENCIL_MAP[ifrontFaceDepthFail];
        frontFaceRef = ifrontFaceRef;
        frontFaceReadMask = ifrontFaceReadMask;
        frontFaceWriteMask = ifrontFaceWriteMask;

        bBackFaceStencilEnabled = ibBackFaceStencilEnable;
        backStencilFunc = COMPARE_MAP[ibackFaceStencilCompare];
        backFaceStencilFail = STENCIL_MAP[ibackFaceStencilFail];
        backFaceStencilPass = STENCIL_MAP[ibackFaceStencilPass];
        backFaceDepthFail = STENCIL_MAP[ibackFaceDepthFail];
        backFaceRef = ibackFaceRef;
        backFaceReadMask = ibackFaceReadMask;
        backFaceWriteMask = ibackFaceWriteMask;
    }
}

class SOGLRasterState {
    static immutable GLenum[] FRONT_FACE_MAP = [
        GL_CW,
        GL_CCW,
    ];

    static immutable GLenum[] CULL_FACE_MAP = [
        GL_FRONT,
        GL_BACK,
        GL_FRONT_AND_BACK,
    ];

    static immutable GLenum[] RASTER_MODE_MAP = [
        GL_POINT,
        GL_LINE,
        GL_FILL,
    ];

    bool bCullEnabled;
    GLenum frontFace;
    GLenum cullFace;
    GLenum polygonMode;

    this(
        bool ibCullEnable = false,
        ERDWinding ifrontFace = ERDWinding.CCW,
        ERDFace iface = ERDFace.BACK,
        ERDRasterMode imode = ERDRasterMode.FILL
    ) {
        bCullEnabled = ibCullEnable;
        frontFace = FRONT_FACE_MAP[ifrontFace];
        cullFace = CULL_FACE_MAP[iface];
        polygonMode = RASTER_MODE_MAP[imode];
    }
}

class COGLShader : CObject {
    mixin( TRegisterClass!COGLShader );
public:
    bool bValid = false;
    int program = 0;

    this( ERDShaderType itype, String code ) {
        switch ( itype ) {
        case ERDShaderType.VERTEX:
            program = glCreateShader( GL_VERTEX_SHADER );
            break;
        case ERDShaderType.PIXEL:
            program = glCreateShader( GL_FRAGMENT_SHADER );
            break;
        default:
            assert( false );
        }

        int len = cast( int )code.length;
        CString src = code.c_str;
        const( char )* csrc = cast( const( char )* )( src.toString() );
        glShaderSource( program, 1, &csrc, &len );
        glCompileShader( program );

        GLint status;
        glGetShaderiv( program, GL_COMPILE_STATUS, &status );
        if ( status != GL_TRUE ) {
            GLint maxLength = 0;
            glGetShaderiv( program, GL_INFO_LOG_LENGTH, &maxLength );

            Array!GLchar errLog;
            errLog.resize( maxLength );

            glGetShaderInfoLog( program, maxLength, &maxLength, &errLog.ptr()[0] );
            log.error( String( errLog.rawdata ) );
            return;
        }

        bValid = true;
    }

    ~this() {
        glDeleteShader( program );
    }
}

class COGLPipelineParam : CObject {
    mixin( TRegisterClass!COGLPipelineParam );
public:
    COGLPipeline pipeline;
    int location = 0;

    this( COGLPipeline pp, int loc ) {
        pipeline = pp;
        location = loc;
    }
}

class COGLPipeline : CObject {
    mixin( TRegisterClass!COGLPipeline );
public:
    int shader = 0;

    Dict!( COGLPipelineParam, String ) params;

    this( COGLShader ivertexShader, COGLShader ipixelShader ) {
        assert( ivertexShader && ipixelShader );
        assert( ivertexShader.bValid && ipixelShader.bValid );

        shader = glCreateProgram();
        glAttachShader( shader, ivertexShader.program );
        glAttachShader( shader, ipixelShader.program );
        glLinkProgram( shader );        

        gl_checkErrors();
    }

    ~this() {
        glDeleteProgram( shader );
        foreach ( key, p; params ) {
            destroyObject( p );
        }
    }

    COGLPipelineParam getParam( String name ) {
        COGLPipelineParam pp = params.get( name, null );
        if ( pp ) return pp;

        CString src = name.opCast!char;
        int location = glGetUniformLocation( shader, src.cstr );
        if ( location < 0 ) {
            //log.error( "Canno't find param for shader: ", name );
            return null;
        }

        pp = newObject!COGLPipelineParam( this, location );
        params.set( name, pp );

        return pp;
    }
}

class COGLTextureData : CObject {
    mixin( TRegisterClass!COGLTextureData );
public:
    GLuint textureId;
    ERDTextureType type;

    SVec3I resolution;

    this( GLuint tid, ERDTextureType itype, SVec3I res ) {
        textureId = tid;
        type = itype;
        resolution = res;
    }

    ~this() {
        glDeleteTextures( 1, &textureId );
    }
}

class COGLRenderTarget : CObject {
    mixin( TRegisterClass!COGLRenderTarget );
public:
    GLuint rtId;
    GLuint textureId;

    uint width;
    uint height;

    this( GLuint tid, GLuint texture, uint iwidth, uint iheight ) {
        rtId = tid;
        textureId = texture;

        width = iwidth;
        height = iheight;
    }

    ~this() {
        glDeleteFramebuffers( 1, &rtId );
    }
}

final class COpenGLRD : ARenderDevice {
    mixin( TRegisterClass!COpenGLRD );
private:
    SRDRasterState rasterState;
    SRDRasterState defaultRasterState;

    SRDDepthStencilState depthStencilState;
    SRDDepthStencilState defaultDepthStencilState;

public:
    this() {
        DerelictGL3.load();
        DerelictGL3.reload();

        log.info( "OpenGL: ", glGetString( GL_VERSION ), ", GLSL: ", glGetString( GL_SHADING_LANGUAGE_VERSION ) );

        //cfg.set( "engine/modules/render/wincom/pipeline/pixel", "resources/engine/ogl_render/wincom_fragment.glsl" );
        //cfg.set( "engine/modules/render/wincom/pipeline/vertex", "resources/engine/ogl_render/wincom_vertex.glsl" );
        
        // Hardcoded for sometime, replace by normal logic in future
        glEnable( GL_DEPTH_TEST );
        glDepthFunc( GL_LEQUAL );
        glEnable( GL_BLEND );
        glBlendFuncSeparate( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE );
    }

    override void destroy( ID id ) {
        destroyObject( id );
    }

    override void update( float delta ) {
        //gl_checkErrors();
    }

    override ID texture_create( ERDTextureType type, SRDTextureData data ) {
        assert( data.isValid(), "Passed invalid data!" );

        GLuint tid;
        auto textureType = GL_TEXTURE_2D;
        auto primitiveType = GL_UNSIGNED_BYTE;
        auto format = GL_RGBA;
        void* dataPtr = null;

        switch ( type ) {
        case ERDTextureType.TT_1D:
            textureType = GL_TEXTURE_1D;
            break;
        case ERDTextureType.TT_2D:
            textureType = GL_TEXTURE_2D;
            break;
        case ERDTextureType.TT_3D:
            textureType = GL_TEXTURE_3D;
            break;
        default:
            assert( false );
        }

        switch ( data.format ) {
        case ERDTextureDataFormat.R:
            format = GL_RED;
            break;
        case ERDTextureDataFormat.G:
            format = GL_GREEN;
            break;
        case ERDTextureDataFormat.B:
            format = GL_BLUE;
            break;
        case ERDTextureDataFormat.RGB:
            format = GL_RGB;
            break;
        case ERDTextureDataFormat.RGBA:
            format = GL_RGBA;
            break;
        case ERDTextureDataFormat.DEPTH_STENCIL:
            format = GL_DEPTH_STENCIL;
            break;
        default:
            assert( false );
        }

        switch ( data.dataType() ) {
        case ERDPrimitiveType.BYTE:
            primitiveType = GL_BYTE;
            break;
        case ERDPrimitiveType.SHORT:
            primitiveType = GL_SHORT;
            break;
        case ERDPrimitiveType.INT:
            primitiveType = GL_INT;
            break;
        
        case ERDPrimitiveType.UBYTE:
            primitiveType = GL_UNSIGNED_BYTE;
            break;
        case ERDPrimitiveType.USHORT:
            primitiveType = GL_UNSIGNED_SHORT;
            break;
        case ERDPrimitiveType.UINT:
            primitiveType = GL_UNSIGNED_INT;
            break;
        
        case ERDPrimitiveType.FLOAT:
            primitiveType = GL_FLOAT;
            break;
        case ERDPrimitiveType.DOUBLE:
            primitiveType = GL_DOUBLE;
            break;

        default:
            assert( false, "Unsupported primitive type!" );
        }

        glGenTextures( 1, &tid );
        glBindTexture( textureType, tid );

        // TODO: Rewrite this costile
        //Array!ubyte rawData;
        //rawData.reserve( data.data.length() );
        //foreach ( elem; data.data ) {
            //rawData ~= elem.as!ubyte;
        //}
        Array!ubyte rawData = data.data;
        scope( exit ) {
            rawData.free();
        }

        glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            format,
            data.width,
            data.height,
            0,
            format,
            primitiveType,
            rawData.rawdata.ptr
        );

        glBindTexture( textureType, 0 );

        return newObject!COGLTextureData( tid, type, SVec3I( data.width, data.height, data.depth ) ).id;
    }

    override void texture_set( ID id, uint slot ) {
        GLuint tid = 0;
        ERDTextureType type = ERDTextureType.TT_1D;

        if ( COGLTextureData data = getObjectByID!COGLTextureData( id ) ) {
            tid = data.textureId;
            type = data.type;
        } else if ( COGLRenderTarget data = getObjectByID!COGLRenderTarget( id ) ) {
            tid = data.textureId;
            type = ERDTextureType.TT_2D;
        }

        glActiveTexture( GL_TEXTURE0 + slot );

        switch ( type ) {
        case ERDTextureType.TT_1D:
            glBindTexture( GL_TEXTURE_1D, tid );
            break;
        case ERDTextureType.TT_2D:
            glBindTexture( GL_TEXTURE_2D, tid );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            break;
        case ERDTextureType.TT_3D:
            glBindTexture( GL_TEXTURE_3D, tid );
            break;
        default:
            break;
        }
    }

    /*override SVec3I texture_resolution( ID id ) {
        COGLTextureData texture = getObjectByID!COGLTextureData( id );
        if ( !texture ) return SVec3I( -1 );

        return texture.resolution;
    }*/

    override ID shader_create( ERDShaderType type, String code ) {
        COGLShader shader = newObject!COGLShader( type, code );
        if ( !shader.bValid ) {
            destroyObject( shader );
            return ID_INVALID;
        }

        return shader.id;
    }

    override ID rt_create( uint width, uint height ) {
        GLuint rtId;
        glGenFramebuffers( 1, &rtId );
        glBindFramebuffer( GL_FRAMEBUFFER, rtId );  

        GLuint texture;
        glGenTextures( 1, &texture );
        glBindTexture( GL_TEXTURE_2D, texture );
        glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast( void* )0 );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER );
        glBindTexture( GL_TEXTURE_2D, 0 );
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0 );
        assert( glCheckFramebufferStatus( GL_FRAMEBUFFER ) == GL_FRAMEBUFFER_COMPLETE );
        glBindFramebuffer( GL_FRAMEBUFFER, 0 );

        return newObject!COGLRenderTarget( rtId, texture, width, height ).id;
    }

    override SVec2I rt_resolution( ID id ) {
        COGLRenderTarget pp = getObjectByID!COGLRenderTarget( id );
        if ( !pp ) return SVec2I( 0, 0 );

        return SVec2I( pp.width, pp.height );
    }

    override void rt_set( ID id ) {
        COGLRenderTarget pp = getObjectByID!COGLRenderTarget( id );
        if ( !pp ) {
            glBindFramebuffer( GL_FRAMEBUFFER, 0 );
            return;
        }

        glBindFramebuffer( GL_FRAMEBUFFER, pp.rtId );
    }

    override bool rt_copy( ID src, ID dst ) {
        COGLRenderTarget rtSrc = getObjectByID!COGLRenderTarget( src );
        COGLRenderTarget rtDst = getObjectByID!COGLRenderTarget( dst );

        if ( !rtSrc || !rtDst ) {
            log.warning( "Invalid src or dst" );
            return false;
        }

        glBindFramebuffer( GL_READ_FRAMEBUFFER, rtSrc.rtId );
        glBindFramebuffer( GL_DRAW_FRAMEBUFFER, rtDst.rtId );

        glReadBuffer( GL_COLOR_ATTACHMENT0 );
        glDrawBuffer( GL_COLOR_ATTACHMENT0 );

        glBlitFramebuffer(
            0, 0, rtSrc.width, rtSrc.height,
            0, 0, rtDst.width, rtDst.height,
            GL_COLOR_BUFFER_BIT, GL_NEAREST
        );

        glBindFramebuffer( GL_READ_FRAMEBUFFER, 0 );
        glBindFramebuffer( GL_DRAW_FRAMEBUFFER, 0 );

        return true;
    }


    /*********** RD ***********/
    override ID pipeline_create( ID vertexShader, ID pixelShader ) {
        return newObject!COGLPipeline(
            getObjectByID!COGLShader( vertexShader ),
            getObjectByID!COGLShader( pixelShader )
        ).id;
    }

    override void pipeline_set( ID id ) {
        COGLPipeline pp = getObjectByID!COGLPipeline( id );
        if ( !pp ) {
            log.error( "Invalid pipeline id!" );
            assert( false );
            //return;
        }

        glUseProgram( pp.shader );
    }

    override void pipeline_set( ID id, Dict!(var, String) params ) {
        COGLPipeline pp = getObjectByID!COGLPipeline( id );
        if ( !pp ) return;

        glUseProgram( pp.shader );

        foreach ( name, val; params ) {
            COGLPipelineParam param = pp.getParam( name );
            if ( !param ) continue;

            if ( val.type is typeid( int ) ) {
                glUniform1i( param.location, val.as!int );
            }
            else if ( val.type is typeid( uint ) ) {
                glUniform1i( param.location, cast( int )val.as!uint );
            }
            else if ( val.type is typeid( ulong ) ) {
                glUniform1i( param.location, cast( int )val.as!ulong );
            }
            else if ( val.type is typeid( float ) ) {
                glUniform1f( param.location, val.as!float );
            }

            else if ( val.type is typeid( SVec2I ) ) {
                glUniform2fv( param.location, 1, val.as!SVec2I.tov!float.data.ptr );
            }
            else if ( val.type is typeid( SVec2F ) ) {
                glUniform2fv( param.location, 1, val.as!SVec2F.data.ptr );
            }
            else if ( val.type is typeid( SVec3F ) ) {
                glUniform3fv( param.location, 1, val.as!SVec3F.data.ptr );
            }
            else if ( val.type is typeid( SVec4F ) ) {
                glUniform4fv( param.location, 1, val.as!SVec4F.data.ptr );
            }
            else if ( val.type is typeid( SColorRGB ) ) {
                glUniform3fv( param.location, 1, val.as!SColorRGB.data.ptr );
            }
            else if ( val.type is typeid( SColorRGBA ) ) {
                glUniform4fv( param.location, 1, val.as!SColorRGBA.data.ptr );
            }

            else if ( val.type is typeid( SMat4F ) ) {
                glUniformMatrix4fv( param.location, 1, GL_TRUE, val.as!SMat4F[0].ptr );
            } else {
                assert( false, "Received invalid type: " ~ val.type.toString() );
            }
        }
    }

    override Array!String pipeline_getParamsNames( ID id ) {
        assert( false );
    }

    override void pipeline_setParam( ID id, String name, var val ) {
        COGLPipeline pp = getObjectByID!COGLPipeline( id );
        if ( !pp || val.isEmpty() ) return;

        COGLPipelineParam param = pp.getParam( name );
        if ( !param ) return;

        glUseProgram( pp.shader );

        if ( val.type is typeid( int ) ) {
            glUniform1i( param.location, val.as!int );
        }
        else if ( val.type is typeid( uint ) ) {
            glUniform1i( param.location, cast( int )val.as!uint );
        }
        else if ( val.type is typeid( ulong ) ) {
            glUniform1i( param.location, cast( int )val.as!ulong );
        }
        else if ( val.type is typeid( float ) ) {
            glUniform1f( param.location, val.as!float );
        }

        else if ( val.type is typeid( SVec2I ) ) {
            glUniform2fv( param.location, 1, val.as!SVec2I.tov!float.data.ptr );
        }
        else if ( val.type is typeid( SVec2F ) ) {
            glUniform2fv( param.location, 1, val.as!SVec2F.data.ptr );
        }
        else if ( val.type is typeid( SVec3F ) ) {
            glUniform3fv( param.location, 1, val.as!SVec3F.data.ptr );
        }
        else if ( val.type is typeid( SVec4F ) ) {
            glUniform4fv( param.location, 1, val.as!SVec4F.data.ptr );
        }
        else if ( val.type is typeid( SColorRGB ) ) {
            glUniform3fv( param.location, 1, val.as!SColorRGB.data.ptr );
        }
        else if ( val.type is typeid( SColorRGBA ) ) {
            glUniform4fv( param.location, 1, val.as!SColorRGBA.data.ptr );
        }

        else if ( val.type is typeid( SMat4F ) ) {
            glUniformMatrix4fv( param.location, 1, GL_TRUE, val.as!SMat4F[0].ptr );
        } else {
            assert( false, "Received invalid type: " ~ val.type.toString() );
        }
    }

    override void rs_set( SRDRasterState nrs = SRDRasterState() ) {
        rasterState = nrs;

        if ( nrs.bCullEnable ) {
            glEnable( GL_CULL_FACE );
        } else {
            glDisable( GL_CULL_FACE );
        }

        glFrontFace( SOGLRasterState.FRONT_FACE_MAP[nrs.frontFace] );
        glCullFace( SOGLRasterState.CULL_FACE_MAP[nrs.face] );
        glPolygonMode( GL_FRONT_AND_BACK, SOGLRasterState.RASTER_MODE_MAP[nrs.mode] );
    }

    override SRDRasterState rs_get() { return rasterState; }

    override void dss_set( SRDDepthStencilState ndst = SRDDepthStencilState() ) {
        depthStencilState = ndst;

        if ( ndst.bDepthEnable ) {
            glEnable( GL_DEPTH_TEST );
        } else {
            glDisable( GL_DEPTH_TEST );
        }

        glDepthFunc( SOGLDepthStencilState.COMPARE_MAP[ndst.depthCompare] );
        glDepthMask( ndst.bDepthWriteEnable ? GL_TRUE : GL_FALSE );
        glDepthRange( ndst.depthNear, ndst.depthFar );

        if ( ndst.bFrontFaceStencilEnable || ndst.bBackFaceStencilEnable ) {
            glEnable( GL_STENCIL_TEST );
        } else {
            glDisable( GL_STENCIL_TEST );
        }

        glStencilFuncSeparate( GL_FRONT, SOGLDepthStencilState.COMPARE_MAP[ndst.frontFaceStencilCompare], ndst.frontFaceRef, ndst.frontFaceReadMask );
        glStencilMaskSeparate( GL_FRONT, ndst.frontFaceWriteMask );
        glStencilOpSeparate( GL_FRONT, SOGLDepthStencilState.STENCIL_MAP[ndst.frontFaceStencilFail], SOGLDepthStencilState.STENCIL_MAP[ndst.frontFaceDepthFail], SOGLDepthStencilState.STENCIL_MAP[ndst.frontFaceStencilPass] );

        glStencilFuncSeparate( GL_BACK, SOGLDepthStencilState.COMPARE_MAP[ndst.backFaceStencilCompare], ndst.backFaceRef, ndst.backFaceReadMask );
        glStencilMaskSeparate( GL_BACK, ndst.backFaceWriteMask );
        glStencilOpSeparate( GL_BACK, SOGLDepthStencilState.STENCIL_MAP[ndst.backFaceStencilFail], SOGLDepthStencilState.STENCIL_MAP[ndst.backFaceDepthFail], SOGLDepthStencilState.STENCIL_MAP[ndst.backFaceStencilPass] );
    }

    override SRDDepthStencilState dss_get() { return depthStencilState; }

    /*********** BUFFERS ***********/
    override ID buffer_create( ERDBufferType type, ERDBufferUpdate dataType ) {
        return newObject!COGLBuffer( type, dataType ).id;
    }
    
    override void buffer_set( ID id ) {
        COGLBuffer buffer = getObjectByID!COGLBuffer( id );
        if ( !buffer ) {
            return;
        }

        glBindBuffer( buffer.glType, buffer.glID );
    }

    override void buffer_setData( ID id, long size, void* data ) {
        COGLBuffer buffer = getObjectByID!COGLBuffer( id );
        
        if ( !buffer ) {
            return;
        }

        buffer.setData( 0, size, data );
    }

    override void buffer_subData( ID id, long offset, long size, void* data ) {
        COGLBuffer buffer = getObjectByID!COGLBuffer( id );
        
        if ( !buffer ) {
            return;
        }

        buffer.setData( offset, size, data );
    }

    override void buffer_clear( ID id ) { assert( false ); }
    override void buffer_copy( ID dst, ID src ) { assert( false ); }

    override ID vd_create( Array!SRDVertexElement elements ) {
        return newObject!COGLVertexDescription( elements ).id;
    }
    
    override ID vao_create( ID vd, ID vbo, ID ibo ) {
        return newObject!COGLVertexArray(
            getObjectByID!COGLVertexDescription( vd ),
            getObjectByID!COGLBuffer( vbo ),
            getObjectByID!COGLBuffer( ibo )
        ).id;
    }

    override void vao_set( ID id ) {
        COGLVertexArray va = getObjectByID!COGLVertexArray( id );
        if ( !va ) {
            glBindVertexArray( 0 );
            return;
        }

        glBindVertexArray( va.VAO );
    }

    /*********** DRAW ***********/
    override void clear( float r = 0.0f, float g = 0.0f, float b = 0.0f, float a = 1.0f, float depth = 1.0f, int stencil = 0 ) {
        glColorMask( true, true, true, true );
        glClearColor( r, g, b, a );
        glClearDepth( depth );
        glClearStencil( stencil );
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
    }

    override void draw( ERDDrawMode mode, int offset, int count ) {
        glDrawArrays( getGLDrawMode( mode ), offset, count );
    }

    override void drawIndexed32( ERDDrawMode mode, long offset, int count, ERDDrawIndicesType type ) {
        auto tp = GL_UNSIGNED_INT;
        long roffset = offset;

        switch ( type ) {
        case ERDDrawIndicesType.UINT:
            tp = GL_UNSIGNED_INT;
            roffset *= uint.sizeof;
            break;
        case ERDDrawIndicesType.USHORT:
            tp = GL_UNSIGNED_SHORT;
            roffset *= ushort.sizeof;
            break;
        case ERDDrawIndicesType.UBYTE:
            tp = GL_UNSIGNED_BYTE;
            roffset *= ubyte.sizeof;
            break;
        default:
            assert( false );
        }

        glDrawElements( getGLDrawMode( mode ), count, tp, cast( GLvoid* )roffset );
    }

    override void scissor_enable( SRect rect ) {
        glEnable( GL_SCISSOR_TEST );
        glScissor( cast(int)rect.pos.x, cast(int)rect.pos.y, cast(int)rect.width, cast(int)rect.height );
    }
    
    override void scissor_disable() {
        glDisable( GL_SCISSOR_TEST );
    }

    override void viewport( uint x, uint y, uint iwidth, uint iheight ) {
        glViewport( x, y, iwidth, iheight );
    }

private:
    int getGLDrawMode( ERDDrawMode mode ) {
        switch ( mode ) {
            case ERDDrawMode.POINT: return GL_POINTS;
            case ERDDrawMode.LINE: return GL_LINES;
            case ERDDrawMode.TRIANGLE: return GL_TRIANGLES;

            default: assert( false );
        }
    }
}

//mixin( TExportRenderDevice!COpenGLRD );
