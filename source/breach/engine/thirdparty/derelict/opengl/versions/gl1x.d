/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module engine.thirdparty.derelict.opengl.versions.gl1x;

import engine.thirdparty.derelict.opengl.types,
        engine.thirdparty.derelict.opengl.versions.base;

enum _gl1Decls =
q{
enum : uint
{
    // OpenGL 1.2
    GL_UNSIGNED_BYTE_3_3_2            = 0x8032,
    GL_UNSIGNED_SHORT_4_4_4_4         = 0x8033,
    GL_UNSIGNED_SHORT_5_5_5_1         = 0x8034,
    GL_UNSIGNED_INT_8_8_8_8           = 0x8035,
    GL_UNSIGNED_INT_10_10_10_2        = 0x8036,
    GL_TEXTURE_BINDING_3D             = 0x806A,
    GL_PACK_SKIP_IMAGES               = 0x806B,
    GL_PACK_IMAGE_HEIGHT              = 0x806C,
    GL_UNPACK_SKIP_IMAGES             = 0x806D,
    GL_UNPACK_IMAGE_HEIGHT            = 0x806E,
    GL_TEXTURE_3D                     = 0x806F,
    GL_PROXY_TEXTURE_3D               = 0x8070,
    GL_TEXTURE_DEPTH                  = 0x8071,
    GL_TEXTURE_WRAP_R                 = 0x8072,
    GL_MAX_3D_TEXTURE_SIZE            = 0x8073,
    GL_UNSIGNED_BYTE_2_3_3_REV        = 0x8362,
    GL_UNSIGNED_SHORT_5_6_5           = 0x8363,
    GL_UNSIGNED_SHORT_5_6_5_REV       = 0x8364,
    GL_UNSIGNED_SHORT_4_4_4_4_REV     = 0x8365,
    GL_UNSIGNED_SHORT_1_5_5_5_REV     = 0x8366,
    GL_UNSIGNED_INT_8_8_8_8_REV       = 0x8367,
    GL_UNSIGNED_INT_2_10_10_10_REV    = 0x8368,
    GL_BGR                            = 0x80E0,
    GL_BGRA                           = 0x80E1,
    GL_MAX_ELEMENTS_VERTICES          = 0x80E8,
    GL_MAX_ELEMENTS_INDICES           = 0x80E9,
    GL_CLAMP_TO_EDGE                  = 0x812F,
    GL_TEXTURE_MIN_LOD                = 0x813A,
    GL_TEXTURE_MAX_LOD                = 0x813B,
    GL_TEXTURE_BASE_LEVEL             = 0x813C,
    GL_TEXTURE_MAX_LEVEL              = 0x813D,
    GL_SMOOTH_POINT_SIZE_RANGE        = 0x0B12,
    GL_SMOOTH_POINT_SIZE_GRANULARITY  = 0x0B13,
    GL_SMOOTH_LINE_WIDTH_RANGE        = 0x0B22,
    GL_SMOOTH_LINE_WIDTH_GRANULARITY  = 0x0B23,
    GL_ALIASED_LINE_WIDTH_RANGE       = 0x846E,

    // OpenGL 1.3
    GL_TEXTURE0                       = 0x84C0,
    GL_TEXTURE1                       = 0x84C1,
    GL_TEXTURE2                       = 0x84C2,
    GL_TEXTURE3                       = 0x84C3,
    GL_TEXTURE4                       = 0x84C4,
    GL_TEXTURE5                       = 0x84C5,
    GL_TEXTURE6                       = 0x84C6,
    GL_TEXTURE7                       = 0x84C7,
    GL_TEXTURE8                       = 0x84C8,
    GL_TEXTURE9                       = 0x84C9,
    GL_TEXTURE10                      = 0x84CA,
    GL_TEXTURE11                      = 0x84CB,
    GL_TEXTURE12                      = 0x84CC,
    GL_TEXTURE13                      = 0x84CD,
    GL_TEXTURE14                      = 0x84CE,
    GL_TEXTURE15                      = 0x84CF,
    GL_TEXTURE16                      = 0x84D0,
    GL_TEXTURE17                      = 0x84D1,
    GL_TEXTURE18                      = 0x84D2,
    GL_TEXTURE19                      = 0x84D3,
    GL_TEXTURE20                      = 0x84D4,
    GL_TEXTURE21                      = 0x84D5,
    GL_TEXTURE22                      = 0x84D6,
    GL_TEXTURE23                      = 0x84D7,
    GL_TEXTURE24                      = 0x84D8,
    GL_TEXTURE25                      = 0x84D9,
    GL_TEXTURE26                      = 0x84DA,
    GL_TEXTURE27                      = 0x84DB,
    GL_TEXTURE28                      = 0x84DC,
    GL_TEXTURE29                      = 0x84DD,
    GL_TEXTURE30                      = 0x84DE,
    GL_TEXTURE31                      = 0x84DF,
    GL_ACTIVE_TEXTURE                 = 0x84E0,
    GL_MULTISAMPLE                    = 0x809D,
    GL_SAMPLE_ALPHA_TO_COVERAGE       = 0x809E,
    GL_SAMPLE_ALPHA_TO_ONE            = 0x809F,
    GL_SAMPLE_COVERAGE                = 0x80A0,
    GL_SAMPLE_BUFFERS                 = 0x80A8,
    GL_SAMPLES                        = 0x80A9,
    GL_SAMPLE_COVERAGE_VALUE          = 0x80AA,
    GL_SAMPLE_COVERAGE_INVERT         = 0x80AB,
    GL_TEXTURE_CUBE_MAP               = 0x8513,
    GL_TEXTURE_BINDING_CUBE_MAP       = 0x8514,
    GL_TEXTURE_CUBE_MAP_POSITIVE_X    = 0x8515,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_X    = 0x8516,
    GL_TEXTURE_CUBE_MAP_POSITIVE_Y    = 0x8517,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Y    = 0x8518,
    GL_TEXTURE_CUBE_MAP_POSITIVE_Z    = 0x8519,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Z    = 0x851A,
    GL_PROXY_TEXTURE_CUBE_MAP         = 0x851B,
    GL_MAX_CUBE_MAP_TEXTURE_SIZE      = 0x851C,
    GL_COMPRESSED_RGB                 = 0x84ED,
    GL_COMPRESSED_RGBA                = 0x84EE,
    GL_TEXTURE_COMPRESSION_HINT       = 0x84EF,
    GL_TEXTURE_COMPRESSED_IMAGE_SIZE  = 0x86A0,
    GL_TEXTURE_COMPRESSED             = 0x86A1,
    GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2,
    GL_COMPRESSED_TEXTURE_FORMATS     = 0x86A3,
    GL_CLAMP_TO_BORDER                = 0x812D,

    // OpenGL 1.4
    GL_BLEND_DST_RGB                  = 0x80C8,
    GL_BLEND_SRC_RGB                  = 0x80C9,
    GL_BLEND_DST_ALPHA                = 0x80CA,
    GL_BLEND_SRC_ALPHA                = 0x80CB,
    GL_POINT_FADE_THRESHOLD_SIZE      = 0x8128,
    GL_DEPTH_COMPONENT16              = 0x81A5,
    GL_DEPTH_COMPONENT24              = 0x81A6,
    GL_DEPTH_COMPONENT32              = 0x81A7,
    GL_MIRRORED_REPEAT                = 0x8370,
    GL_MAX_TEXTURE_LOD_BIAS           = 0x84FD,
    GL_TEXTURE_LOD_BIAS               = 0x8501,
    GL_INCR_WRAP                      = 0x8507,
    GL_DECR_WRAP                      = 0x8508,
    GL_TEXTURE_DEPTH_SIZE             = 0x884A,
    GL_TEXTURE_COMPARE_MODE           = 0x884C,
    GL_TEXTURE_COMPARE_FUNC           = 0x884D,
    GL_CONSTANT_COLOR                 = 0x8001,
    GL_ONE_MINUS_CONSTANT_COLOR       = 0x8002,
    GL_CONSTANT_ALPHA                 = 0x8003,
    GL_ONE_MINUS_CONSTANT_ALPHA       = 0x8004,
    GL_FUNC_ADD                       = 0x8006,
    GL_MIN                            = 0x8007,
    GL_MAX                            = 0x8008,
    GL_FUNC_SUBTRACT                  = 0x800A,
    GL_FUNC_REVERSE_SUBTRACT          = 0x800B,

    // OpenGL 1.5
    GL_BUFFER_SIZE                    = 0x8764,
    GL_BUFFER_USAGE                   = 0x8765,
    GL_QUERY_COUNTER_BITS             = 0x8864,
    GL_CURRENT_QUERY                  = 0x8865,
    GL_QUERY_RESULT                   = 0x8866,
    GL_QUERY_RESULT_AVAILABLE         = 0x8867,
    GL_ARRAY_BUFFER                   = 0x8892,
    GL_ELEMENT_ARRAY_BUFFER           = 0x8893,
    GL_ARRAY_BUFFER_BINDING           = 0x8894,
    GL_ELEMENT_ARRAY_BUFFER_BINDING   = 0x8895,
    GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F,
    GL_READ_ONLY                      = 0x88B8,
    GL_WRITE_ONLY                     = 0x88B9,
    GL_READ_WRITE                     = 0x88BA,
    GL_BUFFER_ACCESS                  = 0x88BB,
    GL_BUFFER_MAPPED                  = 0x88BC,
    GL_BUFFER_MAP_POINTER             = 0x88BD,
    GL_STREAM_DRAW                    = 0x88E0,
    GL_STREAM_READ                    = 0x88E1,
    GL_STREAM_COPY                    = 0x88E2,
    GL_STATIC_DRAW                    = 0x88E4,
    GL_STATIC_READ                    = 0x88E5,
    GL_STATIC_COPY                    = 0x88E6,
    GL_DYNAMIC_DRAW                   = 0x88E8,
    GL_DYNAMIC_READ                   = 0x88E9,
    GL_DYNAMIC_COPY                   = 0x88EA,
    GL_SAMPLES_PASSED                 = 0x8914,
}

extern(System) @nogc nothrow {
    // OpenGL 1.2
    alias da_glDrawRangeElements = void function(GLenum,GLuint,GLuint,GLsizei,GLenum,const(GLvoid)*);
    alias da_glTexImage3D = void function(GLenum,GLint,GLint,GLsizei,GLsizei,GLsizei,GLint,GLenum,GLenum,const(GLvoid)*);
    alias da_glTexSubImage3D = void function(GLenum,GLint,GLint,GLint,GLint,GLsizei,GLsizei,GLsizei,GLenum,GLenum,const(GLvoid)*);
    alias da_glCopyTexSubImage3D = void function(GLenum,GLint,GLint,GLint,GLint,GLint,GLint,GLsizei,GLsizei);

    // OpenGL 1.3
    alias da_glActiveTexture = void function(GLenum);
    alias da_glSampleCoverage = void function(GLclampf,GLboolean);
    alias da_glCompressedTexImage3D = void function(GLenum,GLint,GLenum,GLsizei,GLsizei,GLsizei,GLint,GLsizei,const(GLvoid)*);
    alias da_glCompressedTexImage2D = void function(GLenum,GLint,GLenum,GLsizei,GLsizei,GLint,GLsizei,const(GLvoid)*);
    alias da_glCompressedTexImage1D = void function(GLenum,GLint,GLenum,GLsizei,GLint,GLsizei,const(GLvoid)*);
    alias da_glCompressedTexSubImage3D = void function(GLenum,GLint,GLint,GLint,GLint,GLsizei,GLsizei,GLsizei,GLenum,GLsizei,const(GLvoid)*);
    alias da_glCompressedTexSubImage2D = void function(GLenum,GLint,GLint,GLint,GLsizei,GLsizei,GLenum,GLsizei,const(GLvoid)*);
    alias da_glCompressedTexSubImage1D = void function(GLenum,GLint,GLint,GLsizei,GLenum,GLsizei,const(GLvoid)*);
    alias da_glGetCompressedTexImage = void function(GLenum,GLint,GLvoid*);

    // OpenGL 1.4
    alias da_glBlendFuncSeparate = void function(GLenum,GLenum,GLenum,GLenum);
    alias da_glMultiDrawArrays = void function(GLenum,const(GLint)*,const(GLsizei)*,GLsizei);
    alias da_glMultiDrawElements = void function(GLenum,const(GLsizei)*,GLenum,const(GLvoid)*,GLsizei);
    alias da_glPointParameterf = void function(GLenum,GLfloat);
    alias da_glPointParameterfv = void function(GLenum,const(GLfloat)*);
    alias da_glPointParameteri = void function(GLenum,GLint);
    alias da_glPointParameteriv = void function(GLenum,const(GLint)*);
    alias da_glBlendColor = void function(GLclampf,GLclampf,GLclampf,GLclampf);
    alias da_glBlendEquation = void function(GLenum);

    // OpenGL 1.5
    alias da_glGenQueries = void function(GLsizei,GLuint*);
    alias da_glDeleteQueries = void function(GLsizei,const(GLuint)*);
    alias da_glIsQuery = GLboolean function(GLuint);
    alias da_glBeginQuery = void function(GLenum,GLuint);
    alias da_glEndQuery = void function(GLenum);
    alias da_glGetQueryiv = void function(GLenum,GLenum,GLint*);
    alias da_glGetQueryObjectiv = void function(GLuint,GLenum,GLint*);
    alias da_glGetQueryObjectuiv = void function(GLuint,GLenum,GLuint*);
    alias da_glBindBuffer = void function(GLenum,GLuint);
    alias da_glDeleteBuffers = void function(GLsizei,const(GLuint)*);
    alias da_glGenBuffers = void function(GLsizei,GLuint*);
    alias da_glIsBuffer = GLboolean function(GLuint);
    alias da_glBufferData = void function(GLenum,GLsizeiptr,const(GLvoid)*,GLenum);
    alias da_glBufferSubData = void function(GLenum,GLintptr,GLsizeiptr,const(GLvoid)*);
    alias da_glGetBufferSubData = void function(GLenum,GLintptr,GLsizeiptr,GLvoid*);
    alias da_glMapBuffer = GLvoid* function(GLenum,GLenum);
    alias da_glUnmapBuffer = GLboolean function(GLenum);
    alias da_glGetBufferParameteriv = void function(GLenum,GLenum,GLint*);
    alias da_glGetBufferPointerv = void function(GLenum,GLenum,GLvoid*);
}};

