module engine.core.math.rect;

public import engine.core.math.vec;

struct SRect {
public:
    SVec2F pos = SVec2F( 0.0f );
    float width = 0.0f;
    float height = 0.0f;
 
    static immutable SRect rnull = SRect( SVec2F( 0.0f, 0.0f ), 0.0f, 0.0f );

public:
    this( T )( T posx, T posy, T iwidth, T iheight ) {
        pos = SVec2F( cast( float )posx, cast( float )posy );
        width = cast( float )iwidth;
        height = cast( float )iheight;
    }

    this( SVec2F lower, SVec2F upper ) {
        pos = lower;
        width = upper.x - lower.x;
        height = upper.y - lower.x;
    }

    this( SVec2F ipos, float iwidth, float iheight ) {
        pos = ipos;
        width = iwidth;
        height = iheight;
    }

    this( float posx, float posy, float iwidth, float iheight ) {
        pos = SVec2F( posx, posy );
        width = iwidth;
        height = iheight;
    }

    static bool isContains( SRect first, SRect second ) {
        if ( second.pos.x < first.pos.x ) return false;
        if ( second.pos.y < first.pos.y ) return false;
        if ( second.pos.x + second.width > first.pos.x + first.width ) return false;
        if ( second.pos.y + second.height > first.pos.y + first.height ) return false;
        
        return true;
    }

    static bool isIntersects( SRect rect, SRect intersection ) {
        import engine.core.math.aabb;

        return SAABB.isIntersection( rect, intersection );
    }

    bool isContainsVec( SVec2F point ) {
        return  point.x >= pos.x &&
                point.x < pos.x + width &&
                point.y >= pos.y &&
                point.y < pos.y + height;
    }

    void expand( SVec2F point ) {
        SVec2F lower = lowerBound();
        SVec2F upper = upperBound();

        if ( point.x < lowerBound.x ) {
            lower.x = point.x;
        } else if ( point.x > upper.x ) {
            upper.x = point.x;
        }

        if ( point.y < lowerBound.y ) {
            lower.y = point.y;
        } else if ( point.y > upper.y ) {
            upper.y = point.y;
        }

        this = SRect( lower, upper );
    }

    void recenter( SVec2F icenter ) {
        SVec2F dims = dims();

        this = SRect( center - halfDims, dims );
    }

    SVec2F center() {
        return SVec2F(
            pos.x + width * 0.5f,
            pos.y + height * 0.5f
        );
    }

    SVec2F dims() {
        return SVec2F( width, height );
    }

    SVec2F halfDims() {
        return dims * 0.5f;
    }

    SVec2F lowerBound() {
        return pos;
    }

    SVec2F upperBound() {
        return pos + dims;
    }
}

bool isInRect( SRect rect, SVec2F pos ) {
    return  pos.x >= rect.pos.x &&
            pos.x < rect.pos.x + rect.width &&
            pos.y >= rect.pos.y &&
            pos.y < rect.pos.y + rect.height;
}
