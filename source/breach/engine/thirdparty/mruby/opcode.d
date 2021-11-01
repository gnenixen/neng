module engine.thirdparty.mruby.opcode;

extern (C):

enum _Anonymous_0
{
	OP_NOP = 0,
	OP_MOVE = 1,
	OP_LOADL = 2,
	OP_LOADI = 3,
	OP_LOADSYM = 4,
	OP_LOADNIL = 5,
	OP_LOADSELF = 6,
	OP_LOADT = 7,
	OP_LOADF = 8,
	OP_GETGLOBAL = 9,
	OP_SETGLOBAL = 10,
	OP_GETSPECIAL = 11,
	OP_SETSPECIAL = 12,
	OP_GETIV = 13,
	OP_SETIV = 14,
	OP_GETCV = 15,
	OP_SETCV = 16,
	OP_GETCONST = 17,
	OP_SETCONST = 18,
	OP_GETMCNST = 19,
	OP_SETMCNST = 20,
	OP_GETUPVAR = 21,
	OP_SETUPVAR = 22,
	OP_JMP = 23,
	OP_JMPIF = 24,
	OP_JMPNOT = 25,
	OP_ONERR = 26,
	OP_RESCUE = 27,
	OP_POPERR = 28,
	OP_RAISE = 29,
	OP_EPUSH = 30,
	OP_EPOP = 31,
	OP_SEND = 32,
	OP_SENDB = 33,
	OP_FSEND = 34,
	OP_CALL = 35,
	OP_SUPER = 36,
	OP_ARGARY = 37,
	OP_ENTER = 38,
	OP_KARG = 39,
	OP_KDICT = 40,
	OP_RETURN = 41,
	OP_TAILCALL = 42,
	OP_BLKPUSH = 43,
	OP_ADD = 44,
	OP_ADDI = 45,
	OP_SUB = 46,
	OP_SUBI = 47,
	OP_MUL = 48,
	OP_DIV = 49,
	OP_EQ = 50,
	OP_LT = 51,
	OP_LE = 52,
	OP_GT = 53,
	OP_GE = 54,
	OP_ARRAY = 55,
	OP_ARYCAT = 56,
	OP_ARYPUSH = 57,
	OP_AREF = 58,
	OP_ASET = 59,
	OP_APOST = 60,
	OP_STRING = 61,
	OP_STRCAT = 62,
	OP_HASH = 63,
	OP_LAMBDA = 64,
	OP_RANGE = 65,
	OP_OCLASS = 66,
	OP_CLASS = 67,
	OP_MODULE = 68,
	OP_EXEC = 69,
	OP_METHOD = 70,
	OP_SCLASS = 71,
	OP_TCLASS = 72,
	OP_DEBUG = 73,
	OP_STOP = 74,
	OP_ERR = 75,
	OP_RSVD1 = 76,
	OP_RSVD2 = 77,
	OP_RSVD3 = 78,
	OP_RSVD4 = 79,
	OP_RSVD5 = 80
}