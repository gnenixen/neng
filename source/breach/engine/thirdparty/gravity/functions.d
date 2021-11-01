module engine.thirdparty.grivity.functions;

import engine.thirdparty.gravity.types;

extern extern( C ) @nogc {
    gravity_compiler_t* gravity_compiler_create( gravity_delegate_t* _delegate );
    void gravity_compiler_free( gravity_compiler_t* compiler );
    gravity_closure_t* gravity_compiler_run( gravity_compiler_t* compiler, const( char )* src, size_t len, size_t fileid, bool is_static, bool add_debug );
    void gravity_compiler_transfer( gravity_compiler_t* compiler, gravity_vm* vm );

    gravity_vm* gravity_vm_new( gravity_delegate_t* _delegate );
    void gravity_vm_free( gravity_vm* vm );
    bool gravity_vm_runmain( gravity_vm* vm, gravity_closure_t* closure );
    gravity_value_t gravity_vm_result( gravity_vm* vm );
    gravity_value_t gravity_vm_getvalue( gravity_vm* vm, const( char )* key, uint32_t keylen );
    void gravity_vm_setvalue( gravity_vm* vm, const( char )* key, gravity_value_t value );
    void gravity_vm_setslot( gravity_vm* vm, gravity_value_t value, uint32_t index );
    void gravity_vm_seterror_string( gravity_vm* vm, const( char )* s );

    void gravity_value_dump( gravity_vm* vm, gravity_value_t v, char* buffer, uint16_t len );
    gravity_value_t gravity_value_from_object( void* obj );

    gravity_class_t* gravity_class_new_pair( gravity_vm* vm, const( char )* identifier, gravity_class_t* superclass, uint32_t nivar, uint32_t nsvar );
    gravity_class_t* gravity_class_get_meta( gravity_class_t* c );
    gravity_class_t* gravity_class_getsuper( gravity_class_t* c );
    bool gravity_class_setsuper( gravity_class_t* baseclass, gravity_class_t* superclass );
    void gravity_class_setxdata( gravity_class_t* c, void* xdata );
    void gravity_class_bind( gravity_class_t* c, const( char )* key, gravity_value_t value );

    gravity_closure_t* gravity_closure_new( gravity_vm* vm, gravity_function_t* f );

    gravity_function_t* gravity_function_new_bridged( gravity_vm* vm, const( char )* identifier, void* xdata );
    gravity_function_t* gravity_function_new_internal( gravity_vm* vm, const( char )* identifier, gravity_c_internal exec, uint16_t nparams );

    void gravity_gc_setenabled( gravity_vm* vm, bool enabled );
}

alias VALUE_FROM_OBJECT = gravity_value_from_object;

gravity_object_t* VALUE_AS_OBJECT( gravity_value_t val ) { return val.p; }
gravity_class_t* VALUE_AS_CLASS( gravity_value_t val ) { return cast( gravity_class_t* )VALUE_AS_OBJECT( val ); }
gravity_string_t* VALUE_AS_STRING( gravity_value_t val ) { return cast( gravity_string_t* )VALUE_AS_OBJECT( val ); }
char* VALUE_AS_CSTRING( gravity_value_t val ) { return VALUE_AS_STRING( val ).s; }
bool VALUE_ISA_VALID( gravity_value_t val ) { return val.isa !is null; }
