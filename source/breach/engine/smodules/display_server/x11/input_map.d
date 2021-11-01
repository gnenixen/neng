module engine.smodules.display_server.x11.input_map;

version( linux ):

import engine.thirdparty.x11.X;
import engine.thirdparty.x11.Xutil;
import engine.thirdparty.x11.Xtos;
import engine.thirdparty.x11.Xlib;
import engine.thirdparty.x11.keysymdef;

import engine.core.containers;
import engine.core.input;

static __gshared {
    enum KEYSYM_MAX = 759;
    
    Dict!( EKeyboard, ulong ) XII_KEYBOARD_MAPPING;
    Array!KeySym XKEYSYM_TO_UNICODE_KEYS;
    Dict!( dchar, KeySym ) XKEYSYM_TO_UNICODE;
}

void setup_XII_KEYBOARD_MAPPING() {
    XII_KEYBOARD_MAPPING.set( XK_0, EKeyboard.K_0 );
    XII_KEYBOARD_MAPPING.set( XK_1, EKeyboard.K_1 );
    XII_KEYBOARD_MAPPING.set( XK_2, EKeyboard.K_2 );
    XII_KEYBOARD_MAPPING.set( XK_3, EKeyboard.K_3 );
    XII_KEYBOARD_MAPPING.set( XK_4, EKeyboard.K_4 );
    XII_KEYBOARD_MAPPING.set( XK_5, EKeyboard.K_5 );
    XII_KEYBOARD_MAPPING.set( XK_6, EKeyboard.K_6 );
    XII_KEYBOARD_MAPPING.set( XK_7, EKeyboard.K_7 );
    XII_KEYBOARD_MAPPING.set( XK_8, EKeyboard.K_8 );
    XII_KEYBOARD_MAPPING.set( XK_9, EKeyboard.K_9 );
    
    XII_KEYBOARD_MAPPING.set( XK_F1, EKeyboard.F1 );
    XII_KEYBOARD_MAPPING.set( XK_F2, EKeyboard.F2 );
    XII_KEYBOARD_MAPPING.set( XK_F3, EKeyboard.F3 );
    XII_KEYBOARD_MAPPING.set( XK_F4, EKeyboard.F4 );
    XII_KEYBOARD_MAPPING.set( XK_F5, EKeyboard.F5 );
    XII_KEYBOARD_MAPPING.set( XK_F6, EKeyboard.F6 );
    XII_KEYBOARD_MAPPING.set( XK_F7, EKeyboard.F7 );
    XII_KEYBOARD_MAPPING.set( XK_F8, EKeyboard.F8 );
    XII_KEYBOARD_MAPPING.set( XK_F9, EKeyboard.F9 );
    XII_KEYBOARD_MAPPING.set( XK_F10, EKeyboard.F10 );
    XII_KEYBOARD_MAPPING.set( XK_F11, EKeyboard.F11 );
    XII_KEYBOARD_MAPPING.set( XK_F12, EKeyboard.F12 );

    XII_KEYBOARD_MAPPING.set( XK_Return, EKeyboard.ENTER );
    XII_KEYBOARD_MAPPING.set( XK_Escape, EKeyboard.ESCAPE );
    XII_KEYBOARD_MAPPING.set( XK_backslash, EKeyboard.BACKSLASH );
    XII_KEYBOARD_MAPPING.set( XK_BackSpace, EKeyboard.BACKSPACE );
    XII_KEYBOARD_MAPPING.set( XK_Tab, EKeyboard.TAB );
    XII_KEYBOARD_MAPPING.set( XK_Shift_L, EKeyboard.SHIFT );
    XII_KEYBOARD_MAPPING.set( XK_Shift_R, EKeyboard.SHIFT );
    XII_KEYBOARD_MAPPING.set( XK_Super_L, EKeyboard.SUPER_L );
    XII_KEYBOARD_MAPPING.set( XK_Super_R, EKeyboard.SUPER_R );
    XII_KEYBOARD_MAPPING.set( XK_Control_L, EKeyboard.CONTROL );
    XII_KEYBOARD_MAPPING.set( XK_Control_R, EKeyboard.CONTROL );
    XII_KEYBOARD_MAPPING.set( XK_Alt_L, EKeyboard.ALT );
    XII_KEYBOARD_MAPPING.set( XK_Alt_R, EKeyboard.ALT );
    XII_KEYBOARD_MAPPING.set( XK_space, EKeyboard.SPACE );
    XII_KEYBOARD_MAPPING.set( XK_Caps_Lock, EKeyboard.CAPSLOCK );
    XII_KEYBOARD_MAPPING.set( XK_Num_Lock, EKeyboard.NUMLOCK );

    XII_KEYBOARD_MAPPING.set( XK_Up, EKeyboard.UP );
    XII_KEYBOARD_MAPPING.set( XK_Down, EKeyboard.DOWN );
    XII_KEYBOARD_MAPPING.set( XK_Left, EKeyboard.LEFT );
    XII_KEYBOARD_MAPPING.set( XK_Right, EKeyboard.RIGHT );

    XII_KEYBOARD_MAPPING.set( XK_a, EKeyboard.A );
    XII_KEYBOARD_MAPPING.set( XK_b, EKeyboard.B );
    XII_KEYBOARD_MAPPING.set( XK_c, EKeyboard.C );
    XII_KEYBOARD_MAPPING.set( XK_d, EKeyboard.D );
    XII_KEYBOARD_MAPPING.set( XK_e, EKeyboard.E );
    XII_KEYBOARD_MAPPING.set( XK_f, EKeyboard.F );
    XII_KEYBOARD_MAPPING.set( XK_g, EKeyboard.G );
    XII_KEYBOARD_MAPPING.set( XK_h, EKeyboard.H );
    XII_KEYBOARD_MAPPING.set( XK_i, EKeyboard.I );
    XII_KEYBOARD_MAPPING.set( XK_j, EKeyboard.J );
    XII_KEYBOARD_MAPPING.set( XK_k, EKeyboard.K );
    XII_KEYBOARD_MAPPING.set( XK_l, EKeyboard.L );
    XII_KEYBOARD_MAPPING.set( XK_m, EKeyboard.M );
    XII_KEYBOARD_MAPPING.set( XK_n, EKeyboard.N );
    XII_KEYBOARD_MAPPING.set( XK_o, EKeyboard.O );
    XII_KEYBOARD_MAPPING.set( XK_p, EKeyboard.P );
    XII_KEYBOARD_MAPPING.set( XK_q, EKeyboard.Q );
    XII_KEYBOARD_MAPPING.set( XK_r, EKeyboard.R );
    XII_KEYBOARD_MAPPING.set( XK_s, EKeyboard.S );
    XII_KEYBOARD_MAPPING.set( XK_q, EKeyboard.Q );
    XII_KEYBOARD_MAPPING.set( XK_u, EKeyboard.U );
    XII_KEYBOARD_MAPPING.set( XK_v, EKeyboard.V );
    XII_KEYBOARD_MAPPING.set( XK_w, EKeyboard.W );
    XII_KEYBOARD_MAPPING.set( XK_x, EKeyboard.X );
    XII_KEYBOARD_MAPPING.set( XK_y, EKeyboard.Y );
    XII_KEYBOARD_MAPPING.set( XK_z, EKeyboard.Z );
}


