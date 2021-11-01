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
module engine.thirdparty.derelict.opengl.types;

// Types defined by the core versions
alias GLenum = uint;
alias GLvoid = void;
alias GLboolean = ubyte;
alias GLbitfield = uint;
alias GLchar = char;
alias GLbyte = byte;
alias GLshort = short;
alias GLint = int;
alias GLsizei = int;
alias GLubyte = ubyte;
alias GLushort = ushort;
alias GLuint = uint;
alias GLhalf = ushort;
alias GLfloat = float;
alias GLclampf = float;
alias GLdouble = double;
alias GLclampd = double;
alias GLintptr = ptrdiff_t;
alias GLsizeiptr = ptrdiff_t;
alias GLint64 = long;
alias GLuint64 = ulong;
alias GLhandle = uint;

// Types defined in various extensions (declared here to avoid repetition)
alias GLint64EXT = GLint64;
alias GLuint64EXT = GLuint64;
alias GLintptrARB = GLintptr;
alias GLsizeiptrARB = GLsizeiptr;
alias GLcharARB = GLchar;
alias GLhandleARB = GLhandle;
alias GLhalfARB = GLhalf;
alias GLhalfNV = GLhalf;

// The following are Derelict types, not from OpenGL
enum GLVersion {
    none,
    gl11 = 11,
    gl12 = 12,
    gl13 = 13,
    gl14 = 14,
    gl15 = 15,
    gl20 = 20,
    gl21 = 21,
    gl30 = 30,
    gl31 = 31,
    gl32 = 32,
    gl33 = 33,
    gl40 = 40,
    gl41 = 41,
    gl42 = 42,
    gl43 = 43,
    gl44 = 44,
    gl45 = 45,
    highestSupported = gl32,
}

version(DerelictGL3_Contexts)
    enum usingContexts = true;
else
    enum usingContexts = false;