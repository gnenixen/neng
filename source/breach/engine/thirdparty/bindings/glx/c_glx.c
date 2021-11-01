#define GL_GLEXT_PROTOTYPES
#define GLX_GLXEXT_PROTOTYPES

#include <X11/X.h>
#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <GL/glxext.h>
#include <GL/glext.h>
#include <assert.h>

typedef GLXContext (*GLXCREATECONTEXTATTRIBSARBPROC)(Display *, GLXFBConfig, GLXContext, Bool, const int *);
static GLXCREATECONTEXTATTRIBSARBPROC __glXCreateContextAttribsARB;

void _c_initializeGLX() {
    __glXCreateContextAttribsARB = (GLXCREATECONTEXTATTRIBSARBPROC)glXGetProcAddress( (const GLubyte *)"glXCreateContextAttribsARB" );
    assert( __glXCreateContextAttribsARB != NULL );
}

void* _c_glXChoseVisual( void* dsp, GLint screen, GLint* att ) {
    return (void*)glXChooseVisual( (Display*)dsp, screen, att );
}

void* _c_glXCreateContext( void* dsp, void* vi, void* gxc, int direct ) {
    return ( void* )glXCreateContext( (Display*)dsp, (XVisualInfo*)vi, ( GLXContext )gxc, direct );
}

void _c_glXDestroyContext( void* dsp, void* glc ) {
    glXDestroyContext( (Display*)dsp, ( GLXContext )glc );
}

void _c_glXMakeCurrent( void* dsp, Window win, void* glc ) {
    glXMakeCurrent( (Display*)dsp, win, ( GLXContext )glc );
}

void _c_glXSwapBuffers( void* dsp, Window win ) {
    glXSwapBuffers( (Display*)dsp, win );
}

void* _c_glXCreateContextAttribsARB( void* dpy, void* config, void* share_context, Bool direct, const int *attrib_list ) {
    return ( void* )__glXCreateContextAttribsARB( (Display*)dpy, (( GLXFBConfig* )config)[0], ( GLXContext )share_context, direct, attrib_list );
}

void* _c_glXChooseFBConfig( void* dpy, int screen, const int *attribList, int *nitems ) {
   return ( void* )glXChooseFBConfig( (Display*)dpy, screen, attribList, nitems );
}
