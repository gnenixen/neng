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
module engine.thirdparty.derelict.opengl.extensions.arb_m;

import engine.thirdparty.derelict.opengl.types : usingContexts;
import engine.thirdparty.derelict.opengl.extensions.internal;

// ARB_map_buffer_alignment <-- Core in GL 4.2
enum ARB_map_buffer_alignment = "GL_ARB_map_buffer_alignment";
enum arbMapBufferAlignmentDecls = `enum uint GL_MIN_MAP_BUFFER_ALIGNMENT = 0x90BC;`;
enum arbMapBufferAlignmentLoader = makeLoader(ARB_map_buffer_alignment, "", "gl42");
static if(!usingContexts) enum arbMapBufferAlignment = arbMapBufferAlignmentDecls ~ arbMapBufferAlignmentLoader;

// ARB_map_buffer_range <-- Core in GL 3.0
enum ARB_map_buffer_range = "GL_ARB_map_buffer_range";
enum arbMapBufferRangeDecls =
q{
enum : uint
{
    GL_MAP_READ_BIT                   = 0x0001,
    GL_MAP_WRITE_BIT                  = 0x0002,
    GL_MAP_INVALIDATE_RANGE_BIT       = 0x0004,
    GL_MAP_INVALIDATE_BUFFER_BIT      = 0x0008,
    GL_MAP_FLUSH_EXPLICIT_BIT         = 0x0010,
    GL_MAP_UNSYNCHRONIZED_BIT         = 0x0020,
}

extern(System) @nogc nothrow {
    alias da_glMapBufferRange = GLvoid* function(GLenum, GLintptr, GLsizeiptr, GLbitfield);
    alias da_glFlushMappedBufferRange = void function(GLenum, GLintptr, GLsizeiptr);
}};

enum arbMapBufferRangeFuncs =
q{
    da_glMapBufferRange glMapBufferRange;
    da_glFlushMappedBufferRange glFlushMappedBufferRange;
};

enum arbMapBufferRangeLoaderImpl =
q{
    bindGLFunc(cast(void**)&glMapBufferRange, "glMapBufferRange");
    bindGLFunc(cast(void**)&glFlushMappedBufferRange, "glFlushMappedBufferRange");
};

enum arbMapBufferRangeLoader = makeLoader(ARB_map_buffer_range, arbMapBufferRangeLoaderImpl, "gl30");
static if(!usingContexts) enum arbMapBufferRange = arbMapBufferRangeDecls ~ arbMapBufferRangeFuncs.makeGShared() ~ arbMapBufferRangeLoader;

// ARB_multi_bind <-- Core in GL 4.4
enum ARB_multi_bind = "GL_ARB_multi_bind";
enum arbMultBindDecls =
q{
extern(System) @nogc nothrow {
    alias da_glBindBuffersBase = void function(GLenum,GLuint,GLsizei,const(GLuint)*);
    alias da_glBindBuffersRange = void function(GLenum,GLuint,GLsizei,const(GLuint)*,const(GLintptr)*,const(GLsizeiptr)*);
    alias da_glBindTextures = void function(GLuint,GLsizei,const(GLuint)*);
    alias da_glBindSamplers = void function(GLuint,GLsizei,const(GLuint)*);
    alias da_glBindImageTextures = void function(GLuint,GLsizei,const(GLuint)*);
    alias da_glBindVertexBuffers = void function(GLuint,GLsizei,const(GLuint)*,const(GLintptr)*,const(GLsizei)*);
}};

enum arbMultBindFuncs =
q{
    da_glBindBuffersBase glBindBuffersBase;
    da_glBindBuffersRange glBindBuffersRange;
    da_glBindTextures glBindTextures;
    da_glBindSamplers glBindSamplers;
    da_glBindImageTextures glBindImageTextures;
    da_glBindVertexBuffers glBindVertexBuffers;
};

enum arbMultBindLoaderImpl =
q{
    bindGLFunc(cast(void**)&glBindBuffersBase, "glBindBuffersBase");
    bindGLFunc(cast(void**)&glBindBuffersRange, "glBindBuffersRange");
    bindGLFunc(cast(void**)&glBindTextures, "glBindTextures");
    bindGLFunc(cast(void**)&glBindSamplers, "glBindSamplers");
    bindGLFunc(cast(void**)&glBindImageTextures, "glBindImageTextures");
    bindGLFunc(cast(void**)&glBindVertexBuffers, "glBindVertexBuffers");
};

enum arbMultBindLoader = makeLoader(ARB_multi_bind, arbMultBindLoaderImpl, "gl44");
static if(!usingContexts) enum arbMultBind = arbMultBindDecls ~ arbMultBindFuncs.makeGShared() ~ arbMultBindLoader;

// ARB_multi_draw_indirect <-- Core in GL 4.3
enum ARB_multi_draw_indirect = "GL_ARB_multi_draw_indirect";
enum arbMultiDrawIndirectDecls =
q{
extern(System) @nogc nothrow {
    alias da_glMultiDrawArraysIndirect = void function(GLenum,const(void)*,GLsizei,GLsizei);
    alias da_glMultiDrawElementsIndirect = void function(GLenum,GLenum,const(void)*,GLsizei,GLsizei);
}};

enum arbMultiDrawIndirectFuncs =
q{
    da_glMultiDrawArraysIndirect glMultiDrawArraysIndirect;
    da_glMultiDrawElementsIndirect glMultiDrawElementsIndirect;
};

enum arbMultiDrawIndirectLoaderImpl =
q{
    bindGLFunc(cast(void**)&glMultiDrawArraysIndirect, "glMultiDrawArraysIndirect");
    bindGLFunc(cast(void**)&glMultiDrawElementsIndirect, "glMultiDrawElementsIndirect");
};

enum arbMultiDrawIndirectLoader = makeLoader(ARB_multi_draw_indirect, arbMultiDrawIndirectLoaderImpl, "gl43");
static if(!usingContexts) enum arbMultiDrawIndirect = arbMultiDrawIndirectDecls ~ arbMultiDrawIndirectFuncs.makeGShared() ~ arbMultiDrawIndirectLoader;