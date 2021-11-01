module engine.core.input.devices.keyboard;

import engine.core.string;
import engine.core.containers;

import engine.core.input.backend.device;

private enum SPK = ( 1 << 24 );

enum EKeyboard {
    /* CURSOR/FUNCTION/BROWSER/MULTIMEDIA/MISC KEYS */
    ESCAPE = SPK | 0x01,
    TAB = SPK | 0x02,
    BACKTAB = SPK | 0x03,
    BACKSPACE = SPK | 0x04,
    ENTER = SPK | 0x05,
    KP_ENTER = SPK | 0x06,
    INSERT = SPK | 0x07,
    DELETE = SPK | 0x08,
    PAUSE = SPK | 0x09,
    PRINT = SPK | 0x0A,
    SYSREQ = SPK | 0x0B,
    CLEAR = SPK | 0x0C,
    HOME = SPK | 0x0D,
    END = SPK | 0x0E,
    LEFT = SPK | 0x0F,
    UP = SPK | 0x10,
    RIGHT = SPK | 0x11,
    DOWN = SPK | 0x12,
    PAGEUP = SPK | 0x13,
    PAGEDOWN = SPK | 0x14,
    SHIFT = SPK | 0x15,
    CONTROL = SPK | 0x16,
    META = SPK | 0x17,
    ALT = SPK | 0x18,
    CAPSLOCK = SPK | 0x19,
    NUMLOCK = SPK | 0x1A,
    SCROLLLOCK = SPK | 0x1B,
    F1 = SPK | 0x1C,
    F2 = SPK | 0x1D,
    F3 = SPK | 0x1E,
    F4 = SPK | 0x1F,
    F5 = SPK | 0x20,
    F6 = SPK | 0x21,
    F7 = SPK | 0x22,
    F8 = SPK | 0x23,
    F9 = SPK | 0x24,
    F10 = SPK | 0x25,
    F11 = SPK | 0x26,
    F12 = SPK | 0x27,
    F13 = SPK | 0x28,
    F14 = SPK | 0x29,
    F15 = SPK | 0x2A,
    F16 = SPK | 0x2B,
    KP_MULTIPLY = SPK | 0x81,
    KP_DIVIDE = SPK | 0x82,
    KP_SUBTRACT = SPK | 0x83,
    KP_PERIOD = SPK | 0x84,
    KP_ADD = SPK | 0x85,
    KP_0 = SPK | 0x86,
    KP_1 = SPK | 0x87,
    KP_2 = SPK | 0x88,
    KP_3 = SPK | 0x89,
    KP_4 = SPK | 0x8A,
    KP_5 = SPK | 0x8B,
    KP_6 = SPK | 0x8C,
    KP_7 = SPK | 0x8D,
    KP_8 = SPK | 0x8E,
    KP_9 = SPK | 0x8F,
    SUPER_L = SPK | 0x2C,
    SUPER_R = SPK | 0x2D,
    MENU = SPK | 0x2E,
    HYPER_L = SPK | 0x2F,
    HYPER_R = SPK | 0x30,
    HELP = SPK | 0x31,
    DIRECTION_L = SPK | 0x32,
    DIRECTION_R = SPK | 0x33,
    BACK = SPK | 0x40,
    FORWARD = SPK | 0x41,
    STOP = SPK | 0x42,
    REFRESH = SPK | 0x43,
    VOLUMEDOWN = SPK | 0x44,
    VOLUMEMUTE = SPK | 0x45,
    VOLUMEUP = SPK | 0x46,
    BASSBOOST = SPK | 0x47,
    BASSUP = SPK | 0x48,
    BASSDOWN = SPK | 0x49,
    TREBLEUP = SPK | 0x4A,
    TREBLEDOWN = SPK | 0x4B,
    MEDIAPLAY = SPK | 0x4C,
    MEDIASTOP = SPK | 0x4D,
    MEDIAPREVIOUS = SPK | 0x4E,
    MEDIANEXT = SPK | 0x4F,
    MEDIARECORD = SPK | 0x50,
    HOMEPAGE = SPK | 0x51,
    FAVORITES = SPK | 0x52,
    SEARCH = SPK | 0x53,
    STANDBY = SPK | 0x54,
    OPENURL = SPK | 0x55,
    LAUNCHMAIL = SPK | 0x56,
    LAUNCHMEDIA = SPK | 0x57,
    LAUNCH0 = SPK | 0x58,
    LAUNCH1 = SPK | 0x59,
    LAUNCH2 = SPK | 0x5A,
    LAUNCH3 = SPK | 0x5B,
    LAUNCH4 = SPK | 0x5C,
    LAUNCH5 = SPK | 0x5D,
    LAUNCH6 = SPK | 0x5E,
    LAUNCH7 = SPK | 0x5F,
    LAUNCH8 = SPK | 0x60,
    LAUNCH9 = SPK | 0x61,
    LAUNCHA = SPK | 0x62,
    LAUNCHB = SPK | 0x63,
    LAUNCHC = SPK | 0x64,
    LAUNCHD = SPK | 0x65,
    LAUNCHE = SPK | 0x66,
    LAUNCHF = SPK | 0x67,