void setup_XKEYSYM_TO_UNICODE() {
  XKEYSYM_TO_UNICODE.set( 0x01A1, 0x0104 );
	XKEYSYM_TO_UNICODE.set( 0x01A2, 0x02D8 );
	XKEYSYM_TO_UNICODE.set( 0x01A3, 0x0141 );
	XKEYSYM_TO_UNICODE.set( 0x01A5, 0x013D );
	XKEYSYM_TO_UNICODE.set( 0x01A6, 0x015A );
	XKEYSYM_TO_UNICODE.set( 0x01A9, 0x0160 );
	XKEYSYM_TO_UNICODE.set( 0x01AA, 0x015E );
	XKEYSYM_TO_UNICODE.set( 0x01AB, 0x0164 );
	XKEYSYM_TO_UNICODE.set( 0x01AC, 0x0179 );
	XKEYSYM_TO_UNICODE.set( 0x01AE, 0x017D );
	XKEYSYM_TO_UNICODE.set( 0x01AF, 0x017B );
	XKEYSYM_TO_UNICODE.set( 0x01B1, 0x0105 );
	XKEYSYM_TO_UNICODE.set( 0x01B2, 0x02DB );
	XKEYSYM_TO_UNICODE.set( 0x01B3, 0x0142 );
	XKEYSYM_TO_UNICODE.set( 0x01B5, 0x013E );
	XKEYSYM_TO_UNICODE.set( 0x01B6, 0x015B );
	XKEYSYM_TO_UNICODE.set( 0x01B7, 0x02C7 );
	XKEYSYM_TO_UNICODE.set( 0x01B9, 0x0161 );
	XKEYSYM_TO_UNICODE.set( 0x01BA, 0x015F );
	XKEYSYM_TO_UNICODE.set( 0x01BB, 0x0165 );
	XKEYSYM_TO_UNICODE.set( 0x01BC, 0x017A );
	XKEYSYM_TO_UNICODE.set( 0x01BD, 0x02DD );
	XKEYSYM_TO_UNICODE.set( 0x01BE, 0x017E );
	XKEYSYM_TO_UNICODE.set( 0x01BF, 0x017C );
	XKEYSYM_TO_UNICODE.set( 0x01C0, 0x0154 );
	XKEYSYM_TO_UNICODE.set( 0x01C3, 0x0102 );
	XKEYSYM_TO_UNICODE.set( 0x01C5, 0x0139 );
	XKEYSYM_TO_UNICODE.set( 0x01C6, 0x0106 );
	XKEYSYM_TO_UNICODE.set( 0x01C8, 0x010C );
	XKEYSYM_TO_UNICODE.set( 0x01CA, 0x0118 );
	XKEYSYM_TO_UNICODE.set( 0x01CC, 0x011A );
	XKEYSYM_TO_UNICODE.set( 0x01CF, 0x010E );
	XKEYSYM_TO_UNICODE.set( 0x01D0, 0x0110 );
	XKEYSYM_TO_UNICODE.set( 0x01D1, 0x0143 );
	XKEYSYM_TO_UNICODE.set( 0x01D2, 0x0147 );
	XKEYSYM_TO_UNICODE.set( 0x01D5, 0x0150 );
	XKEYSYM_TO_UNICODE.set( 0x01D8, 0x0158 );
	XKEYSYM_TO_UNICODE.set( 0x01D9, 0x016E );
	XKEYSYM_TO_UNICODE.set( 0x01DB, 0x0170 );
	XKEYSYM_TO_UNICODE.set( 0x01DE, 0x0162 );
	XKEYSYM_TO_UNICODE.set( 0x01E0, 0x0155 );
	XKEYSYM_TO_UNICODE.set( 0x01E3, 0x0103 );
	XKEYSYM_TO_UNICODE.set( 0x01E5, 0x013A );
	XKEYSYM_TO_UNICODE.set( 0x01E6, 0x0107 );
	XKEYSYM_TO_UNICODE.set( 0x01E8, 0x010D );
	XKEYSYM_TO_UNICODE.set( 0x01EA, 0x0119 );
	XKEYSYM_TO_UNICODE.set( 0x01EC, 0x011B );
	XKEYSYM_TO_UNICODE.set( 0x01EF, 0x010F );
	XKEYSYM_TO_UNICODE.set( 0x01F0, 0x0111 );
	XKEYSYM_TO_UNICODE.set( 0x01F1, 0x0144 );
	XKEYSYM_TO_UNICODE.set( 0x01F2, 0x0148 );
	XKEYSYM_TO_UNICODE.set( 0x01F5, 0x0151 );
	XKEYSYM_TO_UNICODE.set( 0x01F8, 0x0159 );
	XKEYSYM_TO_UNICODE.set( 0x01F9, 0x016F );
	XKEYSYM_TO_UNICODE.set( 0x01FB, 0x0171 );
	XKEYSYM_TO_UNICODE.set( 0x01FE, 0x0163 );
	XKEYSYM_TO_UNICODE.set( 0x01FF, 0x02D9 );
	XKEYSYM_TO_UNICODE.set( 0x02A1, 0x0126 );
	XKEYSYM_TO_UNICODE.set( 0x02A6, 0x0124 );
	XKEYSYM_TO_UNICODE.set( 0x02A9, 0x0130 );
	XKEYSYM_TO_UNICODE.set( 0x02AB, 0x011E );
	XKEYSYM_TO_UNICODE.set( 0x02AC, 0x0134 );
	XKEYSYM_TO_UNICODE.set( 0x02B1, 0x0127 );
	XKEYSYM_TO_UNICODE.set( 0x02B6, 0x0125 );
	XKEYSYM_TO_UNICODE.set( 0x02B9, 0x0131 );
	XKEYSYM_TO_UNICODE.set( 0x02BB, 0x011F );
	XKEYSYM_TO_UNICODE.set( 0x02BC, 0x0135 );
	XKEYSYM_TO_UNICODE.set( 0x02C5, 0x010A );
	XKEYSYM_TO_UNICODE.set( 0x02C6, 0x0108 );
	XKEYSYM_TO_UNICODE.set( 0x02D5, 0x0120 );
	XKEYSYM_TO_UNICODE.set( 0x02D8, 0x011C );
	XKEYSYM_TO_UNICODE.set( 0x02DD, 0x016C );
	XKEYSYM_TO_UNICODE.set( 0x02DE, 0x015C );
	XKEYSYM_TO_UNICODE.set( 0x02E5, 0x010B );
	XKEYSYM_TO_UNICODE.set( 0x02E6, 0x0109 );
	XKEYSYM_TO_UNICODE.set( 0x02F5, 0x0121 );
	XKEYSYM_TO_UNICODE.set( 0x02F8, 0x011D );
	XKEYSYM_TO_UNICODE.set( 0x02FD, 0x016D );
	XKEYSYM_TO_UNICODE.set( 0x02FE, 0x015D );
	XKEYSYM_TO_UNICODE.set( 0x03A2, 0x0138 );
	XKEYSYM_TO_UNICODE.set( 0x03A3, 0x0156 );
	XKEYSYM_TO_UNICODE.set( 0x03A5, 0x0128 );
	XKEYSYM_TO_UNICODE.set( 0x03A6, 0x013B );
	XKEYSYM_TO_UNICODE.set( 0x03AA, 0x0112 );
	XKEYSYM_TO_UNICODE.set( 0x03AB, 0x0122 );
	XKEYSYM_TO_UNICODE.set( 0x03AC, 0x0166 );
	XKEYSYM_TO_UNICODE.set( 0x03B3, 0x0157 );
	XKEYSYM_TO_UNICODE.set( 0x03B5, 0x0129 );
	XKEYSYM_TO_UNICODE.set( 0x03B6, 0x013C );
	XKEYSYM_TO_UNICODE.set( 0x03BA, 0x0113 );
	XKEYSYM_TO_UNICODE.set( 0x03BB, 0x0123 );
	XKEYSYM_TO_UNICODE.set( 0x03BC, 0x0167 );
	XKEYSYM_TO_UNICODE.set( 0x03BD, 0x014A );
	XKEYSYM_TO_UNICODE.set( 0x03BF, 0x014B );
	XKEYSYM_TO_UNICODE.set( 0x03C0, 0x0100 );
	XKEYSYM_TO_UNICODE.set( 0x03C7, 0x012E );
	XKEYSYM_TO_UNICODE.set( 0x03CC, 0x0116 );
	XKEYSYM_TO_UNICODE.set( 0x03CF, 0x012A );
	XKEYSYM_TO_UNICODE.set( 0x03D1, 0x0145 );
	XKEYSYM_TO_UNICODE.set( 0x03D2, 0x014C );
	XKEYSYM_TO_UNICODE.set( 0x03D3, 0x0136 );
	XKEYSYM_TO_UNICODE.set( 0x03D9, 0x0172 );
	XKEYSYM_TO_UNICODE.set( 0x03DD, 0x0168 );
	XKEYSYM_TO_UNICODE.set( 0x03DE, 0x016A );
	XKEYSYM_TO_UNICODE.set( 0x03E0, 0x0101 );
	XKEYSYM_TO_UNICODE.set( 0x03E7, 0x012F );
	XKEYSYM_TO_UNICODE.set( 0x03EC, 0x0117 );
	XKEYSYM_TO_UNICODE.set( 0x03EF, 0x012B );
	XKEYSYM_TO_UNICODE.set( 0x03F1, 0x0146 );
	XKEYSYM_TO_UNICODE.set( 0x03F2, 0x014D );
	XKEYSYM_TO_UNICODE.set( 0x03F3, 0x0137 );
	XKEYSYM_TO_UNICODE.set( 0x03F9, 0x0173 );
	XKEYSYM_TO_UNICODE.set( 0x03FD, 0x0169 );
	XKEYSYM_TO_UNICODE.set( 0x03FE, 0x016B );
	XKEYSYM_TO_UNICODE.set( 0x047E, 0x203E );
	XKEYSYM_TO_UNICODE.set( 0x04A1, 0x3002 );
	XKEYSYM_TO_UNICODE.set( 0x04A2, 0x300C );
	XKEYSYM_TO_UNICODE.set( 0x04A3, 0x300D );
	XKEYSYM_TO_UNICODE.set( 0x04A4, 0x3001 );
	XKEYSYM_TO_UNICODE.set( 0x04A5, 0x30FB );
	XKEYSYM_TO_UNICODE.set( 0x04A6, 0x30F2 );
	XKEYSYM_TO_UNICODE.set( 0x04A7, 0x30A1 );
	XKEYSYM_TO_UNICODE.set( 0x04A8, 0x30A3 );
	XKEYSYM_TO_UNICODE.set( 0x04A9, 0x30A5 );
	XKEYSYM_TO_UNICODE.set( 0x04AA, 0x30A7 );
	XKEYSYM_TO_UNICODE.set( 0x04AB, 0x30A9 );
	XKEYSYM_TO_UNICODE.set( 0x04AC, 0x30E3 );
	XKEYSYM_TO_UNICODE.set( 0x04AD, 0x30E5 );
	XKEYSYM_TO_UNICODE.set( 0x04AE, 0x30E7 );
	XKEYSYM_TO_UNICODE.set( 0x04AF, 0x30C3 );
	XKEYSYM_TO_UNICODE.set( 0x04B0, 0x30FC );
	XKEYSYM_TO_UNICODE.set( 0x04B1, 0x30A2 );
	XKEYSYM_TO_UNICODE.set( 0x04B2, 0x30A4 );
	XKEYSYM_TO_UNICODE.set( 0x04B3, 0x30A6 );
	XKEYSYM_TO_UNICODE.set( 0x04B4, 0x30A8 );
	XKEYSYM_TO_UNICODE.set( 0x04B5, 0x30AA );
	XKEYSYM_TO_UNICODE.set( 0x04B6, 0x30AB );
	XKEYSYM_TO_UNICODE.set( 0x04B7, 0x30AD );
	XKEYSYM_TO_UNICODE.set( 0x04B8, 0x30AF );
	XKEYSYM_TO_UNICODE.set( 0x04B9, 0x30B1 );
	XKEYSYM_TO_UNICODE.set( 0x04BA, 0x30B3 );
	XKEYSYM_TO_UNICODE.set( 0x04BB, 0x30B5 );
	XKEYSYM_TO_UNICODE.set( 0x04BC, 0x30B7 );
	XKEYSYM_TO_UNICODE.set( 0x04BD, 0x30B9 );
	XKEYSYM_TO_UNICODE.set( 0x04BE, 0x30BB );
	XKEYSYM_TO_UNICODE.set( 0x04BF, 0x30BD );
	XKEYSYM_TO_UNICODE.set( 0x04C0, 0x30BF );
	XKEYSYM_TO_UNICODE.set( 0x04C1, 0x30C1 );
	XKEYSYM_TO_UNICODE.set( 0x04C2, 0x30C4 );
	XKEYSYM_TO_UNICODE.set( 0x04C3, 0x30C6 );
	XKEYSYM_TO_UNICODE.set( 0x04C4, 0x30C8 );
	XKEYSYM_TO_UNICODE.set( 0x04C5, 0x30CA );
	XKEYSYM_TO_UNICODE.set( 0x04C6, 0x30CB );
	XKEYSYM_TO_UNICODE.set( 0x04C7, 0x30CC );
	XKEYSYM_TO_UNICODE.set( 0x04C8, 0x30CD );
	XKEYSYM_TO_UNICODE.set( 0x04C9, 0x30CE );
	XKEYSYM_TO_UNICODE.set( 0x04CA, 0x30CF );
	XKEYSYM_TO_UNICODE.set( 0x04CB, 0x30D2 );
	XKEYSYM_TO_UNICODE.set( 0x04CC, 0x30D5 );
	XKEYSYM_TO_UNICODE.set( 0x04CD, 0x30D8 );
	XKEYSYM_TO_UNICODE.set( 0x04CE, 0x30DB );
	XKEYSYM_TO_UNICODE.set( 0x04CF, 0x30DE );
	XKEYSYM_TO_UNICODE.set( 0x04D0, 0x30DF );
	XKEYSYM_TO_UNICODE.set( 0x04D1, 0x30E0 );
	XKEYSYM_TO_UNICODE.set( 0x04D2, 0x30E1 );
	XKEYSYM_TO_UNICODE.set( 0x04D3, 0x30E2 );
	XKEYSYM_TO_UNICODE.set( 0x04D4, 0x30E4 );
	XKEYSYM_TO_UNICODE.set( 0x04D5, 0x30E6 );
	XKEYSYM_TO_UNICODE.set( 0x04D6, 0x30E8 );
	XKEYSYM_TO_UNICODE.set( 0x04D7, 0x30E9 );
	XKEYSYM_TO_UNICODE.set( 0x04D8, 0x30EA );
	XKEYSYM_TO_UNICODE.set( 0x04D9, 0x30EB );
	XKEYSYM_TO_UNICODE.set( 0x04DA, 0x30EC );
	XKEYSYM_TO_UNICODE.set( 0x04DB, 0x30ED );
	XKEYSYM_TO_UNICODE.set( 0x04DC, 0x30EF );
	XKEYSYM_TO_UNICODE.set( 0x04DD, 0x30F3 );
	XKEYSYM_TO_UNICODE.set( 0x04DE, 0x309B );
	XKEYSYM_TO_UNICODE.set( 0x04DF, 0x309C );
	XKEYSYM_TO_UNICODE.set( 0x05AC, 0x060C );
	XKEYSYM_TO_UNICODE.set( 0x05BB, 0x061B );
	XKEYSYM_TO_UNICODE.set( 0x05BF, 0x061F );
	XKEYSYM_TO_UNICODE.set( 0x05C1, 0x0621 );
	XKEYSYM_TO_UNICODE.set( 0x05C2, 0x0622 );
	XKEYSYM_TO_UNICODE.set( 0x05C3, 0x0623 );
	XKEYSYM_TO_UNICODE.set( 0x05C4, 0x0624 );
	XKEYSYM_TO_UNICODE.set( 0x05C5, 0x0625 );
	XKEYSYM_TO_UNICODE.set( 0x05C6, 0x0626 );
	XKEYSYM_TO_UNICODE.set( 0x05C7, 0x0627 );
	XKEYSYM_TO_UNICODE.set( 0x05C8, 0x0628 );
	XKEYSYM_TO_UNICODE.set( 0x05C9, 0x0629 );
	XKEYSYM_TO_UNICODE.set( 0x05CA, 0x062A );
	XKEYSYM_TO_UNICODE.set( 0x05CB, 0x062B );
	XKEYSYM_TO_UNICODE.set( 0x05CC, 0x062C );
	XKEYSYM_TO_UNICODE.set( 0x05CD, 0x062D );
	XKEYSYM_TO_UNICODE.set( 0x05CE, 0x062E );
	XKEYSYM_TO_UNICODE.set( 0x05CF, 0x062F );
	XKEYSYM_TO_UNICODE.set( 0x05D0, 0x0630 );
	XKEYSYM_TO_UNICODE.set( 0x05D1, 0x0631 );
	XKEYSYM_TO_UNICODE.set( 0x05D2, 0x0632 );
	XKEYSYM_TO_UNICODE.set( 0x05D3, 0x0633 );
	XKEYSYM_TO_UNICODE.set( 0x05D4, 0x0634 );
	XKEYSYM_TO_UNICODE.set( 0x05D5, 0x0635 );
	XKEYSYM_TO_UNICODE.set( 0x05D6, 0x0636 );
	XKEYSYM_TO_UNICODE.set( 0x05D7, 0x0637 );
	XKEYSYM_TO_UNICODE.set( 0x05D8, 0x0638 );
	XKEYSYM_TO_UNICODE.set( 0x05D9, 0x0639 );
	XKEYSYM_TO_UNICODE.set( 0x05DA, 0x063A );
	XKEYSYM_TO_UNICODE.set( 0x05E0, 0x0640 );
	XKEYSYM_TO_UNICODE.set( 0x05E1, 0x0641 );
	XKEYSYM_TO_UNICODE.set( 0x05E2, 0x0642 );
	XKEYSYM_TO_UNICODE.set( 0x05E3, 0x0643 );
	XKEYSYM_TO_UNICODE.set( 0x05E4, 0x0644 );
	XKEYSYM_TO_UNICODE.set( 0x05E5, 0x0645 );
	XKEYSYM_TO_UNICODE.set( 0x05E6, 0x0646 );
	XKEYSYM_TO_UNICODE.set( 0x05E7, 0x0647 );
	XKEYSYM_TO_UNICODE.set( 0x05E8, 0x0648 );
	XKEYSYM_TO_UNICODE.set( 0x05E9, 0x0649 );
	XKEYSYM_TO_UNICODE.set( 0x05EA, 0x064A );
	XKEYSYM_TO_UNICODE.set( 0x05EB, 0x064B );
	XKEYSYM_TO_UNICODE.set( 0x05EC, 0x064C );
	XKEYSYM_TO_UNICODE.set( 0x05ED, 0x064D );
	XKEYSYM_TO_UNICODE.set( 0x05EE, 0x064E );
	XKEYSYM_TO_UNICODE.set( 0x05EF, 0x064F );
	XKEYSYM_TO_UNICODE.set( 0x05F0, 0x0650 );
	XKEYSYM_TO_UNICODE.set( 0x05F1, 0x0651 );
	XKEYSYM_TO_UNICODE.set( 0x05F2, 0x0652 );
	XKEYSYM_TO_UNICODE.set( 0x06A1, 0x0452 );
	XKEYSYM_TO_UNICODE.set( 0x06A2, 0x0453 );
	XKEYSYM_TO_UNICODE.set( 0x06A3, 0x0451 );
	XKEYSYM_TO_UNICODE.set( 0x06A4, 0x0454 );
	XKEYSYM_TO_UNICODE.set( 0x06A5, 0x0455 );
	XKEYSYM_TO_UNICODE.set( 0x06A6, 0x0456 );
	XKEYSYM_TO_UNICODE.set( 0x06A7, 0x0457 );
	XKEYSYM_TO_UNICODE.set( 0x06A8, 0x0458 );
	XKEYSYM_TO_UNICODE.set( 0x06A9, 0x0459 );
	XKEYSYM_TO_UNICODE.set( 0x06AA, 0x045A );
	XKEYSYM_TO_UNICODE.set( 0x06AB, 0x045B );
	XKEYSYM_TO_UNICODE.set( 0x06AC, 0x045C );
	XKEYSYM_TO_UNICODE.set( 0x06AE, 0x045E );
	XKEYSYM_TO_UNICODE.set( 0x06AF, 0x045F );
	XKEYSYM_TO_UNICODE.set( 0x06B0, 0x2116 );
	XKEYSYM_TO_UNICODE.set( 0x06B1, 0x0402 );
	XKEYSYM_TO_UNICODE.set( 0x06B2, 0x0403 );
	XKEYSYM_TO_UNICODE.set( 0x06B3, 0x0401 );
	XKEYSYM_TO_UNICODE.set( 0x06B4, 0x0404 );
	XKEYSYM_TO_UNICODE.set( 0x06B5, 0x0405 );
	XKEYSYM_TO_UNICODE.set( 0x06B6, 0x0406 );
	XKEYSYM_TO_UNICODE.set( 0x06B7, 0x0407 );
	XKEYSYM_TO_UNICODE.set( 0x06B8, 0x0408 );
	XKEYSYM_TO_UNICODE.set( 0x06B9, 0x0409 );
	XKEYSYM_TO_UNICODE.set( 0x06BA, 0x040A );
	XKEYSYM_TO_UNICODE.set( 0x06BB, 0x040B );
	XKEYSYM_TO_UNICODE.set( 0x06BC, 0x040C );
	XKEYSYM_TO_UNICODE.set( 0x06BE, 0x040E );
	XKEYSYM_TO_UNICODE.set( 0x06BF, 0x040F );
	XKEYSYM_TO_UNICODE.set( 0x06C0, 0x044E );
	XKEYSYM_TO_UNICODE.set( 0x06C1, 0x0430 );
	XKEYSYM_TO_UNICODE.set( 0x06C2, 0x0431 );
	XKEYSYM_TO_UNICODE.set( 0x06C3, 0x0446 );
	XKEYSYM_TO_UNICODE.set( 0x06C4, 0x0434 );
	XKEYSYM_TO_UNICODE.set( 0x06C5, 0x0435 );
	XKEYSYM_TO_UNICODE.set( 0x06C6, 0x0444 );
	XKEYSYM_TO_UNICODE.set( 0x06C7, 0x0433 );
	XKEYSYM_TO_UNICODE.set( 0x06C8, 0x0445 );
	XKEYSYM_TO_UNICODE.set( 0x06C9, 0x0438 );
	XKEYSYM_TO_UNICODE.set( 0x06CA, 0x0439 );
	XKEYSYM_TO_UNICODE.set( 0x06CB, 0x043A );
	XKEYSYM_TO_UNICODE.set( 0x06CC, 0x043B );
	XKEYSYM_TO_UNICODE.set( 0x06CD, 0x043C );
	XKEYSYM_TO_UNICODE.set( 0x06CE, 0x043D );
	XKEYSYM_TO_UNICODE.set( 0x06CF, 0x043E );
	XKEYSYM_TO_UNICODE.set( 0x06D0, 0x043F );
	XKEYSYM_TO_UNICODE.set( 0x06D1, 0x044F );
	XKEYSYM_TO_UNICODE.set( 0x06D2, 0x0440 );
	XKEYSYM_TO_UNICODE.set( 0x06D3, 0x0441 );
	XKEYSYM_TO_UNICODE.set( 0x06D4, 0x0442 );
	XKEYSYM_TO_UNICODE.set( 0x06D5, 0x0443 );
	XKEYSYM_TO_UNICODE.set( 0x06D6, 0x0436 );
	XKEYSYM_TO_UNICODE.set( 0x06D7, 0x0432 );
	XKEYSYM_TO_UNICODE.set( 0x06D8, 0x044C );
	XKEYSYM_TO_UNICODE.set( 0x06D9, 0x044B );
	XKEYSYM_TO_UNICODE.set( 0x06DA, 0x0437 );
	XKEYSYM_TO_UNICODE.set( 0x06DB, 0x0448 );
	XKEYSYM_TO_UNICODE.set( 0x06DC, 0x044D );
	XKEYSYM_TO_UNICODE.set( 0x06DD, 0x0449 );
	XKEYSYM_TO_UNICODE.set( 0x06DE, 0x0447 );
	XKEYSYM_TO_UNICODE.set( 0x06DF, 0x044A );
	XKEYSYM_TO_UNICODE.set( 0x06E0, 0x042E );
	XKEYSYM_TO_UNICODE.set( 0x06E1, 0x0410 );
	XKEYSYM_TO_UNICODE.set( 0x06E2, 0x0411 );
	XKEYSYM_TO_UNICODE.set( 0x06E3, 0x0426 );
	XKEYSYM_TO_UNICODE.set( 0x06E4, 0x0414 );
	XKEYSYM_TO_UNICODE.set( 0x06E5, 0x0415 );
	XKEYSYM_TO_UNICODE.set( 0x06E6, 0x0424 );
	XKEYSYM_TO_UNICODE.set( 0x06E7, 0x0413 );
	XKEYSYM_TO_UNICODE.set( 0x06E8, 0x0425 );
	XKEYSYM_TO_UNICODE.set( 0x06E9, 0x0418 );
	XKEYSYM_TO_UNICODE.set( 0x06EA, 0x0419 );
	XKEYSYM_TO_UNICODE.set( 0x06EB, 0x041A );
	XKEYSYM_TO_UNICODE.set( 0x06EC, 0x041B );
	XKEYSYM_TO_UNICODE.set( 0x06ED, 0x041C );
	XKEYSYM_TO_UNICODE.set( 0x06EE, 0x041D );
	XKEYSYM_TO_UNICODE.set( 0x06EF, 0x041E );
	XKEYSYM_TO_UNICODE.set( 0x06F0, 0x041F );
	XKEYSYM_TO_UNICODE.set( 0x06F1, 0x042F );
	XKEYSYM_TO_UNICODE.set( 0x06F2, 0x0420 );
	XKEYSYM_TO_UNICODE.set( 0x06F3, 0x0421 );
	XKEYSYM_TO_UNICODE.set( 0x06F4, 0x0422 );
	XKEYSYM_TO_UNICODE.set( 0x06F5, 0x0423 );
	XKEYSYM_TO_UNICODE.set( 0x06F6, 0x0416 );
	XKEYSYM_TO_UNICODE.set( 0x06F7, 0x0412 );
	XKEYSYM_TO_UNICODE.set( 0x06F8, 0x042C );
	XKEYSYM_TO_UNICODE.set( 0x06F9, 0x042B );
	XKEYSYM_TO_UNICODE.set( 0x06FA, 0x0417 );
	XKEYSYM_TO_UNICODE.set( 0x06FB, 0x0428 );
	XKEYSYM_TO_UNICODE.set( 0x06FC, 0x042D );
	XKEYSYM_TO_UNICODE.set( 0x06FD, 0x0429 );
	XKEYSYM_TO_UNICODE.set( 0x06FE, 0x0427 );
	XKEYSYM_TO_UNICODE.set( 0x06FF, 0x042A );
	XKEYSYM_TO_UNICODE.set( 0x07A1, 0x0386 );
	XKEYSYM_TO_UNICODE.set( 0x07A2, 0x0388 );
	XKEYSYM_TO_UNICODE.set( 0x07A3, 0x0389 );
	XKEYSYM_TO_UNICODE.set( 0x07A4, 0x038A );
	XKEYSYM_TO_UNICODE.set( 0x07A5, 0x03AA );
	XKEYSYM_TO_UNICODE.set( 0x07A7, 0x038C );
	XKEYSYM_TO_UNICODE.set( 0x07A8, 0x038E );
	XKEYSYM_TO_UNICODE.set( 0x07A9, 0x03AB );
	XKEYSYM_TO_UNICODE.set( 0x07AB, 0x038F );
	XKEYSYM_TO_UNICODE.set( 0x07AE, 0x0385 );
	XKEYSYM_TO_UNICODE.set( 0x07AF, 0x2015 );
	XKEYSYM_TO_UNICODE.set( 0x07B1, 0x03AC );
	XKEYSYM_TO_UNICODE.set( 0x07B2, 0x03AD );
	XKEYSYM_TO_UNICODE.set( 0x07B3, 0x03AE );
	XKEYSYM_TO_UNICODE.set( 0x07B4, 0x03AF );
	XKEYSYM_TO_UNICODE.set( 0x07B5, 0x03CA );
	XKEYSYM_TO_UNICODE.set( 0x07B6, 0x0390 );
	XKEYSYM_TO_UNICODE.set( 0x07B7, 0x03CC );
	XKEYSYM_TO_UNICODE.set( 0x07B8, 0x03CD );
	XKEYSYM_TO_UNICODE.set( 0x07B9, 0x03CB );
	XKEYSYM_TO_UNICODE.set( 0x07BA, 0x03B0 );
	XKEYSYM_TO_UNICODE.set( 0x07BB, 0x03CE );
	XKEYSYM_TO_UNICODE.set( 0x07C1, 0x0391 );
	XKEYSYM_TO_UNICODE.set( 0x07C2, 0x0392 );
	XKEYSYM_TO_UNICODE.set( 0x07C3, 0x0393 );
	XKEYSYM_TO_UNICODE.set( 0x07C4, 0x0394 );
	XKEYSYM_TO_UNICODE.set( 0x07C5, 0x0395 );
	XKEYSYM_TO_UNICODE.set( 0x07C6, 0x0396 );
	XKEYSYM_TO_UNICODE.set( 0x07C7, 0x0397 );
	XKEYSYM_TO_UNICODE.set( 0x07C8, 0x0398 );
	XKEYSYM_TO_UNICODE.set( 0x07C9, 0x0399 );
	XKEYSYM_TO_UNICODE.set( 0x07CA, 0x039A );
	XKEYSYM_TO_UNICODE.set( 0x07CB, 0x039B );
	XKEYSYM_TO_UNICODE.set( 0x07CC, 0x039C );
	XKEYSYM_TO_UNICODE.set( 0x07CD, 0x039D );
	XKEYSYM_TO_UNICODE.set( 0x07CE, 0x039E );
	XKEYSYM_TO_UNICODE.set( 0x07CF, 0x039F );
	XKEYSYM_TO_UNICODE.set( 0x07D0, 0x03A0 );
	XKEYSYM_TO_UNICODE.set( 0x07D1, 0x03A1 );
	XKEYSYM_TO_UNICODE.set( 0x07D2, 0x03A3 );
	XKEYSYM_TO_UNICODE.set( 0x07D4, 0x03A4 );
	XKEYSYM_TO_UNICODE.set( 0x07D5, 0x03A5 );
	XKEYSYM_TO_UNICODE.set( 0x07D6, 0x03A6 );
	XKEYSYM_TO_UNICODE.set( 0x07D7, 0x03A7 );
	XKEYSYM_TO_UNICODE.set( 0x07D8, 0x03A8 );
	XKEYSYM_TO_UNICODE.set( 0x07D9, 0x03A9 );
	XKEYSYM_TO_UNICODE.set( 0x07E1, 0x03B1 );
	XKEYSYM_TO_UNICODE.set( 0x07E2, 0x03B2 );
	XKEYSYM_TO_UNICODE.set( 0x07E3, 0x03B3 );
	XKEYSYM_TO_UNICODE.set( 0x07E4, 0x03B4 );
	XKEYSYM_TO_UNICODE.set( 0x07E5, 0x03B5 );
	XKEYSYM_TO_UNICODE.set( 0x07E6, 0x03B6 );
	XKEYSYM_TO_UNICODE.set( 0x07E7, 0x03B7 );
	XKEYSYM_TO_UNICODE.set( 0x07E8, 0x03B8 );
	XKEYSYM_TO_UNICODE.set( 0x07E9, 0x03B9 );
	XKEYSYM_TO_UNICODE.set( 0x07EA, 0x03BA );
	XKEYSYM_TO_UNICODE.set( 0x07EB, 0x03BB );
	XKEYSYM_TO_UNICODE.set( 0x07EC, 0x03BC );
	XKEYSYM_TO_UNICODE.set( 0x07ED, 0x03BD );
	XKEYSYM_TO_UNICODE.set( 0x07EE, 0x03BE );
	XKEYSYM_TO_UNICODE.set( 0x07EF, 0x03BF );
	XKEYSYM_TO_UNICODE.set( 0x07F0, 0x03C0 );
	XKEYSYM_TO_UNICODE.set( 0x07F1, 0x03C1 );
	XKEYSYM_TO_UNICODE.set( 0x07F2, 0x03C3 );
	XKEYSYM_TO_UNICODE.set( 0x07F3, 0x03C2 );
	XKEYSYM_TO_UNICODE.set( 0x07F4, 0x03C4 );
	XKEYSYM_TO_UNICODE.set( 0x07F5, 0x03C5 );
	XKEYSYM_TO_UNICODE.set( 0x07F6, 0x03C6 );
	XKEYSYM_TO_UNICODE.set( 0x07F7, 0x03C7 );
	XKEYSYM_TO_UNICODE.set( 0x07F8, 0x03C8 );
	XKEYSYM_TO_UNICODE.set( 0x07F9, 0x03C9 );
	XKEYSYM_TO_UNICODE.set( 0x08A1, 0x23B7 );
	XKEYSYM_TO_UNICODE.set( 0x08A2, 0x250C );
	XKEYSYM_TO_UNICODE.set( 0x08A3, 0x2500 );
	XKEYSYM_TO_UNICODE.set( 0x08A4, 0x2320 );
	XKEYSYM_TO_UNICODE.set( 0x08A5, 0x2321 );
	XKEYSYM_TO_UNICODE.set( 0x08A6, 0x2502 );
	XKEYSYM_TO_UNICODE.set( 0x08A7, 0x23A1 );
	XKEYSYM_TO_UNICODE.set( 0x08A8, 0x23A3 );
	XKEYSYM_TO_UNICODE.set( 0x08A9, 0x23A4 );
	XKEYSYM_TO_UNICODE.set( 0x08AA, 0x23A6 );
	XKEYSYM_TO_UNICODE.set( 0x08AB, 0x239B );
	XKEYSYM_TO_UNICODE.set( 0x08AC, 0x239D );
	XKEYSYM_TO_UNICODE.set( 0x08AD, 0x239E );
	XKEYSYM_TO_UNICODE.set( 0x08AE, 0x23A0 );
	XKEYSYM_TO_UNICODE.set( 0x08AF, 0x23A8 );
	XKEYSYM_TO_UNICODE.set( 0x08B0, 0x23AC );
	XKEYSYM_TO_UNICODE.set( 0x08BC, 0x2264 );
	XKEYSYM_TO_UNICODE.set( 0x08BD, 0x2260 );
	XKEYSYM_TO_UNICODE.set( 0x08BE, 0x2265 );
	XKEYSYM_TO_UNICODE.set( 0x08BF, 0x222B );
	XKEYSYM_TO_UNICODE.set( 0x08C0, 0x2234 );
	XKEYSYM_TO_UNICODE.set( 0x08C1, 0x221D );
	XKEYSYM_TO_UNICODE.set( 0x08C2, 0x221E );
	XKEYSYM_TO_UNICODE.set( 0x08C5, 0x2207 );
	XKEYSYM_TO_UNICODE.set( 0x08C8, 0x223C );
	XKEYSYM_TO_UNICODE.set( 0x08C9, 0x2243 );
	XKEYSYM_TO_UNICODE.set( 0x08CD, 0x21D4 );
	XKEYSYM_TO_UNICODE.set( 0x08CE, 0x21D2 );
	XKEYSYM_TO_UNICODE.set( 0x08CF, 0x2261 );
	XKEYSYM_TO_UNICODE.set( 0x08D6, 0x221A );
	XKEYSYM_TO_UNICODE.set( 0x08DA, 0x2282 );
	XKEYSYM_TO_UNICODE.set( 0x08DB, 0x2283 );
	XKEYSYM_TO_UNICODE.set( 0x08DC, 0x2229 );
	XKEYSYM_TO_UNICODE.set( 0x08DD, 0x222A );
	XKEYSYM_TO_UNICODE.set( 0x08DE, 0x2227 );
	XKEYSYM_TO_UNICODE.set( 0x08DF, 0x2228 );
	XKEYSYM_TO_UNICODE.set( 0x08EF, 0x2202 );
	XKEYSYM_TO_UNICODE.set( 0x08F6, 0x0192 );
	XKEYSYM_TO_UNICODE.set( 0x08FB, 0x2190 );
	XKEYSYM_TO_UNICODE.set( 0x08FC, 0x2191 );
	XKEYSYM_TO_UNICODE.set( 0x08FD, 0x2192 );
	XKEYSYM_TO_UNICODE.set( 0x08FE, 0x2193 );
	XKEYSYM_TO_UNICODE.set( 0x09E0, 0x25C6 );
	XKEYSYM_TO_UNICODE.set( 0x09E1, 0x2592 );
	XKEYSYM_TO_UNICODE.set( 0x09E2, 0x2409 );
	XKEYSYM_TO_UNICODE.set( 0x09E3, 0x240C );
	XKEYSYM_TO_UNICODE.set( 0x09E4, 0x240D );
	XKEYSYM_TO_UNICODE.set( 0x09E5, 0x240A );
	XKEYSYM_TO_UNICODE.set( 0x09E8, 0x2424 );
	XKEYSYM_TO_UNICODE.set( 0x09E9, 0x240B );
	XKEYSYM_TO_UNICODE.set( 0x09EA, 0x2518 );
	XKEYSYM_TO_UNICODE.set( 0x09EB, 0x2510 );
	XKEYSYM_TO_UNICODE.set( 0x09EC, 0x250C );
	XKEYSYM_TO_UNICODE.set( 0x09ED, 0x2514 );
	XKEYSYM_TO_UNICODE.set( 0x09EE, 0x253C );
	XKEYSYM_TO_UNICODE.set( 0x09EF, 0x23BA );
	XKEYSYM_TO_UNICODE.set( 0x09F0, 0x23BB );
	XKEYSYM_TO_UNICODE.set( 0x09F1, 0x2500 );
	XKEYSYM_TO_UNICODE.set( 0x09F2, 0x23BC );
	XKEYSYM_TO_UNICODE.set( 0x09F3, 0x23BD );
	XKEYSYM_TO_UNICODE.set( 0x09F4, 0x251C );
	XKEYSYM_TO_UNICODE.set( 0x09F5, 0x2524 );
	XKEYSYM_TO_UNICODE.set( 0x09F6, 0x2534 );
	XKEYSYM_TO_UNICODE.set( 0x09F7, 0x252C );
	XKEYSYM_TO_UNICODE.set( 0x09F8, 0x2502 );
	XKEYSYM_TO_UNICODE.set( 0x0AA1, 0x2003 );
	XKEYSYM_TO_UNICODE.set( 0x0AA2, 0x2002 );
	XKEYSYM_TO_UNICODE.set( 0x0AA3, 0x2004 );
	XKEYSYM_TO_UNICODE.set( 0x0AA4, 0x2005 );
	XKEYSYM_TO_UNICODE.set( 0x0AA5, 0x2007 );
	XKEYSYM_TO_UNICODE.set( 0x0AA6, 0x2008 );
	XKEYSYM_TO_UNICODE.set( 0x0AA7, 0x2009 );
	XKEYSYM_TO_UNICODE.set( 0x0AA8, 0x200A );
	XKEYSYM_TO_UNICODE.set( 0x0AA9, 0x2014 );
	XKEYSYM_TO_UNICODE.set( 0x0AAA, 0x2013 );
	XKEYSYM_TO_UNICODE.set( 0x0AAE, 0x2026 );
	XKEYSYM_TO_UNICODE.set( 0x0AAF, 0x2025 );
	XKEYSYM_TO_UNICODE.set( 0x0AB0, 0x2153 );
	XKEYSYM_TO_UNICODE.set( 0x0AB1, 0x2154 );
	XKEYSYM_TO_UNICODE.set( 0x0AB2, 0x2155 );
	XKEYSYM_TO_UNICODE.set( 0x0AB3, 0x2156 );
	XKEYSYM_TO_UNICODE.set( 0x0AB4, 0x2157 );
	XKEYSYM_TO_UNICODE.set( 0x0AB5, 0x2158 );
	XKEYSYM_TO_UNICODE.set( 0x0AB6, 0x2159 );
	XKEYSYM_TO_UNICODE.set( 0x0AB7, 0x215A );
	XKEYSYM_TO_UNICODE.set( 0x0AB8, 0x2105 );
	XKEYSYM_TO_UNICODE.set( 0x0ABB, 0x2012 );
	XKEYSYM_TO_UNICODE.set( 0x0ABC, 0x2329 );
	XKEYSYM_TO_UNICODE.set( 0x0ABE, 0x232A );
	XKEYSYM_TO_UNICODE.set( 0x0AC3, 0x215B );
	XKEYSYM_TO_UNICODE.set( 0x0AC4, 0x215C );
	XKEYSYM_TO_UNICODE.set( 0x0AC5, 0x215D );
	XKEYSYM_TO_UNICODE.set( 0x0AC6, 0x215E );
	XKEYSYM_TO_UNICODE.set( 0x0AC9, 0x2122 );
	XKEYSYM_TO_UNICODE.set( 0x0ACA, 0x2613 );
	XKEYSYM_TO_UNICODE.set( 0x0ACC, 0x25C1 );
	XKEYSYM_TO_UNICODE.set( 0x0ACD, 0x25B7 );
	XKEYSYM_TO_UNICODE.set( 0x0ACE, 0x25CB );
	XKEYSYM_TO_UNICODE.set( 0x0ACF, 0x25AF );
	XKEYSYM_TO_UNICODE.set( 0x0AD0, 0x2018 );
	XKEYSYM_TO_UNICODE.set( 0x0AD1, 0x2019 );
	XKEYSYM_TO_UNICODE.set( 0x0AD2, 0x201C );
	XKEYSYM_TO_UNICODE.set( 0x0AD3, 0x201D );
	XKEYSYM_TO_UNICODE.set( 0x0AD4, 0x211E );
	XKEYSYM_TO_UNICODE.set( 0x0AD6, 0x2032 );
	XKEYSYM_TO_UNICODE.set( 0x0AD7, 0x2033 );
	XKEYSYM_TO_UNICODE.set( 0x0AD9, 0x271D );
	XKEYSYM_TO_UNICODE.set( 0x0ADB, 0x25AC );
	XKEYSYM_TO_UNICODE.set( 0x0ADC, 0x25C0 );
	XKEYSYM_TO_UNICODE.set( 0x0ADD, 0x25B6 );
	XKEYSYM_TO_UNICODE.set( 0x0ADE, 0x25CF );
	XKEYSYM_TO_UNICODE.set( 0x0ADF, 0x25AE );
	XKEYSYM_TO_UNICODE.set( 0x0AE0, 0x25E6 );
	XKEYSYM_TO_UNICODE.set( 0x0AE1, 0x25AB );
	XKEYSYM_TO_UNICODE.set( 0x0AE2, 0x25AD );
	XKEYSYM_TO_UNICODE.set( 0x0AE3, 0x25B3 );
	XKEYSYM_TO_UNICODE.set( 0x0AE4, 0x25BD );
	XKEYSYM_TO_UNICODE.set( 0x0AE5, 0x2606 );
	XKEYSYM_TO_UNICODE.set( 0x0AE6, 0x2022 );
	XKEYSYM_TO_UNICODE.set( 0x0AE7, 0x25AA );
	XKEYSYM_TO_UNICODE.set( 0x0AE8, 0x25B2 );
	XKEYSYM_TO_UNICODE.set( 0x0AE9, 0x25BC );
	XKEYSYM_TO_UNICODE.set( 0x0AEA, 0x261C );
	XKEYSYM_TO_UNICODE.set( 0x0AEB, 0x261E );
	XKEYSYM_TO_UNICODE.set( 0x0AEC, 0x2663 );
	XKEYSYM_TO_UNICODE.set( 0x0AED, 0x2666 );
	XKEYSYM_TO_UNICODE.set( 0x0AEE, 0x2665 );
	XKEYSYM_TO_UNICODE.set( 0x0AF0, 0x2720 );
	XKEYSYM_TO_UNICODE.set( 0x0AF1, 0x2020 );
	XKEYSYM_TO_UNICODE.set( 0x0AF2, 0x2021 );
	XKEYSYM_TO_UNICODE.set( 0x0AF3, 0x2713 );
	XKEYSYM_TO_UNICODE.set( 0x0AF4, 0x2717 );
	XKEYSYM_TO_UNICODE.set( 0x0AF5, 0x266F );
	XKEYSYM_TO_UNICODE.set( 0x0AF6, 0x266D );
	XKEYSYM_TO_UNICODE.set( 0x0AF7, 0x2642 );
	XKEYSYM_TO_UNICODE.set( 0x0AF8, 0x2640 );
	XKEYSYM_TO_UNICODE.set( 0x0AF9, 0x260E );
	XKEYSYM_TO_UNICODE.set( 0x0AFA, 0x2315 );
	XKEYSYM_TO_UNICODE.set( 0x0AFB, 0x2117 );
	XKEYSYM_TO_UNICODE.set( 0x0AFC, 0x2038 );
	XKEYSYM_TO_UNICODE.set( 0x0AFD, 0x201A );
	XKEYSYM_TO_UNICODE.set( 0x0AFE, 0x201E );
	XKEYSYM_TO_UNICODE.set( 0x0BA3, 0x003C );
	XKEYSYM_TO_UNICODE.set( 0x0BA6, 0x003E );
	XKEYSYM_TO_UNICODE.set( 0x0BA8, 0x2228 );
	XKEYSYM_TO_UNICODE.set( 0x0BA9, 0x2227 );
	XKEYSYM_TO_UNICODE.set( 0x0BC0, 0x00AF );
	XKEYSYM_TO_UNICODE.set( 0x0BC2, 0x22A5 );
	XKEYSYM_TO_UNICODE.set( 0x0BC3, 0x2229 );
	XKEYSYM_TO_UNICODE.set( 0x0BC4, 0x230A );
	XKEYSYM_TO_UNICODE.set( 0x0BC6, 0x005F );
	XKEYSYM_TO_UNICODE.set( 0x0BCA, 0x2218 );
	XKEYSYM_TO_UNICODE.set( 0x0BCC, 0x2395 );
	XKEYSYM_TO_UNICODE.set( 0x0BCE, 0x22A4 );
	XKEYSYM_TO_UNICODE.set( 0x0BCF, 0x25CB );
	XKEYSYM_TO_UNICODE.set( 0x0BD3, 0x2308 );
	XKEYSYM_TO_UNICODE.set( 0x0BD6, 0x222A );
	XKEYSYM_TO_UNICODE.set( 0x0BD8, 0x2283 );
	XKEYSYM_TO_UNICODE.set( 0x0BDA, 0x2282 );
	XKEYSYM_TO_UNICODE.set( 0x0BDC, 0x22A2 );
	XKEYSYM_TO_UNICODE.set( 0x0BFC, 0x22A3 );
	XKEYSYM_TO_UNICODE.set( 0x0CDF, 0x2017 );
	XKEYSYM_TO_UNICODE.set( 0x0CE0, 0x05D0 );
	XKEYSYM_TO_UNICODE.set( 0x0CE1, 0x05D1 );
	XKEYSYM_TO_UNICODE.set( 0x0CE2, 0x05D2 );
	XKEYSYM_TO_UNICODE.set( 0x0CE3, 0x05D3 );
	XKEYSYM_TO_UNICODE.set( 0x0CE4, 0x05D4 );
	XKEYSYM_TO_UNICODE.set( 0x0CE5, 0x05D5 );
	XKEYSYM_TO_UNICODE.set( 0x0CE6, 0x05D6 );
	XKEYSYM_TO_UNICODE.set( 0x0CE7, 0x05D7 );
	XKEYSYM_TO_UNICODE.set( 0x0CE8, 0x05D8 );
	XKEYSYM_TO_UNICODE.set( 0x0CE9, 0x05D9 );
	XKEYSYM_TO_UNICODE.set( 0x0CEA, 0x05DA );
	XKEYSYM_TO_UNICODE.set( 0x0CEB, 0x05DB );
	XKEYSYM_TO_UNICODE.set( 0x0CEC, 0x05DC );
	XKEYSYM_TO_UNICODE.set( 0x0CED, 0x05DD );
	XKEYSYM_TO_UNICODE.set( 0x0CEE, 0x05DE );
	XKEYSYM_TO_UNICODE.set( 0x0CEF, 0x05DF );
	XKEYSYM_TO_UNICODE.set( 0x0CF0, 0x05E0 );
	XKEYSYM_TO_UNICODE.set( 0x0CF1, 0x05E1 );
	XKEYSYM_TO_UNICODE.set( 0x0CF2, 0x05E2 );
	XKEYSYM_TO_UNICODE.set( 0x0CF3, 0x05E3 );
	XKEYSYM_TO_UNICODE.set( 0x0CF4, 0x05E4 );
	XKEYSYM_TO_UNICODE.set( 0x0CF5, 0x05E5 );
	XKEYSYM_TO_UNICODE.set( 0x0CF6, 0x05E6 );
	XKEYSYM_TO_UNICODE.set( 0x0CF7, 0x05E7 );
	XKEYSYM_TO_UNICODE.set( 0x0CF8, 0x05E8 );
	XKEYSYM_TO_UNICODE.set( 0x0CF9, 0x05E9 );
	XKEYSYM_TO_UNICODE.set( 0x0CFA, 0x05EA );
	XKEYSYM_TO_UNICODE.set( 0x0DA1, 0x0E01 );
	XKEYSYM_TO_UNICODE.set( 0x0DA2, 0x0E02 );
	XKEYSYM_TO_UNICODE.set( 0x0DA3, 0x0E03 );
	XKEYSYM_TO_UNICODE.set( 0x0DA4, 0x0E04 );
	XKEYSYM_TO_UNICODE.set( 0x0DA5, 0x0E05 );
	XKEYSYM_TO_UNICODE.set( 0x0DA6, 0x0E06 );
	XKEYSYM_TO_UNICODE.set( 0x0DA7, 0x0E07 );
	XKEYSYM_TO_UNICODE.set( 0x0DA8, 0x0E08 );
	XKEYSYM_TO_UNICODE.set( 0x0DA9, 0x0E09 );
	XKEYSYM_TO_UNICODE.set( 0x0DAA, 0x0E0A );
	XKEYSYM_TO_UNICODE.set( 0x0DAB, 0x0E0B );
	XKEYSYM_TO_UNICODE.set( 0x0DAC, 0x0E0C );
	XKEYSYM_TO_UNICODE.set( 0x0DAD, 0x0E0D );
	XKEYSYM_TO_UNICODE.set( 0x0DAE, 0x0E0E );
	XKEYSYM_TO_UNICODE.set( 0x0DAF, 0x0E0F );
	XKEYSYM_TO_UNICODE.set( 0x0DB0, 0x0E10 );
	XKEYSYM_TO_UNICODE.set( 0x0DB1, 0x0E11 );
	XKEYSYM_TO_UNICODE.set( 0x0DB2, 0x0E12 );
	XKEYSYM_TO_UNICODE.set( 0x0DB3, 0x0E13 );
	XKEYSYM_TO_UNICODE.set( 0x0DB4, 0x0E14 );
	XKEYSYM_TO_UNICODE.set( 0x0DB5, 0x0E15 );
	XKEYSYM_TO_UNICODE.set( 0x0DB6, 0x0E16 );
	XKEYSYM_TO_UNICODE.set( 0x0DB7, 0x0E17 );
	XKEYSYM_TO_UNICODE.set( 0x0DB8, 0x0E18 );
	XKEYSYM_TO_UNICODE.set( 0x0DB9, 0x0E19 );
	XKEYSYM_TO_UNICODE.set( 0x0DBA, 0x0E1A );
	XKEYSYM_TO_UNICODE.set( 0x0DBB, 0x0E1B );
	XKEYSYM_TO_UNICODE.set( 0x0DBC, 0x0E1C );
	XKEYSYM_TO_UNICODE.set( 0x0DBD, 0x0E1D );
	XKEYSYM_TO_UNICODE.set( 0x0DBE, 0x0E1E );
	XKEYSYM_TO_UNICODE.set( 0x0DBF, 0x0E1F );
	XKEYSYM_TO_UNICODE.set( 0x0DC0, 0x0E20 );
	XKEYSYM_TO_UNICODE.set( 0x0DC1, 0x0E21 );
	XKEYSYM_TO_UNICODE.set( 0x0DC2, 0x0E22 );
	XKEYSYM_TO_UNICODE.set( 0x0DC3, 0x0E23 );
	XKEYSYM_TO_UNICODE.set( 0x0DC4, 0x0E24 );
	XKEYSYM_TO_UNICODE.set( 0x0DC5, 0x0E25 );
	XKEYSYM_TO_UNICODE.set( 0x0DC6, 0x0E26 );
	XKEYSYM_TO_UNICODE.set( 0x0DC7, 0x0E27 );
	XKEYSYM_TO_UNICODE.set( 0x0DC8, 0x0E28 );
	XKEYSYM_TO_UNICODE.set( 0x0DC9, 0x0E29 );
	XKEYSYM_TO_UNICODE.set( 0x0DCA, 0x0E2A );
	XKEYSYM_TO_UNICODE.set( 0x0DCB, 0x0E2B );
	XKEYSYM_TO_UNICODE.set( 0x0DCC, 0x0E2C );
	XKEYSYM_TO_UNICODE.set( 0x0DCD, 0x0E2D );
	XKEYSYM_TO_UNICODE.set( 0x0DCE, 0x0E2E );
	XKEYSYM_TO_UNICODE.set( 0x0DCF, 0x0E2F );
	XKEYSYM_TO_UNICODE.set( 0x0DD0, 0x0E30 );
	XKEYSYM_TO_UNICODE.set( 0x0DD1, 0x0E31 );
	XKEYSYM_TO_UNICODE.set( 0x0DD2, 0x0E32 );
	XKEYSYM_TO_UNICODE.set( 0x0DD3, 0x0E33 );
	XKEYSYM_TO_UNICODE.set( 0x0DD4, 0x0E34 );
	XKEYSYM_TO_UNICODE.set( 0x0DD5, 0x0E35 );
	XKEYSYM_TO_UNICODE.set( 0x0DD6, 0x0E36 );
	XKEYSYM_TO_UNICODE.set( 0x0DD7, 0x0E37 );
	XKEYSYM_TO_UNICODE.set( 0x0DD8, 0x0E38 );
	XKEYSYM_TO_UNICODE.set( 0x0DD9, 0x0E39 );
	XKEYSYM_TO_UNICODE.set( 0x0DDA, 0x0E3A );
	XKEYSYM_TO_UNICODE.set( 0x0DDF, 0x0E3F );
	XKEYSYM_TO_UNICODE.set( 0x0DE0, 0x0E40 );
	XKEYSYM_TO_UNICODE.set( 0x0DE1, 0x0E41 );
	XKEYSYM_TO_UNICODE.set( 0x0DE2, 0x0E42 );
	XKEYSYM_TO_UNICODE.set( 0x0DE3, 0x0E43 );
	XKEYSYM_TO_UNICODE.set( 0x0DE4, 0x0E44 );
	XKEYSYM_TO_UNICODE.set( 0x0DE5, 0x0E45 );
	XKEYSYM_TO_UNICODE.set( 0x0DE6, 0x0E46 );
	XKEYSYM_TO_UNICODE.set( 0x0DE7, 0x0E47 );
	XKEYSYM_TO_UNICODE.set( 0x0DE8, 0x0E48 );
	XKEYSYM_TO_UNICODE.set( 0x0DE9, 0x0E49 );
	XKEYSYM_TO_UNICODE.set( 0x0DEA, 0x0E4A );
	XKEYSYM_TO_UNICODE.set( 0x0DEB, 0x0E4B );
	XKEYSYM_TO_UNICODE.set( 0x0DEC, 0x0E4C );
	XKEYSYM_TO_UNICODE.set( 0x0DED, 0x0E4D );
	XKEYSYM_TO_UNICODE.set( 0x0DF0, 0x0E50 );
	XKEYSYM_TO_UNICODE.set( 0x0DF1, 0x0E51 );
	XKEYSYM_TO_UNICODE.set( 0x0DF2, 0x0E52 );
	XKEYSYM_TO_UNICODE.set( 0x0DF3, 0x0E53 );
	XKEYSYM_TO_UNICODE.set( 0x0DF4, 0x0E54 );
	XKEYSYM_TO_UNICODE.set( 0x0DF5, 0x0E55 );
	XKEYSYM_TO_UNICODE.set( 0x0DF6, 0x0E56 );
	XKEYSYM_TO_UNICODE.set( 0x0DF7, 0x0E57 );
	XKEYSYM_TO_UNICODE.set( 0x0DF8, 0x0E58 );
	XKEYSYM_TO_UNICODE.set( 0x0DF9, 0x0E59 );
	XKEYSYM_TO_UNICODE.set( 0x0EA1, 0x3131 );
	XKEYSYM_TO_UNICODE.set( 0x0EA2, 0x3132 );
	XKEYSYM_TO_UNICODE.set( 0x0EA3, 0x3133 );
	XKEYSYM_TO_UNICODE.set( 0x0EA4, 0x3134 );
	XKEYSYM_TO_UNICODE.set( 0x0EA5, 0x3135 );
	XKEYSYM_TO_UNICODE.set( 0x0EA6, 0x3136 );
	XKEYSYM_TO_UNICODE.set( 0x0EA7, 0x3137 );
	XKEYSYM_TO_UNICODE.set( 0x0EA8, 0x3138 );
	XKEYSYM_TO_UNICODE.set( 0x0EA9, 0x3139 );
	XKEYSYM_TO_UNICODE.set( 0x0EAA, 0x313A );
	XKEYSYM_TO_UNICODE.set( 0x0EAB, 0x313B );
	XKEYSYM_TO_UNICODE.set( 0x0EAC, 0x313C );
	XKEYSYM_TO_UNICODE.set( 0x0EAD, 0x313D );
	XKEYSYM_TO_UNICODE.set( 0x0EAE, 0x313E );
	XKEYSYM_TO_UNICODE.set( 0x0EAF, 0x313F );
	XKEYSYM_TO_UNICODE.set( 0x0EB0, 0x3140 );
	XKEYSYM_TO_UNICODE.set( 0x0EB1, 0x3141 );
	XKEYSYM_TO_UNICODE.set( 0x0EB2, 0x3142 );
	XKEYSYM_TO_UNICODE.set( 0x0EB3, 0x3143 );
	XKEYSYM_TO_UNICODE.set( 0x0EB4, 0x3144 );
	XKEYSYM_TO_UNICODE.set( 0x0EB5, 0x3145 );
	XKEYSYM_TO_UNICODE.set( 0x0EB6, 0x3146 );
	XKEYSYM_TO_UNICODE.set( 0x0EB7, 0x3147 );
	XKEYSYM_TO_UNICODE.set( 0x0EB8, 0x3148 );
	XKEYSYM_TO_UNICODE.set( 0x0EB9, 0x3149 );
	XKEYSYM_TO_UNICODE.set( 0x0EBA, 0x314A );
	XKEYSYM_TO_UNICODE.set( 0x0EBB, 0x314B );
	XKEYSYM_TO_UNICODE.set( 0x0EBC, 0x314C );
	XKEYSYM_TO_UNICODE.set( 0x0EBD, 0x314D );
	XKEYSYM_TO_UNICODE.set( 0x0EBE, 0x314E );
	XKEYSYM_TO_UNICODE.set( 0x0EBF, 0x314F );
	XKEYSYM_TO_UNICODE.set( 0x0EC0, 0x3150 );
	XKEYSYM_TO_UNICODE.set( 0x0EC1, 0x3151 );
	XKEYSYM_TO_UNICODE.set( 0x0EC2, 0x3152 );
	XKEYSYM_TO_UNICODE.set( 0x0EC3, 0x3153 );
	XKEYSYM_TO_UNICODE.set( 0x0EC4, 0x3154 );
	XKEYSYM_TO_UNICODE.set( 0x0EC5, 0x3155 );
	XKEYSYM_TO_UNICODE.set( 0x0EC6, 0x3156 );
	XKEYSYM_TO_UNICODE.set( 0x0EC7, 0x3157 );
	XKEYSYM_TO_UNICODE.set( 0x0EC8, 0x3158 );
	XKEYSYM_TO_UNICODE.set( 0x0EC9, 0x3159 );
	XKEYSYM_TO_UNICODE.set( 0x0ECA, 0x315A );
	XKEYSYM_TO_UNICODE.set( 0x0ECB, 0x315B );
	XKEYSYM_TO_UNICODE.set( 0x0ECC, 0x315C );
	XKEYSYM_TO_UNICODE.set( 0x0ECD, 0x315D );
	XKEYSYM_TO_UNICODE.set( 0x0ECE, 0x315E );
	XKEYSYM_TO_UNICODE.set( 0x0ECF, 0x315F );
	XKEYSYM_TO_UNICODE.set( 0x0ED0, 0x3160 );
	XKEYSYM_TO_UNICODE.set( 0x0ED1, 0x3161 );
	XKEYSYM_TO_UNICODE.set( 0x0ED2, 0x3162 );
	XKEYSYM_TO_UNICODE.set( 0x0ED3, 0x3163 );
	XKEYSYM_TO_UNICODE.set( 0x0ED4, 0x11A8 );
	XKEYSYM_TO_UNICODE.set( 0x0ED5, 0x11A9 );
	XKEYSYM_TO_UNICODE.set( 0x0ED6, 0x11AA );
	XKEYSYM_TO_UNICODE.set( 0x0ED7, 0x11AB );
	XKEYSYM_TO_UNICODE.set( 0x0ED8, 0x11AC );
	XKEYSYM_TO_UNICODE.set( 0x0ED9, 0x11AD );
	XKEYSYM_TO_UNICODE.set( 0x0EDA, 0x11AE );
	XKEYSYM_TO_UNICODE.set( 0x0EDB, 0x11AF );
	XKEYSYM_TO_UNICODE.set( 0x0EDC, 0x11B0 );
	XKEYSYM_TO_UNICODE.set( 0x0EDD, 0x11B1 );
	XKEYSYM_TO_UNICODE.set( 0x0EDE, 0x11B2 );
	XKEYSYM_TO_UNICODE.set( 0x0EDF, 0x11B3 );
	XKEYSYM_TO_UNICODE.set( 0x0EE0, 0x11B4 );
	XKEYSYM_TO_UNICODE.set( 0x0EE1, 0x11B5 );
	XKEYSYM_TO_UNICODE.set( 0x0EE2, 0x11B6 );
	XKEYSYM_TO_UNICODE.set( 0x0EE3, 0x11B7 );
	XKEYSYM_TO_UNICODE.set( 0x0EE4, 0x11B8 );
	XKEYSYM_TO_UNICODE.set( 0x0EE5, 0x11B9 );
	XKEYSYM_TO_UNICODE.set( 0x0EE6, 0x11BA );
	XKEYSYM_TO_UNICODE.set( 0x0EE7, 0x11BB );
	XKEYSYM_TO_UNICODE.set( 0x0EE8, 0x11BC );
	XKEYSYM_TO_UNICODE.set( 0x0EE9, 0x11BD );
	XKEYSYM_TO_UNICODE.set( 0x0EEA, 0x11BE );
	XKEYSYM_TO_UNICODE.set( 0x0EEB, 0x11BF );
	XKEYSYM_TO_UNICODE.set( 0x0EEC, 0x11C0 );
	XKEYSYM_TO_UNICODE.set( 0x0EED, 0x11C1 );
	XKEYSYM_TO_UNICODE.set( 0x0EEE, 0x11C2 );
	XKEYSYM_TO_UNICODE.set( 0x0EEF, 0x316D );
	XKEYSYM_TO_UNICODE.set( 0x0EF0, 0x3171 );
	XKEYSYM_TO_UNICODE.set( 0x0EF1, 0x3178 );
	XKEYSYM_TO_UNICODE.set( 0x0EF2, 0x317F );
	XKEYSYM_TO_UNICODE.set( 0x0EF3, 0x3181 );
	XKEYSYM_TO_UNICODE.set( 0x0EF4, 0x3184 );
	XKEYSYM_TO_UNICODE.set( 0x0EF5, 0x3186 );
	XKEYSYM_TO_UNICODE.set( 0x0EF6, 0x318D );
	XKEYSYM_TO_UNICODE.set( 0x0EF7, 0x318E );
	XKEYSYM_TO_UNICODE.set( 0x0EF8, 0x11EB );
	XKEYSYM_TO_UNICODE.set( 0x0EF9, 0x11F0 );
	XKEYSYM_TO_UNICODE.set( 0x0EFA, 0x11F9 );
	XKEYSYM_TO_UNICODE.set( 0x0EFF, 0x20A9 );
	XKEYSYM_TO_UNICODE.set( 0x13A4, 0x20AC );
	XKEYSYM_TO_UNICODE.set( 0x13BC, 0x0152 );
	XKEYSYM_TO_UNICODE.set( 0x13BD, 0x0153 );
	XKEYSYM_TO_UNICODE.set( 0x13BE, 0x0178 );
	XKEYSYM_TO_UNICODE.set( 0x20AC, 0x20AC );

  XKEYSYM_TO_UNICODE_KEYS = XKEYSYM_TO_UNICODE.keys();
}

