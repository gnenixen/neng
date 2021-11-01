module engine.core.memory.allocators.c_allocator;

import core.stdc.stdlib;
import core.memory;
import core.exception;

import std.algorithm.comparison;

import engine.core.memory.allocator;

static __gshared SAllocator CAllocator = {
    allocate: ( size_t size ) {
        void* p = malloc( size );
        if ( !p ) {
            onOutOfMemoryErrorNoGC();
        }

        GC.addRange( p, size );

        return p;
    },

    deallocate: ( void* ptr ) {
        if ( !ptr ) {
            return;
        }

        GC.removeRange( ptr );
        free( ptr );
    },

    reallocate: ( void* ptr, size_t size ) {
        GC.removeRange( ptr );
        ptr = realloc( ptr, size );
        GC.addRange( ptr, size );
        return ptr;
    }
};