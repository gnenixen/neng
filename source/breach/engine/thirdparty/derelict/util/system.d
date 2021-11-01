/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module engine.thirdparty.derelict.util.system;

static if((void*).sizeof == 8) {
	enum Derelict_Arch_64 = true;
	enum Derelict_Arch_32 = false;
}
else {
	enum Derelict_Arch_64 = false;
	enum Derelict_Arch_32 = true;
}

version(Windows) enum Derelict_OS_Windows = true;
else enum Derelict_OS_Windows = false;

version(OSX) enum Derelict_OS_Mac = true;
else enum Derelict_OS_Mac = false;

version(linux) enum Derelict_OS_Linux = true;
else enum Derelict_OS_Linux = false;

version(Posix) enum Derelict_OS_Posix = true;
else enum Derelict_OS_Posix = false;

version(Android) enum Derelict_OS_Android = true;
else enum Derelict_OS_Android = false;

// TODO
enum Derelict_OS_iOS = false;
enum Derelict_OS_WinRT = false;

version(FreeBSD) {
	enum Derelict_OS_AnyBSD = true;
	enum Derelict_OS_FreeBSD = true;
	enum Derelict_OS_OpenBSD = false;
	enum Derelict_OS_OtherBSD = false;
} else version(OpenBSD) {
	enum Derelict_OS_AnyBSD = true;
	enum Derelict_OS_FreeBSD = false;
	enum Derelict_OS_OpenBSD = true;
	enum Derelict_OS_OtherBSD = false;
} else version(BSD) {
	enum Derelict_OS_AnyBSD = true;
	enum Derelict_OS_FreeBSD = false;
	enum Derelict_OS_OpenBSD = false;
	enum Derelict_OS_OtherBSD = true;
} else {
	enum Derelict_OS_AnyBSD = false;
	enum Derelict_OS_FreeBSD = false;
	enum Derelict_OS_OpenBSD = false;
	enum Derelict_OS_OtherBSD = false;
}

static if(__VERSION__ < 2066) enum nogc = 1;

enum MakeEnum(EnumType, string fqnEnumType = EnumType.stringof) = (){
  string MakeEnum = "enum {";
  foreach(m;__traits(allMembers, EnumType))
  {
      MakeEnum ~= m ~ " = " ~ fqnEnumType ~ "." ~ m ~ ",";
  }
  MakeEnum  ~= "}";
  return MakeEnum;
}();