enum _gl1Funcs =
q{
    // OpenGL 1.2
    da_glDrawRangeElements glDrawRangeElements;
    da_glTexImage3D glTexImage3D;
    da_glTexSubImage3D glTexSubImage3D;
    da_glCopyTexSubImage3D glCopyTexSubImage3D;

    // OpenGL 1.3
    da_glActiveTexture glActiveTexture;
    da_glSampleCoverage glSampleCoverage;
    da_glCompressedTexImage3D glCompressedTexImage3D;
    da_glCompressedTexImage2D glCompressedTexImage2D;
    da_glCompressedTexImage1D glCompressedTexImage1D;
    da_glCompressedTexSubImage3D glCompressedTexSubImage3D;
    da_glCompressedTexSubImage2D glCompressedTexSubImage2D;
    da_glCompressedTexSubImage1D glCompressedTexSubImage1D;
    da_glGetCompressedTexImage glGetCompressedTexImage;

    // OpenGL 1.4
    da_glBlendFuncSeparate glBlendFuncSeparate;
    da_glMultiDrawArrays glMultiDrawArrays;
    da_glMultiDrawElements glMultiDrawElements;
    da_glPointParameterf glPointParameterf;
    da_glPointParameterfv glPointParameterfv;
    da_glPointParameteri glPointParameteri;
    da_glPointParameteriv glPointParameteriv;
    da_glBlendColor glBlendColor;
    da_glBlendEquation glBlendEquation;

    // OpenGL 1.5
    da_glGenQueries glGenQueries;
    da_glDeleteQueries glDeleteQueries;
    da_glIsQuery glIsQuery;
    da_glBeginQuery glBeginQuery;
    da_glEndQuery glEndQuery;
    da_glGetQueryiv glGetQueryiv;
    da_glGetQueryObjectiv glGetQueryObjectiv;
    da_glGetQueryObjectuiv glGetQueryObjectuiv;
    da_glBindBuffer glBindBuffer;
    da_glDeleteBuffers glDeleteBuffers;
    da_glGenBuffers glGenBuffers;
    da_glIsBuffer glIsBuffer;
    da_glBufferData glBufferData;
    da_glBufferSubData glBufferSubData;
    da_glGetBufferSubData glGetBufferSubData;
    da_glMapBuffer glMapBuffer;
    da_glUnmapBuffer glUnmapBuffer;
    da_glGetBufferParameteriv glGetBufferParameteriv;
    da_glGetBufferPointerv glGetBufferPointerv;
};

