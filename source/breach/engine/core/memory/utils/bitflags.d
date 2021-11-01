module engine.core.memory.utils.bitflags;

struct SBitflags( T = uint ) {
    ///Bits in type
    enum BITS_IN_T = T.sizeof * 8;

    T data;

    void set( size_t bit, bool bVal ) {
        if ( bit > BITS_IN_T - 1 ) {
            return;
        }

        if ( bVal ) {
            data |= 1 << bit;
        } else {
            data &= ~( 1 << bit );
        }
    }

    bool get( size_t bit ) {
        if ( bit > BITS_IN_T - 1 ) {
            return false;
        }

        return cast( bool )( data & ( 1 << bit ) );
    }

    size_t length() {
        return BITS_IN_T;
    }

    void clear() {
        for ( int i = 1; i < BITS_IN_T; i++ ) {
            set( i, false );
        }
    }
}