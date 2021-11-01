module engine.core.utils.msg_const;

static __gshared struct SMSGConst {
static const __gshared public:
    enum SHUTDOWN_MEM_LOG = 
"!!!***************SHUTDOWN MEMORY LOG***************!!!";
    
    enum CREATED_WINDOW = 
"Created window: ";

    enum DESTROYED_WINDOW = 
"Destroyed window: ";

    enum ENGINE_CRASH_HEADER = 
"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           ENGINE CRASH           !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";

/// Contains engine version and build mode(debug/release)
enum ENGINE_INFO_FTM = 
q{           ENGINE INFO
VER:                    %s
BM:                     %s};

/// Contains os name, cpu name, ram size in bytes, memory usage
enum HARDWARE_INFO_FMT =
"            HARDWARE INFO           
OS:                     %s
CPU:                    %s
RAM:                    %s
MEM USAGE:              %s";

enum RECEIVED_SIGNAL_WITH_STACK_FMT = 
"           RECEIVED SIGNAL %s
ADD INFO:
%s

BACKTRACE:

%s";
}