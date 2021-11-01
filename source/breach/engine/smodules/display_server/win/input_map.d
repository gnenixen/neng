module engine.smodules.display_server.win.input_map;

version( Windows ):
private {
    import core.sys.windows.windows;
    import core.sys.windows.winuser;
}

import engine.core.input;

enum EKeyboard[ulong] WINDOWS_KEYBOARD_MAPPING = [
    0x41: EKeyboard.A,
    0x44: EKeyboard.D,
    0x5A: EKeyboard.Z,
	0x52: EKeyboard.R,

    VK_SPACE: EKeyboard.SPACE,
	VK_SHIFT: EKeyboard.SHIFT,
    VK_RIGHT: EKeyboard.RIGHT,
	VK_LEFT: EKeyboard.LEFT,
	VK_ESCAPE: EKeyboard.ESCAPE,
];

static EKeyboard getKeyboardEnum( ulong keycode ) {
    if ( EKeyboard* key = keycode in WINDOWS_KEYBOARD_MAPPING ) {
        return *key;
    }

    return EKeyboard.INVALID;
}