static EKeyboard getKeyboardEnum( ulong keycode ) {
    return XII_KEYBOARD_MAPPING.get( keycode, EKeyboard.INVALID );
}

static dchar keysymToUnicode( KeySym sym ) {
    //Latin-1
    if ( sym >= 0x20 && sym <= 0x7e ) {
        return cast( dchar )sym;
    }

    if ( sym >= 0xa0 && sym <= 0xff ) {
        return cast( dchar )sym;
    }

    //Latin-1 keypad
    if ( sym >= 0xffaa && sym <= 0xffb9 ) {
        return cast( dchar )( sym - 0xff80 );
    }


    //Unicode
    if ( ( sym & 0xff000000 ) == 0x01000000 ) {
        return cast( dchar )( sym & 0x00ffffff );
    }

    int middle;
    int low = 0;
    int hight = KEYSYM_MAX - 1;
    
    do {
        middle = ( hight + low ) / 2;

        //Simple check for unhandlable keys, like shift
        if ( XKEYSYM_TO_UNICODE.length <= middle ) {
            return 0x0;
        }

        if ( XKEYSYM_TO_UNICODE_KEYS[middle] == sym ) {
            return XKEYSYM_TO_UNICODE.get( middle, ' ' );
        }

        if ( XKEYSYM_TO_UNICODE_KEYS[middle] <= sym ) {
            low = middle + 1;
        } else {
            hight = middle - 1;
        }

    } while( hight >= low );

    return 0;
}