    UNKNOWN = SPK | 0xFFFFFF,

    /* PRINTABLE LATIN 1 CODES */

    SPACE = 0x0020,
    EXCLAM = 0x0021,
    QUOTEDBL = 0x0022,
    NUMBERSIGN = 0x0023,
    DOLLAR = 0x0024,
    PERCENT = 0x0025,
    AMPERSAND = 0x0026,
    APOSTROPHE = 0x0027,
    PARENLEFT = 0x0028,
    PARENRIGHT = 0x0029,
    ASTERISK = 0x002A,
    PLUS = 0x002B,
    COMMA = 0x002C,
    MINUS = 0x002D,
    PERIOD = 0x002E,
    SLASH = 0x002F,
    K_0 = 0x0030,
    K_1 = 0x0031,
    K_2 = 0x0032,
    K_3 = 0x0033,
    K_4 = 0x0034,
    K_5 = 0x0035,
    K_6 = 0x0036,
    K_7 = 0x0037,
    K_8 = 0x0038,
    K_9 = 0x0039,
    COLON = 0x003A,
    SEMICOLON = 0x003B,
    LESS = 0x003C,
    EQUAL = 0x003D,
    GREATER = 0x003E,
    QUESTION = 0x003F,
    AT = 0x0040,
    A = 0x0041,
    B = 0x0042,
    C = 0x0043,
    D = 0x0044,
    E = 0x0045,
    F = 0x0046,
    G = 0x0047,
    H = 0x0048,
    I = 0x0049,
    J = 0x004A,
    K = 0x004B,
    L = 0x004C,
    M = 0x004D,
    N = 0x004E,
    O = 0x004F,
    P = 0x0050,
    Q = 0x0051,
    R = 0x0052,
    S = 0x0053,
    T = 0x0054,
    U = 0x0055,
    V = 0x0056,
    W = 0x0057,
    X = 0x0058,
    Y = 0x0059,
    Z = 0x005A,
    BRACKETLEFT = 0x005B,
    BACKSLASH = 0x005C,
    BRACKETRIGHT = 0x005D,
    ASCIICIRCUM = 0x005E,
    UNDERSCORE = 0x005F,
    QUOTELEFT = 0x0060,
    BRACELEFT = 0x007B,
    BAR = 0x007C,
    BRACERIGHT = 0x007D,
    ASCIITILDE = 0x007E,
    NOBREAKSPACE = 0x00A0,
    EXCLAMDOWN = 0x00A1,
    CENT = 0x00A2,
    STERLING = 0x00A3,
    CURRENCY = 0x00A4,
    YEN = 0x00A5,
    BROKENBAR = 0x00A6,
    SECTION = 0x00A7,
    DIAERESIS = 0x00A8,
    COPYRIGHT = 0x00A9,
    ORDFEMININE = 0x00AA,
    GUILLEMOTLEFT = 0x00AB,
    NOTSIGN = 0x00AC,
    HYPHEN = 0x00AD,
    REGISTERED = 0x00AE,
    MACRON = 0x00AF,
    DEGREE = 0x00B0,
    PLUSMINUS = 0x00B1,
    TWOSUPERIOR = 0x00B2,
    THREESUPERIOR = 0x00B3,
    ACUTE = 0x00B4,
    MU = 0x00B5,
    PARAGRAPH = 0x00B6,
    PERIODCENTERED = 0x00B7,
    CEDILLA = 0x00B8,
    ONESUPERIOR = 0x00B9,
    MASCULINE = 0x00BA,
    GUILLEMOTRIGHT = 0x00BB,
    ONEQUARTER = 0x00BC,
    ONEHALF = 0x00BD,
    THREEQUARTERS = 0x00BE,
    QUESTIONDOWN = 0x00BF,
    AGRAVE = 0x00C0,
    AACUTE = 0x00C1,
    ACIRCUMFLEX = 0x00C2,
    ATILDE = 0x00C3,
    ADIAERESIS = 0x00C4,
    ARING = 0x00C5,
    AE = 0x00C6,
    CCEDILLA = 0x00C7,
    EGRAVE = 0x00C8,
    EACUTE = 0x00C9,
    ECIRCUMFLEX = 0x00CA,
    EDIAERESIS = 0x00CB,
    IGRAVE = 0x00CC,
    IACUTE = 0x00CD,
    ICIRCUMFLEX = 0x00CE,
    IDIAERESIS = 0x00CF,
    ETH = 0x00D0,
    NTILDE = 0x00D1,
    OGRAVE = 0x00D2,
    OACUTE = 0x00D3,
    OCIRCUMFLEX = 0x00D4,
    OTILDE = 0x00D5,
    ODIAERESIS = 0x00D6,
    MULTIPLY = 0x00D7,
    OOBLIQUE = 0x00D8,
    UGRAVE = 0x00D9,
    UACUTE = 0x00DA,
    UCIRCUMFLEX = 0x00DB,
    UDIAERESIS = 0x00DC,
    YACUTE = 0x00DD,
    THORN = 0x00DE,
    SSHARP = 0x00DF,

