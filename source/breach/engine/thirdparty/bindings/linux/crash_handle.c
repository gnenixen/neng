#define _GNU_SOURCE
#define __USE_GNU

#include <stdio.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <execinfo.h>
#include <unistd.h>
#include <ucontext.h>
#include <string.h>

extern void _c_linux_realCrashHandler( int sig );

void _c_linux_handleCrash( int sig ) {
    _c_linux_realCrashHandler( sig );
}