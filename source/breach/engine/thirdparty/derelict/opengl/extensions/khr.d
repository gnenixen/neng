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
module engine.thirdparty.derelict.opengl.extensions.khr;

import engine.thirdparty.derelict.opengl.types : usingContexts;
import engine.thirdparty.derelict.opengl.extensions.internal;

// KHR_context_flush_control <-- Core in GL 4.5
enum KHR_context_flush_control = "GL_KHR_context_flush_control";
enum khrContextFlushControlDecls =
q{
enum : uint
{
    GL_CONTEXT_RELEASE_BEHAVIOR       = 0x82FB,
    GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = 0x82FC,
}};

enum khrContextFlushControlLoader = makeLoader(KHR_context_flush_control, "", "gl45");
static if(!usingContexts) enum khrContextFlushControl = khrContextFlushControlDecls ~ khrContextFlushControlLoader;

// KHR_debug <-- Core in GL 4.3
enum KHR_debug = "GL_KHR_debug";
enum khrDebugDecls =
q{
enum : uint
{
    GL_DEBUG_OUTPUT_SYNCHRONOUS       = 0x8242,
    GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH = 0x8243,
    GL_DEBUG_CALLBACK_FUNCTION        = 0x8244,
    GL_DEBUG_CALLBACK_USER_PARAM      = 0x8245,
    GL_DEBUG_SOURCE_API               = 0x8246,
    GL_DEBUG_SOURCE_WINDOW_SYSTEM     = 0x8247,
    GL_DEBUG_SOURCE_SHADER_COMPILER   = 0x8248,
    GL_DEBUG_SOURCE_THIRD_PARTY       = 0x8249,
    GL_DEBUG_SOURCE_APPLICATION       = 0x824A,
    GL_DEBUG_SOURCE_OTHER             = 0x824B,
    GL_DEBUG_TYPE_ERROR               = 0x824C,
    GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR = 0x824D,
    GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR  = 0x824E,
    GL_DEBUG_TYPE_PORTABILITY         = 0x824F,
    GL_DEBUG_TYPE_PERFORMANCE         = 0x8250,
    GL_DEBUG_TYPE_OTHER               = 0x8251,
    GL_DEBUG_TYPE_MARKER              = 0x8268,
    GL_DEBUG_TYPE_PUSH_GROUP          = 0x8269,
    GL_DEBUG_TYPE_POP_GROUP           = 0x826A,
    GL_DEBUG_SEVERITY_NOTIFICATION    = 0x826B,
    GL_MAX_DEBUG_GROUP_STACK_DEPTH    = 0x826C,
    GL_DEBUG_GROUP_STACK_DEPTH        = 0x826D,
    GL_BUFFER                         = 0x82E0,
    GL_SHADER                         = 0x82E1,
    GL_PROGRAM                        = 0x82E2,
    GL_QUERY                          = 0x82E3,
    GL_PROGRAM_PIPELINE               = 0x82E4,
    GL_SAMPLER                        = 0x82E6,
    GL_DISPLAY_LIST                   = 0x82E7,
    GL_MAX_LABEL_LENGTH               = 0x82E8,
    GL_MAX_DEBUG_MESSAGE_LENGTH       = 0x9143,
    GL_MAX_DEBUG_LOGGED_MESSAGES      = 0x9144,
    GL_DEBUG_LOGGED_MESSAGES          = 0x9145,
    GL_DEBUG_SEVERITY_HIGH            = 0x9146,
    GL_DEBUG_SEVERITY_MEDIUM          = 0x9147,
    GL_DEBUG_SEVERITY_LOW             = 0x9148,
    GL_DEBUG_OUTPUT                   = 0x92E0,
    GL_CONTEXT_FLAG_DEBUG_BIT         = 0x00000002,
}
extern(System) nothrow alias GLDEBUGPROC = void function(GLenum,GLenum,GLuint,GLenum,GLsizei,const(GLchar)*,GLvoid*);
extern(System) @nogc nothrow {
    alias da_glDebugMessageControl = void function(GLenum,GLenum,GLenum,GLsizei,const(GLuint*),GLboolean);
    alias da_glDebugMessageInsert = void function(GLenum,GLenum,GLuint,GLenum,GLsizei,const(GLchar)*);
    alias da_glDebugMessageCallback = void function(GLDEBUGPROC,const(void)*);
    alias da_glGetDebugMessageLog = GLuint function(GLuint,GLsizei,GLenum*,GLenum*,GLuint*,GLenum*,GLsizei*,GLchar*);
    alias da_glPushDebugGroup = void function(GLenum,GLuint,GLsizei,const(GLchar)*);
    alias da_glPopDebugGroup = void function();
    alias da_glObjectLabel = void function(GLenum,GLuint,GLsizei,const(GLchar)*);
    alias da_glGetObjectLabel = void function(GLenum,GLuint,GLsizei,GLsizei*,GLchar*);
    alias da_glObjectPtrLabel = void function(const(void)*,GLsizei,const(GLchar)*);
    alias da_glGetObjectPtrLabel = void function(const(void)*,GLsizei,GLsizei*,GLchar*);
}};

