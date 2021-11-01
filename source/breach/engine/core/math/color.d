module engine.core.math.color;

import core.stdc.stdlib : strtoul;

import engine.core.containers.array;
import engine.core.math.vec;
import engine.core.string; 

enum COLOR_ELEMS_NAMES = [ "r", "g", "b", "a" ];

template SColorN( int size ) {
	alias SColorN = SVec!( float, size, COLOR_ELEMS_NAMES );
}

alias SColorRGB = SColorN!( 3 );
alias SColorRGBA = SColorN!( 4 );

enum EColors : SColorRGBA {
	WHITE = SColorRGBA( 1.0f ),
	BLACK = SColorRGBA( 0.0f, 0.0f, 0.0f, 1.0f ),
	
	RED = SColorRGBA( 1.0f, 0.0f, 0.0f, 1.0f ),
	GREEN = SColorRGBA( 0.0f, 1.0f, 0.0f, 1.0f ),
	BLUE = SColorRGBA( 0.0f, 0.0f, 1.0f, 1.0f ),
}

SColorRGBA getColorFromHex( int hex ) {
    return SColorRGBA(
            ((hex >> 16) & 0xff) / 255.0f,
            ((hex >> 8) & 0xff) / 255.0f,
            (hex & 0xff) / 255.0f,
            1.0f
        );
}

SColorRGBA getColorFromHex( String hex ) {
    return SColorRGBA(
        strtoul( hex.substr( 1, 2 ).c_str.cstr, null, 16 ) / 256.0f,
        strtoul( hex.substr( 3, 2 ).c_str.cstr, null, 16 ) / 256.0f,
        strtoul( hex.substr( 5, 2 ).c_str.cstr, null, 16 ) / 256.0f,
        1.0f
    );
}
