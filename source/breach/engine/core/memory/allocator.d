module engine.core.memory.allocator;

struct SAllocator {
    void* function( size_t size ) allocate = null;
    void function( void* ptr ) deallocate = null;
    void* function( void* ptr, size_t size ) reallocate = null; 
}