enum khrDebugFuncs =
q{
    da_glDebugMessageControl glDebugMessageControl;
    da_glDebugMessageInsert glDebugMessageInsert;
    da_glDebugMessageCallback glDebugMessageCallback;
    da_glGetDebugMessageLog glGetDebugMessageLog;
    da_glPushDebugGroup glPushDebugGroup;
    da_glPopDebugGroup glPopDebugGroup;
    da_glObjectLabel glObjectLabel;
    da_glGetObjectLabel glGetObjectLabel;
    da_glObjectPtrLabel glObjectPtrLabel;
    da_glGetObjectPtrLabel glGetObjectPtrLabel;
};

enum khrDebugLoaderImpl =
q{
    bindGLFunc(cast(void**)&glDebugMessageControl, "glDebugMessageControl");
    bindGLFunc(cast(void**)&glDebugMessageInsert, "glDebugMessageInsert");
    bindGLFunc(cast(void**)&glDebugMessageCallback, "glDebugMessageCallback");
    bindGLFunc(cast(void**)&glGetDebugMessageLog, "glGetDebugMessageLog");
    bindGLFunc(cast(void**)&glPushDebugGroup, "glPushDebugGroup");
    bindGLFunc(cast(void**)&glPopDebugGroup, "glPopDebugGroup");
    bindGLFunc(cast(void**)&glObjectLabel, "glObjectLabel");
    bindGLFunc(cast(void**)&glGetObjectLabel, "glGetObjectLabel");
    bindGLFunc(cast(void**)&glObjectPtrLabel, "glObjectPtrLabel");
    bindGLFunc(cast(void**)&glGetObjectPtrLabel, "glGetObjectPtrLabel");
};

enum khrDebugLoader = makeLoader(KHR_debug, khrDebugLoaderImpl, "gl43");
static if(!usingContexts) enum khrDebug = khrDebugDecls ~ khrDebugFuncs.makeGShared() ~ khrDebugLoader;

// KHR_no_error
enum KHR_no_error = "GL_KHR_no_error";
enum khrNoErrorDecls = `enum uint GL_CONTEXT_FLAG_NO_ERROR_BIT_KHR = 0x00000008;`;
enum khrNoErrorLoader = makeExtLoader(KHR_no_error);
static if(!usingContexts) enum khrNoError = khrNoErrorDecls ~ khrNoErrorLoader;

// KHR_robustness <-- Core in GL 4.5
enum KHR_robustness = "GL_KHR_robustness";
enum khrRobustnessDecls =
q{
enum : uint
{
    GL_GUILTY_CONTEXT_RESET           = 0x8253,
    GL_INNOCENT_CONTEXT_RESET         = 0x8254,
    GL_UNKNOWN_CONTEXT_RESET          = 0x8255,
    GL_RESET_NOTIFICATION_STRATEGY    = 0x8256,
    GL_LOSE_CONTEXT_ON_RESET          = 0x8252,
    GL_NO_RESET_NOTIFICATION          = 0x8261,
    GL_CONTEXT_LOST                   = 0x0507,
    GL_CONTEXT_ROBUST_ACCESS          = 0x90F3,
}
extern(System) @nogc nothrow
{
    alias da_glGetGraphicsResetStatus = GLenum function();
    alias da_glReadnPixels = void function(GLint,GLint,GLsizei,GLsizei,GLenum,GLenum,GLsizei,void*);
    alias da_glGetnUniformfv = void function(GLuint,GLint,GLsizei,GLfloat*);
    alias da_glGetnUniformiv = void function(GLuint,GLint,GLsizei,GLint*);
    alias da_glGetnUniformuiv = void function(GLuint,GLint,GLsizei,GLuint*);
}};