    DIVISION = 0x00F7,
    YDIAERESIS = 0x00FF,

    INVALID = -1,
}

enum EIKeyboardKeyEventType {
    UP,
    DOWN,
}

struct SIKeyboardModKeys {
    bool bShift = false;
    bool bControl = false;
    bool bAlt = false;
    bool bSuper = false;    // Win on windows
}

class CIKeyboardEvent : AInputEvent {
    mixin( TRegisterClass!CIKeyboardEvent );
public:
    EKeyboard key;
    Char character = '\0';
    EIKeyboardKeyEventType type;
    SIKeyboardModKeys mods;

    override bool cmpImpl( CObject obj ) {
        CIKeyboardEvent event = Cast!CIKeyboardEvent( obj );
        return
            key == event.key &&
            mods == event.mods;
    }

    override float strength() {
        return type == EIKeyboardKeyEventType.DOWN ? 1.0f : 0.0f;
    }

    static CIKeyboardEvent newReference( EKeyboard key ) {
        CIKeyboardEvent res = NewObject!CIKeyboardEvent();
        res.key = key;

        return res;
    }
}

class CIKeyboardState : AInputState {
    mixin( TRegisterClass!CIKeyboardState );
public:
    Dict!( bool, EKeyboard ) keys;
}

class CIKeyboard : AInputDevice {
    mixin( TRegisterClass!CIKeyboard );
    mixin( TRegisterInputDeviceStateType!CIKeyboardState );
protected:
    Dict!( bool, EKeyboard ) basicKeysStates;

public:
    this() {}

    ~this() {
        destroyState();
    }

    bool isKeyPressed( EKeyboard key ) {
        return state.keys.get( key, false );
    }
}
