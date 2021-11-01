module engine.modules.neng_sub_math.curve;

import engine.core.object;
import engine.core.math;
import engine.core.containers.array;

enum ETangentMode {
    TM_FREE,
    TM_LINIAR,
    TM_MODE_COUNT,
}

struct SCurvePoint {
    SVec2F pos;
    float leftTangent = 0.0f;
    float rightTangent = 0.0f;
    ETangentMode leftMode = ETangentMode.TM_FREE;
    ETangentMode rightMode = ETangentMode.TM_FREE;
}

protected {
    struct SPoint2D {
        SVec2F lin;
        SVec2F lout;
        SVec2F lpos;
    }

    pragma( inline, true )
    static T bezierInterp( T )( real t, T start, T ctrl1, T ctrl2, T end ) {
        real omt = ( 1.0 - t );
        real omt2 = omt * omt;
        real omt3 = omt2 * omt;
        real t2 = t * t;
        real t3 = t2 * t;

        return start * omt3 + ctrl1 * omt2 * t * 3.0 + ctrl2 * omt * t2 * 3.0 + end * t3;
    }
}

class CCurve : CObject {
    mixin( TRegisterClass!CCurve );
protected:
    alias SPoint = SCurvePoint;

    enum MIN_X = 0.0f;
    enum MAX_X = 1.0f;

    Array!SPoint lpoints;

public:
    ulong addPoint(
        SVec2F ipos,
        long ileftTangent = 0,
        long irightTangent = 0,
        ETangentMode ileftMode = ETangentMode.TM_FREE,
        ETangentMode irightMode = ETangentMode.TM_FREE
    ) {
        if ( ipos.x > MAX_X ) {
            ipos.x = MAX_X;
        } else if ( ipos.x < MIN_X ) {
            ipos.x = MIN_X;
        }

        ulong ret = -1;

        if ( lpoints.length == 0 ) {
            lpoints ~= SPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode );
            ret = 0;
        } else if ( lpoints.length == 1 ) {
            float diff = ipos.x - lpoints[0].pos.x;

            if ( diff > 0 ) {
                lpoints ~= SPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode );
                ret = 1;
            } else {
                lpoints.insertAt( 0, SPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode ) );
                ret = 0;
            }
        } else {
            ulong idx = getIndex( ipos.x );

            if ( idx == 0 && ipos.x < lpoints[0].pos.x ) {
                lpoints.insertAt( 0, SPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode ) );
                ret = 0;
            } else {
                ++idx;
                lpoints.insertAt( idx, SPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode ) );
                ret = idx;
            }
        }

        return ret;
    }

    ulong updatePoint(
        ulong idx,
        SVec2F ipos,
        long ileftTangent = 0,
        long irightTangent = 0,
        ETangentMode ileftMode = ETangentMode.TM_FREE,
        ETangentMode irightMode = ETangentMode.TM_FREE
    ) {
        assert( idx < points.length );

        removePoint( idx );
        return addPoint( ipos, ileftTangent, irightTangent, ileftMode, irightMode );
    }

    void removePoint( ulong idx ) {
        lpoints.removeAt( idx );
    }

    void clearPoints() {}

    ulong getIndex( float offset ) {
        // Lower-bound float binary search
        ulong imin = 0;
        ulong imax = lpoints.length - 1;

        while ( imax - imin > 1 ) {
            ulong m = ( imin + imax ) / 2;

            float a = lpoints[m].pos.x;
            float b = lpoints[m + 1].pos.x;

            if ( a < offset && b < offset ) {
                imin = m;
            } else if ( a > offset ) {
                imax = m;
            } else {
                return m;
            }
        }

        // Will happen if the offset is out of bounds
        if ( offset > lpoints[imax].pos.x ) {
            return imax;
        }

        return imin;
    }

    float interpolate( float offset ) {
        if ( lpoints.length == 0 ) return 0;
        if ( lpoints.length == 1 ) return lpoints[0].pos.y;

        ulong i = getIndex( offset );

        if ( i == lpoints.length - 1 ) {
            return lpoints[i].pos.y;
        }

        float local = offset - lpoints[i].pos.x;

        if ( i == 0 && local <= 0 ) {
            return lpoints[i].pos.y;
        }

        return interpolateLocalNoncheck( i, local );
    }

    float interpolateLocalNoncheck( ulong idx, float offset ) {
        const SPoint a = lpoints[idx];
        const SPoint b = lpoints[idx + 1];

        /* Cubic bezier
	    *
	    *       ac-----bc
	    *      /         \
	    *     /           \     Here with a.right_tangent > 0
	    *    /             \    and b.left_tangent < 0
	    *   /               \
	    *  a                 b
	    *
	    *  |-d1--|-d2--|-d3--|
	    *
	    * d1 == d2 == d3 == d / 3
	    */

        float d = b.pos.x - a.pos.x;
        if ( Math.abs( d ) <= CMP_EPLISION ) {
            return b.pos.y;
        }
        
        offset /= d;
        d /= 3.0;
        float yac = a.pos.y + d * a.rightTangent;
        float ybc = b.pos.y - d * b.leftTangent;

        float y = bezierInterp( offset, a.pos.y, yac, ybc, b.pos.y );

        return y;
    }

    static CCurve getBasicOneValueCurve() {
        CCurve ret = newObject!CCurve();
        ret.addPoint( SVec2F( 0.0f, 1.0f ) );
        ret.addPoint( SVec2F( 1.0f, 1.0f ) );
        return ret;
    }

public:
    @property {
        void points( Array!SPoint pnts ) {
            lpoints.free();
            lpoints = pnts;
        }

        Array!SPoint points() {
            return lpoints;
        }
    }
}

class CCurve2D : CObject {
    mixin( TRegisterClass!CCurve2D );
protected:
    Array!SPoint2D lpoints;

public:
    void addPoint( SVec2F ipos, SVec2F iin = SVec2F(), SVec2F iout = SVec2F(), int atpos = -1 ) {
        SPoint2D point = SPoint2D( iin, iout, ipos );
        
        if ( atpos >= 0 && atpos < lpoints.length ) {
            lpoints.insertAt( atpos, point );
        } else {
            lpoints ~= point;
        }
    }
}