enum khrRobustnessFuncs =
q{
    da_glGetGraphicsResetStatus glGetGraphicsResetStatus;
    da_glReadnPixels glReadnPixels;
    da_glGetnUniformfv glGetnUniformfv;
    da_glGetnUniformiv glGetnUniformiv;
    da_glGetnUniformuiv glGetnUniformuiv;
};

enum khrRobustnessLoaderImpl =
q{
    bindGLFunc(cast(void**)&glGetGraphicsResetStatus, "glGetGraphicsResetStatus");
    bindGLFunc(cast(void**)&glReadnPixels, "glReadnPixels");
    bindGLFunc(cast(void**)&glGetnUniformfv, "glGetnUniformfv");
    bindGLFunc(cast(void**)&glGetnUniformiv, "glGetnUniformiv");
    bindGLFunc(cast(void**)&glGetnUniformuiv, "glGetnUniformuiv");
};

enum khrRobustnessLoader = makeLoader(KHR_robustness, khrRobustnessLoaderImpl, "gl45");
static if(!usingContexts) enum khrRobustness = khrRobustnessDecls ~ khrRobustnessFuncs.makeGShared() ~ khrRobustnessLoader;

// KHR_texture_compression_astc_hdr
enum KHR_texture_compression_astc_hdr = "GL_KHR_texture_compression_astc_hdr";
enum khrTextureCompressionASTCHDRDecls =
q{
enum : uint
{
    GL_COMPRESSED_RGBA_ASTC_4x4_KHR   = 0x93B0,
    GL_COMPRESSED_RGBA_ASTC_5x4_KHR   = 0x93B1,
    GL_COMPRESSED_RGBA_ASTC_5x5_KHR   = 0x93B2,
    GL_COMPRESSED_RGBA_ASTC_6x5_KHR   = 0x93B3,
    GL_COMPRESSED_RGBA_ASTC_6x6_KHR   = 0x93B4,
    GL_COMPRESSED_RGBA_ASTC_8x5_KHR   = 0x93B5,
    GL_COMPRESSED_RGBA_ASTC_8x6_KHR   = 0x93B6,
    GL_COMPRESSED_RGBA_ASTC_8x8_KHR   = 0x93B7,
    GL_COMPRESSED_RGBA_ASTC_10x5_KHR  = 0x93B8,
    GL_COMPRESSED_RGBA_ASTC_10x6_KHR  = 0x93B9,
    GL_COMPRESSED_RGBA_ASTC_10x8_KHR  = 0x93BA,
    GL_COMPRESSED_RGBA_ASTC_10x10_KHR = 0x93BB,
    GL_COMPRESSED_RGBA_ASTC_12x10_KHR = 0x93BC,
    GL_COMPRESSED_RGBA_ASTC_12x12_KHR = 0x93BD,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR = 0x93D0,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR = 0x93D1,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR = 0x93D2,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR = 0x93D3,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR = 0x93D4,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR = 0x93D5,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR = 0x93D6,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR = 0x93D7,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR = 0x93D8,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR = 0x93D9,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR = 0x93DA,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR = 0x93DB,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR = 0x93DC,
    GL_COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR = 0x93DD,
}};

enum khrTextureCompressionASTCHDRLoader = makeExtLoader(KHR_texture_compression_astc_hdr);
static if(!usingContexts) enum khrTextureCompressionASTCHDR = khrTextureCompressionASTCHDRDecls ~ khrTextureCompressionASTCHDRLoader;

// KHR_texture_compression_astc_ldr
enum KHR_texture_compression_astc_ldr = "GL_KHR_texture_compression_astc_ldr";
enum khrTextureCompressionASTCLDRLoader = makeExtLoader(KHR_texture_compression_astc_ldr);
static if(!usingContexts) enum khrTextureCompressionASTCLDR = khrTextureCompressionASTCLDRLoader;

// KHR_texture_compression_astc_sliced_3d
enum KHR_texture_compression_astc_sliced_3d = "GL_KHR_texture_compression_astc_sliced_3d";
enum khrTextureCompressionASTCSliced3DLoader = makeExtLoader(KHR_texture_compression_astc_sliced_3d);
static if(!usingContexts) enum khrTextureCompressionASTCSliced3D = khrTextureCompressionASTCSliced3DLoader;
