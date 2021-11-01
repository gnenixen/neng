module engine.thirdparty.bindings.glx.glx;

version( linux ):

import core.stdc.config;

extern extern( C ) {
    void _c_initializeGLX();
    void* _c_glXChoseVisual( void* dsp, int screen, int* att );
    void* _c_glXCreateContext( void* dsp, void* vi, void* gxc, int direct );
    void _c_glXDestroyContext( void* dps, void* glc );
    void _c_glXMakeCurrent( void* dsp, c_ulong win, void* glc );
    void _c_glXSwapBuffers( void* dsp, c_ulong win );
    void* _c_glXCreateContextAttribsARB( void* dsp, void* config, void* glc, int direct, int* attr );
    void* _c_glXChooseFBConfig( void* dsp, int screen, int* attr, int* nitems );
}

pragma( inline, true ):

void* glXChoseVisual( void* dsp, int screen, int* att ) {
    return _c_glXChoseVisual( dsp, screen, att );
}

void* glXCreateContext( void* dsp, void* vi, void* gxc, int direct ) {
    return _c_glXCreateContext( dsp, vi, gxc, direct );
}

void glXDestroyContext( void* dsp, void* glc ) {
    _c_glXDestroyContext( dsp, glc );
}

void glXMakeCurrent( void* dsp, c_ulong win, void* glc ) {
    _c_glXMakeCurrent( dsp, win, glc );
}

void glXSwapBuffers( void* dsp, c_ulong win ) {
    _c_glXSwapBuffers( dsp, win );
}

void* glXCreateContextAttribsARB( void* dsp, void* config, void* glc, int direct, int* attr ) {
    return _c_glXCreateContextAttribsARB( dsp, config, glc, direct, attr );
}

void* glXChooseFBConfig( void* dsp, int screen, int* attr, int* nitems ) {
    return _c_glXChooseFBConfig( dsp, screen, attr, nitems );
}
