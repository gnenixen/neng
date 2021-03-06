module engine.thirdparty.mruby.variable;

import engine.thirdparty.mruby;
import engine.thirdparty.mruby.value;
import engine.thirdparty.mruby.object;
import engine.thirdparty.mruby.mrb_class;

extern (C):

struct global_variable
{
	int counter;
	mrb_value* data;
	mrb_value function () getter;
	void function () setter;
}

struct global_entry
{
	global_variable* var;
	mrb_sym id;
}

static const int MRB_SEGMENT_SIZE = 4;

struct segment {
	mrb_sym[MRB_SEGMENT_SIZE] key;
	mrb_value[MRB_SEGMENT_SIZE] val;
	segment *next;
}

struct iv_tbl
{
	segment* rootseg;
	size_t size;
	size_t last_len;
}

extern @nogc:
mrb_value mrb_vm_special_get (mrb_state*, mrb_sym);
void mrb_vm_special_set (mrb_state*, mrb_sym, mrb_value);
mrb_value mrb_vm_iv_get (mrb_state*, mrb_sym);
void mrb_vm_iv_set (mrb_state*, mrb_sym, mrb_value);
mrb_value mrb_vm_cv_get (mrb_state*, mrb_sym);
void mrb_vm_cv_set (mrb_state*, mrb_sym, mrb_value);
mrb_value mrb_vm_const_get (mrb_state*, mrb_sym);
void mrb_vm_const_set (mrb_state*, mrb_sym, mrb_value);
mrb_value mrb_const_get (mrb_state*, mrb_value, mrb_sym);
void mrb_const_set (mrb_state*, mrb_value, mrb_sym, mrb_value);
mrb_bool mrb_const_defined (mrb_state*, mrb_value, mrb_sym);
void mrb_const_remove (mrb_state*, mrb_value, mrb_sym);
mrb_bool mrb_iv_p (mrb_state* mrb, mrb_sym sym);
void mrb_iv_check (mrb_state* mrb, mrb_sym sym);
mrb_value mrb_obj_iv_get (mrb_state* mrb, RObject* obj, mrb_sym sym);
void mrb_obj_iv_set (mrb_state* mrb, RObject* obj, mrb_sym sym, mrb_value v);
mrb_bool mrb_obj_iv_defined (mrb_state* mrb, RObject* obj, mrb_sym sym);
void mrb_obj_iv_ifnone (mrb_state* mrb, RObject* obj, mrb_sym sym, mrb_value v);
mrb_value mrb_iv_get (mrb_state* mrb, mrb_value obj, mrb_sym sym);
void mrb_iv_set (mrb_state* mrb, mrb_value obj, mrb_sym sym, mrb_value v);
mrb_bool mrb_iv_defined (mrb_state*, mrb_value, mrb_sym);
mrb_value mrb_iv_remove (mrb_state* mrb, mrb_value obj, mrb_sym sym);
void mrb_iv_copy (mrb_state* mrb, mrb_value dst, mrb_value src);
mrb_bool mrb_const_defined_at (mrb_state* mrb, mrb_value mod, mrb_sym id);
mrb_value mrb_gv_get (mrb_state* mrb, mrb_sym sym);
void mrb_gv_set (mrb_state* mrb, mrb_sym sym, mrb_value val);
void mrb_gv_remove (mrb_state* mrb, mrb_sym sym);
mrb_value mrb_cv_get (mrb_state* mrb, mrb_value mod, mrb_sym sym);
void mrb_mod_cv_set (mrb_state* mrb, RClass* c, mrb_sym sym, mrb_value v);
void mrb_cv_set (mrb_state* mrb, mrb_value mod, mrb_sym sym, mrb_value v);
mrb_bool mrb_cv_defined (mrb_state* mrb, mrb_value mod, mrb_sym sym);
mrb_value mrb_obj_iv_inspect (mrb_state*, RObject*);
mrb_value mrb_mod_constants (mrb_state* mrb, mrb_value mod);
mrb_value mrb_f_global_variables (mrb_state* mrb, mrb_value self);
mrb_value mrb_obj_instance_variables (mrb_state*, mrb_value);
mrb_value mrb_mod_class_variables (mrb_state*, mrb_value);
mrb_value mrb_mod_cv_get (mrb_state* mrb, RClass* c, mrb_sym sym);
mrb_bool mrb_mod_cv_defined (mrb_state* mrb, RClass* c, mrb_sym sym);
mrb_sym mrb_class_sym (mrb_state* mrb, RClass* c, RClass* outer);
void mrb_gc_mark_gv (mrb_state*);
void mrb_gc_free_gv (mrb_state*);
void mrb_gc_mark_iv (mrb_state*, RObject*);
size_t mrb_gc_mark_iv_size (mrb_state*, RObject*);
void mrb_gc_free_iv (mrb_state*, RObject*);
