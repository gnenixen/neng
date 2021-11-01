module engine.core.math.functions;

private {
    import std.stdint;
    import std.math;
    import std.random;
    import std.algorithm.comparison;

    import engine.core.math.perlin_noise;
}

static __gshared struct SMath {
static __gshared:
    enum PI = std.math.PI;
    enum DEG_TO_RAD = PI / 180.0f;
    enum RAD_TO_DEG = 180.0f * PI;

    static this() {
        randSeed( unpredictableSeed() );
    }

    T abs( T )( T arg ) {
        static if ( is( T == float ) ) {
            union U {
                float f;
                uint32_t i;
            }

            U u;
            u.f = arg;
            u.i &= 2147483647u;
            return u.f;
        } else static if ( is( T == double ) ) {
            union U {
                double d;
                uint64_t i;
            }

            U u;
            u.d = arg;
            u.i &= cast( uint64_t )INTMAX_MIN;
            return u.d;
        } else {
            if ( arg < 0 ) {
                return -arg;
            }

            return arg;
        }
    }

    int sign( T )( T value ) {
        if ( value > 0 ) return 1;
        if ( value < 0 ) return -1;
        return 0;
    }

    int nextPow2( int n ) {
        --n;
        n |= (n >> 1);
        n |= (n >> 2);
        n |= (n >> 4);
        n |= (n >> 8);
        n |= (n >> 16);

        return n + 1;
    }

    T lerp( T )( T from, T to, T weight ) {
        return from + ( to - from ) * weight;
    }

    T normAbs( T )( T val ) {
        if ( val != 0 ) {
            return val / abs( val );
        }

        return val;
    }

    float degToRad( float angle ) {
        return angle * DEG_TO_RAD;
    }

    float radToDeg( float angle ) {
        return angle * RAD_TO_DEG;
    }

    double perlinNoise( double x, double y = 0.1, double z = 0.1 ) {
        return SPerlinNoise( x, y, z );
    }

    alias sqrt = std.math.sqrt;
    alias frexp = std.math.frexp;
    alias floor = std.math.floor;
    alias round = std.math.round;
    alias ceil = std.math.ceil;
    alias ldexp = std.math.ldexp;
    alias fmod = std.math.fmod;
    alias pow = std.math.pow;
    alias sin = std.math.sin;
    alias cos = std.math.cos;
    alias acos = std.math.acos;
    alias tan = std.math.tan;
    alias tanh = std.math.tanh;
    alias atan = std.math.atan;
    alias atan2 = std.math.atan2;
    alias isNan = std.math.isNaN;
    alias isInfinity = std.math.isInfinity;
    alias max = std.algorithm.comparison.max;
    alias min = std.algorithm.comparison.min;
    alias clamp = std.algorithm.comparison.clamp;

    @( "Random module" )
    {
        private static __gshared Random lseed;

        void randSeed( uint val ) {
            lseed = Random( val );
        }

        float randf( float from = 0.0f, float to = 1.0f ) {
            return uniform( from, to, lseed );
        }

        T rand( T )( T from, T to ) {
            return uniform( from, to );
        }
    }
}

alias Math = SMath;
