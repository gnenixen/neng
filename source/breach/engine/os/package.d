module engine.os;

private import engine.core : newObject, GEngine, GSymbolDB;

void preInitLowLevelSystems() {
    version( linux ) {
        import core.stdc.signal;
        import core.sys.posix.signal;

        //import bindings.linux.linux_bind;

        //signal( SIGSEGV, &linux_handleCrash );
        //signal( SIGFPE, &linux_handleCrash );
        //signal( SIGILL, &linux_handleCrash );
    }
}

void initOS() {
    import engine.core.log;
    import engine.core.os;

    version( linux ) {
        import engine.os.linux;

        GSymbolDB.register!COSLinux;
        GSymbolDB.register!CPosixSemaphore;
        Thread.backend = GSymbolDB.register!CPosixThread;
        Mutex.backend = GSymbolDB.register!CPosixMutex;

        newObject!COSLinux();
    }

    version( Windows ) {
        import engine.os.win;

        GSymbolDB.register!COSWin;
        GSymbolDB.register!CWinSemaphore;
        Thread.backend = GSymbolDB.register!CWinThread;
        Mutex.backend = GSymbolDB.register!CWinMutex;

        newObject!COSWin();
    }
}

void destroyOS() {}
