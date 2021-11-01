module engine.thirdparty.grivity.types;

public:
import core.stdc.stdint;

enum error_type_t {
    GRAVITY_ERROR_NONE = 0,
    GRAVITY_ERROR_SYNTAX,
    GRAVITY_ERROR_SEMANTIC,
    GRAVITY_ERROR_RUNTIME,
    GRAVITY_ERROR_IO,
    GRAVITY_WARNING,
}

struct error_desc_t {
    uint32_t lineno;
    uint32_t colno;
    uint32_t fileid;
    uint32_t offset;
}

extern( C ) {
    alias gravity_error_callback = extern( C ) void function( gravity_vm* vm, error_type_t error_type, const( char )* descr, error_desc_t error_desc, void* xdata );
    alias gravity_log_callback = extern( C ) void function( gravity_vm* vm, const( char )* msg, void* xdata );
    alias gravity_log_clear = extern( C ) void function( gravity_vm* vm, void* xdata );
    alias gravity_unittest_callback = extern( C ) void function( gravity_vm* vm, error_type_t error_type, const( char )* desc, const( char )* note, gravity_value_t value, int32_t row, int32_t col, void* xdata );
    alias gravity_filename_callback = const( char )* function( uint32_t fileid, void* xdata );
    alias gravity_loadfile_callback = const( char )* function( const( char )* file, size_t* size, uint32_t fileid, void* xdata, bool* is_static );
    alias gravity_optclass_callback = const( char )** function( void* xdata );
    alias gravity_parser_callback = void function( void* tocken, void* xdata );
    alias gravity_precode_callback = const( char )* function( void* xdata );
    alias gravity_type_callback = void function( void* token, const( char )* type, void* xdata );

    alias gravity_bridge_blacken = void function( gravity_vm* vm, void* xdata );
    alias gravity_bridge_clone = void* function( gravity_vm* vm, void* xdata );
    alias gravity_bridge_equals = bool function( gravity_vm* vm, void* obj1, void* obj2 );
    alias gravity_bridge_execute = bool function( gravity_vm* vm, void* xdata, gravity_value_t ctx, gravity_value_t* args, uint16_t nargs, uint32_t vindex );
    alias gravity_bridge_free = void function( gravity_vm* vm, gravity_object_t* obj );
    alias gravity_bridge_getundef = void function( gravity_vm* vm, void* xdata, gravity_value_t target, const( char )* key, uint32_t vindex );
    alias gravity_bridge_getvalue = bool function( gravity_vm* vm, void* xdata, gravity_value_t target, const( char )* key, uint32_t vindex );
    alias gravity_bridge_initinstance = void function( gravity_vm* vm, void* xdata, gravity_value_t ctx, gravity_instance_t* instance, gravity_value_t* args, int16_t nargs );
    alias gravity_bridge_setvalue = bool function( gravity_vm* vm, void* xdata, gravity_value_t target, const( char )* key, gravity_value_t value );
    alias gravity_bridge_setundef = bool function( gravity_vm* vm, void* xdata, gravity_value_t target, const( char )* key, gravity_value_t value );
    alias gravity_bridge_size = uint32_t function( gravity_vm* vm, gravity_object_t* obj );
    alias gravity_bridge_string = const( char )* function( gravity_vm* vm, void* xdata, uint32_t len );

    alias gravity_gc_callback = uint32_t function( gravity_vm* vm, gravity_object_t* obj );
    alias gravity_c_internal = bool function( gravity_vm* vm, gravity_value_t* args, uint16_t nargs, uint32_t rindex );
}

alias gravity_int_t = int64_t;
alias gravity_float_t = double;
alias gravity_class_t = gravity_class_s;
alias gravity_object_t = gravity_class_s;

struct gravity_class_s {
    gravity_class_t* isa;
    gravity_gc_t gc;

    gravity_class_t* objclass;
    const( char )* identifier;
    bool has_outer;
    bool is_struct;
    bool is_inited;
    bool unused;
    void* xdata;
    gravity_class_s* superclass;
    const( char )* superlook;
    void* htable;
    uint32_t nivars;
    gravity_value_t* ivars;
}

struct gravity_instance_t {
    gravity_class_t* isa;
    gravity_gc_t gc;

    gravity_class_t* objclass;
    void* xdata;
    gravity_value_t* ivars;
}

struct gravity_value_t {
    void* isa;
    union {
        gravity_int_t n;
        gravity_float_t f;
        gravity_object_t* p;
    }
}

struct gravity_gc_t {
    bool isdark;
    bool visited;

    gravity_gc_callback free;
    gravity_gc_callback size;
    gravity_gc_callback blacken;
    gravity_object_t* next;
}

struct gravity_string_t {
    gravity_class_t* isa;
    gravity_gc_t gc;

    char* s;
    uint32_t hash;
    uint32_t len;
    uint32_t alloc;
}

struct gravity_delegate_t {
    void* xdata;
    bool report_null_errors;
    bool disable_gccheck_1;

    gravity_log_callback log_callback;
    gravity_log_clear log_clear;
    gravity_error_callback error_callback;
    gravity_unittest_callback unittest_callback;
    gravity_parser_callback parser_callback;
    gravity_type_callback type_callback;
    gravity_precode_callback precode_callback;
    gravity_loadfile_callback loadfile_callback;
    gravity_filename_callback filename_callback;
    gravity_optclass_callback optional_classes;

    gravity_bridge_initinstance bridge_initinstance;
    gravity_bridge_setvalue bridge_setvalue;
    gravity_bridge_getvalue bridge_getvalue;
    gravity_bridge_setundef bridge_setundef;
    gravity_bridge_getundef bridge_getundef;
    gravity_bridge_execute bridge_execute;
    gravity_bridge_blacken bridge_blacken;
    gravity_bridge_string bridge_string;
    gravity_bridge_equals bridge_equals;
    gravity_bridge_clone bridge_clone;
    gravity_bridge_size bridge_size;
    gravity_bridge_free bridge_free;
}

alias gravity_compiler_t = void*;
alias gravity_closure_t = void*;
alias gravity_function_t = void*;
alias gravity_vm = void*;
