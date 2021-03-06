/*

Boost Software License - Version 1.0 - August 17th,2003

Permission is hereby granted,free of charge,to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use,reproduce,display,distribute,
execute,and transmit the Software,and to prepare derivative works of the
Software,and to permit third-parties to whom the Software is furnished to
do so,all subject to the following:

The copyright notices in the Software and this entire statement,including
the above license grant,this restriction and the following disclaimer,
must be included in all copies of the Software,in whole or in part,and
all derivative works of the Software,unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS",WITHOUT WARRANTY OF ANY KIND,EXPRESS OR
IMPLIED,INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE,TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY,WHETHER IN CONTRACT,TORT OR OTHERWISE,
ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module engine.thirdparty.derelict.opengl.extensions.arb_g;

import engine.thirdparty.derelict.opengl.types : usingContexts;
import engine.thirdparty.derelict.opengl.extensions.internal;

// ARB_geometry_shader4
enum ARB_geometry_shader4 = "GL_ARB_geometry_shader4";
enum arbGeometryShader4Decls =
q{
enum : uint
{
    GL_LINES_ADJACENCY_ARB            = 0x000A,
    GL_LINE_STRIP_ADJACENCY_ARB       = 0x000B,
    GL_TRIANGLES_ADJACENCY_ARB        = 0x000C,
    GL_TRIANGLE_STRIP_ADJACENCY_ARB   = 0x000D,
    GL_PROGRAM_POINT_SIZE_ARB         = 0x8642,
    GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS_ARB = 0x8C29,
    GL_FRAMEBUFFER_ATTACHMENT_LAYERED_ARB = 0x8DA7,
    GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS_ARB = 0x8DA8,
    GL_FRAMEBUFFER_INCOMPLETE_LAYER_COUNT_ARB = 0x8DA9,
    GL_GEOMETRY_SHADER_ARB            = 0x8DD9,
    GL_GEOMETRY_VERTICES_OUT_ARB      = 0x8DDA,
    GL_GEOMETRY_INPUT_TYPE_ARB        = 0x8DDB,
    GL_GEOMETRY_OUTPUT_TYPE_ARB       = 0x8DDC,
    GL_MAX_GEOMETRY_VARYING_COMPONENTS_ARB = 0x8DDD,
    GL_MAX_VERTEX_VARYING_COMPONENTS_ARB = 0x8DDE,
    GL_MAX_GEOMETRY_UNIFORM_COMPONENTS_ARB = 0x8DDF,
    GL_MAX_GEOMETRY_OUTPUT_VERTICES_ARB = 0x8DE0,
    GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS_ARB = 0x8DE1,
}
extern(System) @nogc nothrow {
    alias da_glProgramParameteriARB = void function(GLuint,GLenum,GLint);
    alias da_glFramebufferTextureARB = void function(GLuint,GLenum,GLuint,GLint);
    alias da_glFramebufferTextureLayerARB = void function(GLuint,GLenum,GLuint,GLint,GLint);
    alias da_glFramebufferTextureFaceARB = void function(GLuint,GLenum,GLuint,GLint,GLenum);
}};

enum arbGeometryShader4Funcs =
q{
    da_glProgramParameteriARB glProgramParameteriARB;
    da_glFramebufferTextureARB glFramebufferTextureARB;
    da_glFramebufferTextureLayerARB glFramebufferTextureLayerARB;
    da_glFramebufferTextureFaceARB glFramebufferTextureFaceARB;
};

enum arbGeometryShader4LoaderImpl =
q{
    bindGLFunc(cast(void**)&glProgramParameteriARB,"glProgramParameteriARB");
    bindGLFunc(cast(void**)&glFramebufferTextureARB,"glFramebufferTextureARB");
    bindGLFunc(cast(void**)&glFramebufferTextureLayerARB,"glFramebufferTextureLayerARB");
    bindGLFunc(cast(void**)&glFramebufferTextureFaceARB,"glFramebufferTextureFaceARB");
};

enum arbGeometryShader4Loader = makeExtLoader(ARB_geometry_shader4, arbGeometryShader4LoaderImpl);
static if(!usingContexts) enum arbGeometryShader4 = arbGeometryShader4Decls ~ arbGeometryShader4Funcs.makeGShared() ~ arbGeometryShader4Loader;

// ARB_get_program_binary <-- Core in GL 4.1
enum ARB_get_program_binary = "GL_ARB_get_program_binary";
enum arbGetProgramBinaryDecls =
q{
enum : uint
{
    GL_PROGRAM_BINARY_RETRIEVABLE_HINT = 0x8257,
    GL_PROGRAM_BINARY_LENGTH          = 0x8741,
    GL_NUM_PROGRAM_BINARY_FORMATS     = 0x87FE,
    GL_PROGRAM_BINARY_FORMATS         = 0x87FF,
}
extern(System) @nogc nothrow {
    alias da_glGetProgramBinary = void function(GLuint,GLsizei,GLsizei*,GLenum*,GLvoid*);
    alias da_glProgramBinary = void function(GLuint,GLenum,const(GLvoid)*,GLsizei);
    alias da_glProgramParameteri = void function(GLuint,GLenum,GLint);
}};

enum arbGetProgramBinaryFuncs =
q{
    da_glGetProgramBinary glGetProgramBinary;
    da_glProgramBinary glProgramBinary;
    da_glProgramParameteri glProgramParameteri;
};

enum arbGetProgramBinaryLoaderImpl =
q{
    bindGLFunc(cast(void**)&glGetProgramBinary,"glGetProgramBinary");
    bindGLFunc(cast(void**)&glProgramBinary,"glProgramBinary");
    bindGLFunc(cast(void**)&glProgramParameteri,"glProgramParameteri");
};

enum arbGetProgramBinaryLoader = makeLoader(ARB_get_program_binary,arbGetProgramBinaryLoaderImpl,"gl41");
static if(!usingContexts) enum arbGetProgramBinary = arbGetProgramBinaryDecls ~ arbGetProgramBinaryFuncs.makeGShared() ~ arbGetProgramBinaryLoader;

// ARB_get_texture_sub_image <-- Core in GL 4.5
enum ARB_get_texture_sub_image = "GL_ARB_get_texture_sub_image";
enum arbGetTextureSubImageDecls =
q{
extern(System) @nogc nothrow
{
    alias da_glGetTextureSubImage = void function(GLuint,GLint,GLint,GLint,GLint,GLsizei,GLsizei,GLsizei,GLenum,GLenum,GLsizei,void*);
    alias da_glGetCompressedTextureSubImage = void function(GLuint,GLint,GLint,GLint,GLint,GLsizei,GLsizei,GLsizei,GLsizei,void*);
}};

enum arbGetTextureSubImageFuncs =
q{
    da_glGetTextureSubImage glGetTextureSubImage;
    da_glGetCompressedTextureSubImage glGetCompressedTextureSubImage;
};

enum arbGetTextureSubImageLoaderImpl =
q{
    bindGLFunc(cast(void**)&glGetTextureSubImage,"glGetTextureSubImage");
    bindGLFunc(cast(void**)&glGetCompressedTextureSubImage,"glGetCompressedTextureSubImage");
};

enum arbGetTextureSubImageLoader = makeLoader(ARB_get_texture_sub_image,arbGetTextureSubImageLoaderImpl,"gl45");
static if(!usingContexts) enum arbGetTextureSubImage = arbGetTextureSubImageDecls ~ arbGetTextureSubImageFuncs.makeGShared() ~ arbGetTextureSubImageLoader;

// ARB_gpu_shader5 <-- Core in GL 4.0
enum ARB_gpu_shader5 = "GL_ARB_gpu_shader5";
enum arbGPUShader5Decls =
q{
enum : uint
{
    GL_GEOMETRY_SHADER_INVOCATIONS    = 0x887F,
    GL_MAX_GEOMETRY_SHADER_INVOCATIONS = 0x8E5A,
    GL_MIN_FRAGMENT_INTERPOLATION_OFFSET = 0x8E5B,
    GL_MAX_FRAGMENT_INTERPOLATION_OFFSET = 0x8E5C,
    GL_FRAGMENT_INTERPOLATION_OFFSET_BITS = 0x8E5D,
}};

enum arbGPUShader5Loader = makeLoader(ARB_gpu_shader5,"","gl40");
static if(!usingContexts) enum arbGPUShader5 = arbGPUShader5Decls ~ arbGPUShader5Loader;

// ARB_gpu_shader_fp64 <-- Core in GL 4.0
enum ARB_gpu_shader_fp64 = "GL_ARB_gpu_shader_fp64";
enum arbGPUShaderFP64Decls =
q{
enum : uint
{
    GL_DOUBLE_VEC2                    = 0x8FFC,
    GL_DOUBLE_VEC3                    = 0x8FFD,
    GL_DOUBLE_VEC4                    = 0x8FFE,
    GL_DOUBLE_MAT2                    = 0x8F46,
    GL_DOUBLE_MAT3                    = 0x8F47,
    GL_DOUBLE_MAT4                    = 0x8F48,
    GL_DOUBLE_MAT2x3                  = 0x8F49,
    GL_DOUBLE_MAT2x4                  = 0x8F4A,
    GL_DOUBLE_MAT3x2                  = 0x8F4B,
    GL_DOUBLE_MAT3x4                  = 0x8F4C,
    GL_DOUBLE_MAT4x2                  = 0x8F4D,
    GL_DOUBLE_MAT4x3                  = 0x8F4E,
}
extern(System) @nogc nothrow {
    alias da_glUniform1d = void function(GLint,GLdouble);
    alias da_glUniform2d = void function(GLint,GLdouble,GLdouble);
    alias da_glUniform3d = void function(GLint,GLdouble,GLdouble,GLdouble);
    alias da_glUniform4d = void function(GLint,GLdouble,GLdouble,GLdouble,GLdouble);
    alias da_glUniform1dv = void function(GLint,GLsizei,const(GLdouble)*);
    alias da_glUniform2dv = void function(GLint,GLsizei,const(GLdouble)*);
    alias da_glUniform3dv = void function(GLint,GLsizei,const(GLdouble)*);
    alias da_glUniform4dv = void function(GLint,GLsizei,const(GLdouble)*);
    alias da_glUniformMatrix2dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix3dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix4dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix2x3dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix2x4dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix3x2dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix3x4dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix4x2dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glUniformMatrix4x3dv = void function(GLint,GLsizei,GLboolean,const(GLdouble)*);
    alias da_glGetUniformdv = void function(GLuint,GLint,GLdouble*);
}};

enum arbGPUShaderFP64Funcs =
q{
    da_glUniform1d glUniform1d;
    da_glUniform2d glUniform2d;
    da_glUniform3d glUniform3d;
    da_glUniform4d glUniform4d;
    da_glUniform1dv glUniform1dv;
    da_glUniform2dv glUniform2dv;
    da_glUniform3dv glUniform3dv;
    da_glUniform4dv glUniform4dv;
    da_glUniformMatrix2dv glUniformMatrix2dv;
    da_glUniformMatrix3dv glUniformMatrix3dv;
    da_glUniformMatrix4dv glUniformMatrix4dv;
    da_glUniformMatrix2x3dv glUniformMatrix2x3dv;
    da_glUniformMatrix2x4dv glUniformMatrix2x4dv;
    da_glUniformMatrix3x2dv glUniformMatrix3x2dv;
    da_glUniformMatrix3x4dv glUniformMatrix3x4dv;
    da_glUniformMatrix4x2dv glUniformMatrix4x2dv;
    da_glUniformMatrix4x3dv glUniformMatrix4x3dv;
    da_glGetUniformdv glGetUniformdv;
};

enum arbGPUShaderFP64LoaderImpl =
q{
    bindGLFunc(cast(void**)&glUniform1d,"glUniform1d");
    bindGLFunc(cast(void**)&glUniform2d,"glUniform2d");
    bindGLFunc(cast(void**)&glUniform3d,"glUniform3d");
    bindGLFunc(cast(void**)&glUniform4d,"glUniform4d");
    bindGLFunc(cast(void**)&glUniform1dv,"glUniform1dv");
    bindGLFunc(cast(void**)&glUniform2dv,"glUniform2dv");
    bindGLFunc(cast(void**)&glUniform3dv,"glUniform3dv");
    bindGLFunc(cast(void**)&glUniform4dv,"glUniform4dv");
    bindGLFunc(cast(void**)&glUniformMatrix2dv,"glUniformMatrix2dv");
    bindGLFunc(cast(void**)&glUniformMatrix3dv,"glUniformMatrix3dv");
    bindGLFunc(cast(void**)&glUniformMatrix4dv,"glUniformMatrix4dv");
    bindGLFunc(cast(void**)&glUniformMatrix2x3dv,"glUniformMatrix2x3dv");
    bindGLFunc(cast(void**)&glUniformMatrix2x4dv,"glUniformMatrix2x4dv");
    bindGLFunc(cast(void**)&glUniformMatrix3x2dv,"glUniformMatrix3x2dv");
    bindGLFunc(cast(void**)&glUniformMatrix3x4dv,"glUniformMatrix3x4dv");
    bindGLFunc(cast(void**)&glUniformMatrix4x2dv,"glUniformMatrix4x2dv");
    bindGLFunc(cast(void**)&glUniformMatrix4x3dv,"glUniformMatrix4x3dv");
    bindGLFunc(cast(void**)&glGetUniformdv,"glGetUniformdv");
};

enum arbGPUShaderFP64Loader = makeLoader(ARB_gpu_shader_fp64,arbGPUShaderFP64LoaderImpl,"gl40");
static if(!usingContexts) enum arbGPUShaderFP64 = arbGPUShaderFP64Decls ~ arbGPUShaderFP64Funcs.makeGShared() ~ arbGPUShaderFP64Loader;