enum _gl12Loader =
q{
    if(maxVer >= GLVersion.gl12) {
        bindGLFunc(cast(void**)&glDrawRangeElements, "glDrawRangeElements");
        bindGLFunc(cast(void**)&glTexImage3D, "glTexImage3D");
        bindGLFunc(cast(void**)&glTexSubImage3D, "glTexSubImage3D");
        bindGLFunc(cast(void**)&glCopyTexSubImage3D, "glCopyTexSubImage3D");
        glVer = GLVersion.gl12;
    }
};

enum _gl13Loader =
q{
    if(maxVer >= GLVersion.gl13) {
        bindGLFunc(cast(void**)&glActiveTexture, "glActiveTexture");
        bindGLFunc(cast(void**)&glSampleCoverage, "glSampleCoverage");
        bindGLFunc(cast(void**)&glCompressedTexImage3D, "glCompressedTexImage3D");
        bindGLFunc(cast(void**)&glCompressedTexImage2D, "glCompressedTexImage2D");
        bindGLFunc(cast(void**)&glCompressedTexImage1D, "glCompressedTexImage1D");
        bindGLFunc(cast(void**)&glCompressedTexSubImage3D, "glCompressedTexSubImage3D");
        bindGLFunc(cast(void**)&glCompressedTexSubImage2D, "glCompressedTexSubImage2D");
        bindGLFunc(cast(void**)&glCompressedTexSubImage1D, "glCompressedTexSubImage1D");
        bindGLFunc(cast(void**)&glGetCompressedTexImage, "glGetCompressedTexImage");
        glVer = GLVersion.gl13;
    }
};

