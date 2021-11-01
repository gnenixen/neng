module engine.core.math.aabb;

import engine.core.math.vec;
import engine.core.math.rect;

struct SAABB {
public:
    SVec2F min;
    SVec2F max;

    bool isIntersection( SAABB iaabb ) {
        if ( max.x < iaabb.min.x || min.x > iaabb.max.x ) {
            return false;
        }
        
        if ( max.y < iaabb.min.y || min.y > iaabb.max.y ) {
            return false;
        }

        return true;
    }

    static SAABB fromRect( SRect irect ) {
        return SAABB( cast( SVec2F )irect.pos, SVec2F( irect.pos.x + irect.width, irect.pos.y + irect.height ) );
    }

    static bool isIntersection( T, U )( T ifirst, U isecond )
    if ( 
        ( is( T == SAABB ) || is( T == SRect ) ) &&
        ( is( U == SAABB ) || is( U == SRect ) )
    ) {
        static if ( is( T == SAABB ) ) {
            SAABB first = ifirst;
        } else static if ( is( T == SRect ) ) {
            SAABB first = fromRect( ifirst );
        }

        static if ( is( U == SAABB ) ) {
            SAABB second = isecond;
        } else static if ( is( U == SRect ) ) {
            SAABB second = fromRect( isecond );
        }

        return first.isIntersection( second );
    }
}