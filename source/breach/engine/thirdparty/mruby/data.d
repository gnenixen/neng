module engine.thirdparty.mruby.data;

extern (C):

import engine.thirdparty.mruby;
import engine.thirdparty.mruby.mrb_class;
import engine.thirdparty.mruby.object;
import engine.thirdparty.mruby.variable;
import engine.thirdparty.mruby.value;

struct mrb_data_type
{
	const(char)* struct_name;
	void function (mrb_state*, void*) dfree;
}

struct RData
{
	enum mrb_vtype
	{
		MRB_TT_FALSE = 0,
		MRB_TT_FREE = 1,
		MRB_TT_TRUE = 2,
		MRB_TT_FIXNUM = 3,
		MRB_TT_SYMBOL = 4,
		MRB_TT_UNDEF = 5,
		MRB_TT_FLOAT = 6,
		MRB_TT_CPTR = 7,
		MRB_TT_OBJECT = 8,
		MRB_TT_CLASS = 9,
		MRB_TT_MODULE = 10,
		MRB_TT_ICLASS = 11,
		MRB_TT_SCLASS = 12,
		MRB_TT_PROC = 13,
		MRB_TT_ARRAY = 14,
		MRB_TT_HASH = 15,
		MRB_TT_STRING = 16,
		MRB_TT_RANGE = 17,
		MRB_TT_EXCEPTION = 18,
		MRB_TT_FILE = 19,
		MRB_TT_ENV = 20,
		MRB_TT_DATA = 21,
		MRB_TT_FIBER = 22,
		MRB_TT_MAXDEFINE = 23
	}
	mrb_vtype tt;
	uint color;
	uint flags;
	RClass* c;
	RBasic* gcnext;
	iv_tbl* iv;
	const(mrb_data_type)* type;
	void* data;
}

extern @nogc:
RData* mrb_data_object_alloc (mrb_state* mrb, RClass* klass, void* datap, const(mrb_data_type)* type);
void mrb_data_check_type (mrb_state* mrb, mrb_value, const(mrb_data_type)*);
void* mrb_data_get_ptr (mrb_state* mrb, mrb_value, const(mrb_data_type)*);
void* mrb_data_check_get_ptr (mrb_state* mrb, mrb_value, const(mrb_data_type)*);
void mrb_data_init (mrb_value v, void* ptr, const(mrb_data_type)* type);
