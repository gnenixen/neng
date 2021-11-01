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
module engine.thirdparty.derelict.opengl.extensions.arb_e;

import engine.thirdparty.derelict.opengl.types : usingContexts;
import engine.thirdparty.derelict.opengl.extensions.internal;

// ARB_enhanced_layouts <-- Core in GL 4.4
enum ARB_enhanced_layouts = "GL_ARB_enhanced_layouts";
enum arbEnhancedLayoutsDecls =
q{
enum : uint
{
    GL_LOCATION_COMPONENT             = 0x934A,
    GL_TRANSFORM_FEEDBACK_BUFFER_INDEX = 0x934B,
    GL_TRANSFORM_FEEDBACK_BUFFER_STRIDE = 0x934C,
}};
enum arbEnhancedLayoutsLoader = makeLoader(ARB_enhanced_layouts, "", "gl44");
static if(!usingContexts) enum arbEnhancedLayouts = arbEnhancedLayoutsDecls ~ arbEnhancedLayoutsLoader;

// ARB_ES2_compatibility <-- Core in GL 4.1
enum ARB_ES2_compatibility = "GL_ARB_ES2_compatibility";
enum arbES2CompatibilityDecls =
q{
enum : uint
{
    GL_FIXED                          = 0x140C,
    GL_IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A,
    GL_IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B,
    GL_LOW_FLOAT                      = 0x8DF0,
    GL_MEDIUM_FLOAT                   = 0x8DF1,
    GL_HIGH_FLOAT                     = 0x8DF2,
    GL_LOW_INT                        = 0x8DF3,
    GL_MEDIUM_INT                     = 0x8DF4,
    GL_HIGH_INT                       = 0x8DF5,
    GL_SHADER_COMPILER                = 0x8DFA,
    GL_NUM_SHADER_BINARY_FORMATS      = 0x8DF9,
    GL_MAX_VERTEX_UNIFORM_VECTORS     = 0x8DFB,
    GL_MAX_VARYING_VECTORS            = 0x8DFC,
    GL_MAX_FRAGMENT_UNIFORM_VECTORS   = 0x8DFD,
}
extern(System) @nogc nothrow {
    alias da_glReleaseShaderCompiler = void function();
    alias da_glShaderBinary = void function(GLsizei, const(GLuint)*, GLenum, const(GLvoid)*, GLsizei);
    alias da_glGetShaderPrecisionFormat = void function(GLenum, GLenum, GLint*, GLint*);
    alias da_glDepthRangef = void function(GLclampf, GLclampf);
    alias da_glClearDepthf = void function(GLclampf);
}};

enum arbES2CompatibilityFuncs =
q{
    da_glReleaseShaderCompiler glReleaseShaderCompiler;
    da_glShaderBinary glShaderBinary;
    da_glGetShaderPrecisionFormat glGetShaderPrecisionFormat;
    da_glDepthRangef glDepthRangef;
    da_glClearDepthf glClearDepthf;
};

enum arbES2CompatibilityLoaderImpl =
q{
    bindGLFunc(cast(void**)&glReleaseShaderCompiler, "glReleaseShaderCompiler");
    bindGLFunc(cast(void**)&glShaderBinary, "glShaderBinary");
    bindGLFunc(cast(void**)&glGetShaderPrecisionFormat, "glGetShaderPrecisionFormat");
    bindGLFunc(cast(void**)&glDepthRangef, "glDepthRangef");
    bindGLFunc(cast(void**)&glClearDepthf, "glClearDepthf");
};

enum arbES2CompatibilityLoader = makeLoader(ARB_ES2_compatibility, arbES2CompatibilityLoaderImpl, "gl41");
static if(!usingContexts) enum arbES2Compatibility = arbES2CompatibilityDecls ~ arbES2CompatibilityFuncs.makeGShared() ~ arbES2CompatibilityLoader;

// ARB_ES3_compatibility <-- Core in GL 4.3
enum ARB_ES3_compatibility = "GL_ARB_ES3_compatibility";
enum arbES3CompatibilityDecls =
q{
enum : uint
{
    GL_COMPRESSED_RGB8_ETC2           = 0x9274,
    GL_COMPRESSED_SRGB8_ETC2          = 0x9275,
    GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276,
    GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277,
    GL_COMPRESSED_RGBA8_ETC2_EAC      = 0x9278,
    GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279,
    GL_COMPRESSED_R11_EAC             = 0x9270,
    GL_COMPRESSED_SIGNED_R11_EAC      = 0x9271,
    GL_COMPRESSED_RG11_EAC            = 0x9272,
    GL_COMPRESSED_SIGNED_RG11_EAC     = 0x9273,
    GL_PRIMITIVE_RESTART_FIXED_INDEX  = 0x8D69,
    GL_ANY_SAMPLES_PASSED_CONSERVATIVE = 0x8D6A,
    GL_MAX_ELEMENT_INDEX              = 0x8D6B,
}};

enum arbES3CompatibilityLoader = makeLoader(ARB_ES3_compatibility, "", "gl43");
static if(!usingContexts) enum arbES3Compatibility = arbES3CompatibilityDecls ~ arbES3CompatibilityLoader;

// ARB_ES3_1_compatibility <-- Core in GL 4.5
enum ARB_ES3_1_compatibility = "GL_ARB_ES3_1_compatibility";
enum arbES31CompatibilityDecls = `extern(System) @nogc nothrow alias da_glMemoryBarrierByRegion = void function(GLbitfield);`;
enum arbES31CompatibilityFuncs = `da_glMemoryBarrierByRegion glMemoryBarrierByRegion;`;
enum arbES31CompatibilityLoaderImpl = `bindGLFunc(cast(void**)&glMemoryBarrierByRegion, "glMemoryBarrierByRegion");`;
enum arbES31CompatibilityLoader = makeLoader(ARB_ES3_1_compatibility, arbES31CompatibilityLoaderImpl, "gl45");
static if(!usingContexts) enum arbES31Compatibility = arbES31CompatibilityDecls ~ arbES31CompatibilityFuncs.makeGShared() ~ arbES31CompatibilityLoader;

// ARB_explicit_attrib_location <-- Core in GL 3.3
enum ARB_explicit_attrib_location = "GL_ARB_explicit_attrib_location";
enum arbExplicitAttribLocationLoader = makeLoader(ARB_explicit_attrib_location, "", "gl33");
static if(!usingContexts) enum arbExplicitAttribLocation = arbExplicitAttribLocationLoader;

// ARB_explicit_uniform_location <-- Core in GL 4.3
enum ARB_explicit_uniform_location = "GL_ARB_explicit_uniform_location";
enum arbExplicitUniformLocationDecls = `enum uint GL_MAX_UNIFORM_LOCATIONS = 0x826E;`;
enum arbExplicitUniformLocationLoader = makeLoader(ARB_explicit_uniform_location, "", "gl43");
static if(!usingContexts) enum arbExplicitUniformLocation = arbExplicitUniformLocationDecls ~ arbExplicitUniformLocationLoader;