enum _gl14Loader =
q{
    if(maxVer >= GLVersion.gl14) {
        bindGLFunc(cast(void**)&glBlendFuncSeparate, "glBlendFuncSeparate");
        bindGLFunc(cast(void**)&glMultiDrawArrays, "glMultiDrawArrays");
        bindGLFunc(cast(void**)&glMultiDrawElements, "glMultiDrawElements");
        bindGLFunc(cast(void**)&glPointParameterf, "glPointParameterf");
        bindGLFunc(cast(void**)&glPointParameterfv, "glPointParameterfv");
        bindGLFunc(cast(void**)&glPointParameteri, "glPointParameteri");
        bindGLFunc(cast(void**)&glPointParameteriv, "glPointParameteriv");
        bindGLFunc(cast(void**)&glBlendColor, "glBlendColor");
        bindGLFunc(cast(void**)&glBlendEquation, "glBlendEquation");
        glVer = GLVersion.gl14;
    }
};

enum _gl15Loader =
q{
    if(maxVer >= GLVersion.gl15) {
        bindGLFunc(cast(void**)&glGenQueries, "glGenQueries");
        bindGLFunc(cast(void**)&glDeleteQueries, "glDeleteQueries");
        bindGLFunc(cast(void**)&glIsQuery, "glIsQuery");
        bindGLFunc(cast(void**)&glBeginQuery, "glBeginQuery");
        bindGLFunc(cast(void**)&glEndQuery, "glEndQuery");
        bindGLFunc(cast(void**)&glGetQueryiv, "glGetQueryiv");
        bindGLFunc(cast(void**)&glGetQueryObjectiv, "glGetQueryObjectiv");
        bindGLFunc(cast(void**)&glGetQueryObjectuiv, "glGetQueryObjectuiv");
        bindGLFunc(cast(void**)&glBindBuffer, "glBindBuffer");
        bindGLFunc(cast(void**)&glDeleteBuffers, "glDeleteBuffers");
        bindGLFunc(cast(void**)&glGenBuffers, "glGenBuffers");
        bindGLFunc(cast(void**)&glIsBuffer, "glIsBuffer");
        bindGLFunc(cast(void**)&glBufferData, "glBufferData");
        bindGLFunc(cast(void**)&glBufferSubData, "glBufferSubData");
        bindGLFunc(cast(void**)&glGetBufferSubData, "glGetBufferSubData");
        bindGLFunc(cast(void**)&glMapBuffer, "glMapBuffer");
        bindGLFunc(cast(void**)&glUnmapBuffer, "glUnmapBuffer");
        bindGLFunc(cast(void**)&glGetBufferParameteriv, "glGetBufferParameteriv");
        bindGLFunc(cast(void**)&glGetBufferPointerv, "glGetBufferPointerv");
        glVer = GLVersion.gl15;
    }
};

enum gl1Decls = baseDecls ~ _gl1Decls;
enum gl1Funcs = baseFuncs ~ _gl1Funcs;
enum gl1Loader = _gl12Loader ~ _gl13Loader ~ _gl14Loader ~ _gl15Loader;