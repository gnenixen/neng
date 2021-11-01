module engine.core.math.matrix;

import std.math,
    std.typetuple,
    std.traits,
    std.string,
    std.typecons,
    std.conv,
    std.meta;

import engine.core.math.vec;
import engine.core.math.functions;

template TupleRange( int from, int to )
if ( from <= to ) {
    static if ( from >= to ) {
        alias TupleRange = TypeTuple!();
    } else {
        alias TupleRange = TypeTuple!( from, TupleRange!( from + 1, to ) );
    }
}

template isMatrixInstantiation( U ) {
    private static void isMatrix( T, int R, int C )( SMatrix!( T, R, C ) x ) {}

    enum bool isMatrixInstantiation = is( typeof( isMatrix( U.init ) ) );
}

private {
    template isAssignable( T ) {
        enum bool isAssignable = std.traits.isAssignable!( SMatrix, T );
    }
}

/**
    Generic non-resizable matrix
    Params:
        T - type of elemtns
        rows - number of rows
        columns - number of columns
*/
struct SMatrix( T, int T_ROWS_NUM, int T_COLUMNS_NUM )
if ( T_ROWS_NUM >= 1 && T_COLUMNS_NUM >= 1 ) {
public:
    enum ROWS_NUM = T_ROWS_NUM;
    enum COLUMNS_NUM = T_COLUMNS_NUM;
    enum ELEMS_COUNT = T_ROWS_NUM * T_COLUMNS_NUM;
    enum bool isSquared = ( T_ROWS_NUM == T_COLUMNS_NUM );

    template isTAssignable( U ) {
        enum bool isTAssignable = std.traits.isAssignable!( T, U );
    }

public:
    alias _T = T;
    
    alias SVec!( T, T_COLUMNS_NUM ) TRow;
    alias SVec!( T, T_ROWS_NUM ) TColumn;

    union {
        T[ELEMS_COUNT] data;
        T[T_COLUMNS_NUM][T_ROWS_NUM] matrix;
    }

    alias matrix this;

    this( U... )( U values ) {
        static if ( ( U.length == ELEMS_COUNT ) && allSatisfy!( isTAssignable, U ) ) {
            
            foreach ( int i, x; values ) {
                data[i] = x;
            }

        } else static if ( ( U.length == 1 ) && ( isAssignable!( U[0] ) ) && ( !is( U[0] : SMatrix ) ) ) {
            
            opAssign!( U[0] )( values );

        } else {
            
            static assert( false, "Cannot create a matrix from given arguments" );
        
        }
    }

    ref SMatrix opAssign( U : T )( U x ) {
        for ( int i = 0; i < ELEMS_COUNT; i++ ) {
            data[i] = x;
        }

        return this;
    }

    ref SMatrix opAssign( U : SMatrix )( U x ) {
        for ( int i = 0; i < ELEMS_COUNT; i++ ) {
            data[i] = x.data[i];
        }

        return this;
    }

    auto opBinary( string op, U )( U x ) const
    if ( isMatrixInstantiation!U && ( U.ROWS_NUM == COLUMNS_NUM ) && ( op == "*" ) ) {
        SMatrix!( T, ROWS_NUM, COLUMNS_NUM ) res = void;
        
        for ( int i = 0; i < ROWS_NUM; i++ ) {
            for ( int j = 0; j < COLUMNS_NUM; j++ ) {
                T sum = 0;
            
                for ( int k = 0; k < COLUMNS_NUM; k++ ) {
                    sum += matrix[i][k] * x[k][j];
                }

                res[i][j] = sum;
            }
        }

        return res;
    }

    TColumn opBinary( string op )( TRow x ) const
    if ( op == "*" ) {
        TColumn res = void;
        
        for ( int i = 0; i < ROWS_NUM; i++ ) {
            T sum = 0;
        
            for ( int j = 0; j < COLUMNS_NUM; j++ ) {
                sum += matrix[i][j] * x.data[j];
            }

            res.data[i] = sum;
        }

        return res;
    }

    @property
    auto ptr() const {
        return matrix[0].ptr;
    }

    void clear( T value ) {
        foreach( r; TupleRange!( 0, ROWS_NUM ) ) {
            foreach ( c; TupleRange!( 0, COLUMNS_NUM ) ) {
                matrix[r][c] = value;
            }
        }
    }

    /**
        Convert elements to string
    */
    string toString() const nothrow {
        try {
            return format( "%s", matrix );
        } catch ( Exception ex ) {
            assert( false );
        }
    }

    /**
        Construct an identityt matrix
        Note: the identity matrix, while only meaningful for square matrices,
        is also defined for non-square ones.
    */
    @nogc
    static SMatrix identity() pure nothrow {
        SMatrix ret = void;
        for ( int i = 0; i < ROWS_NUM; i++ ) {
            for ( int j = 0; j < COLUMNS_NUM; j++ ) {
                ret.matrix[i][j] = ( i == j ) ? 1 : 0;
            }
        }

        return ret;
    }

    static if ( isSquared && ( ROWS_NUM == 3 || ROWS_NUM == 4 ) ) {
        @nogc
        static SMatrix rotatedAxis( int i, int j )( float angle ) pure nothrow {
            SMatrix res = identity();
            const float cosa = cos( angle );
            const float sina = sin( angle );

            res.matrix[i][i] = cast( T )cosa;
            res.matrix[i][j] = cast( T )-sina;
            res.matrix[j][i] = cast( T )sina;
            res.matrix[j][j] = cast( T )cosa;

            return res;
        }

        //Rotated along X axis
        alias rotatedAxis!( 1, 2 ) rotatedX;

        //Rotated along Y axis
        alias rotatedAxis!( 2, 0 ) rotatedY;

        //Rotated along Z axis
        alias rotatedAxis!( 1, 0 ) rotatedZ;

        @nogc
        SMatrix rotateAxis( int i, int j )( float angle ) pure nothrow {
            SMatrix res = rotatedAxis!( i, j )( angle );
            this = res * this;
            return this;
        }

        //Rotate along X axis
        alias rotateAxis!( 1, 2 ) rotateX;

        //Rotate along Y axis
        alias rotateAxis!( 2, 0 ) rotateY;

        //Rotate along Z axis
        alias rotateAxis!( 1, 0 ) rotateZ;

        @nogc
        static SMatrix rotate( float iAngle, T x, T y, T z ) pure nothrow {
            SMatrix ret = void;
            
            float angle = iAngle * ( PI / 180 );
            const float cosa = Math.cos( angle );
            const float sina = Math.sin( angle );
            const oneMinCos = 1 - cosa;

            SVec!( T, 3 ) axis = SVec!( T, 3 )( x, y, z );
            axis.normalize();

            x = axis.x;
            y = axis.y;
            z = axis.z;

            ret.matrix[0][0] = cast( T )( x * x * oneMinCos + cosa );
            ret.matrix[0][1] = cast( T )( x * y * oneMinCos - z * sina );
            ret.matrix[0][2] = cast( T )( x * z * oneMinCos + y * sina );

            ret.matrix[1][0] = cast( T )( y * x * oneMinCos + z * sina );
            ret.matrix[1][1] = cast( T )( y * y * oneMinCos + cosa );
            ret.matrix[1][2] = cast( T )( y * z * oneMinCos - x * sina );

            ret.matrix[2][0] = cast( T )( z * x * oneMinCos - y * sina );
            ret.matrix[2][1] = cast( T )( z * y * oneMinCos + x * sina );
            ret.matrix[2][2] = cast( T )( z * z * oneMinCos + cosa );

            return ret;
        }

        SMatrix translated( T x, T y, T z ) {
            SMatrix ret = identity();

            ret.matrix[0][COLUMNS_NUM - 1] = x;
            ret.matrix[1][COLUMNS_NUM - 1] = y;
            ret.matrix[2][COLUMNS_NUM - 1] = z;

            return ret;
        }

        SMatrix translate( T x, T y, T z ) {
            this = translated( x, y, z ) * this;
            return this;
        }

        static SMatrix scaling( T x, T y, T z ) {
            SMatrix ret = SMatrix.identity();

            ret[0][0] = x;
            ret[1][1] = y;
            ret[2][2] = z;

            return ret;
        }

        SMatrix scale( T x, T y, T z ) {
            this = SMatrix.scaling( x, y, z ) * this;
            return this;
        }
    }

    static if ( isSquared && T_ROWS_NUM > 3 ) {
        static SMatrix ortho( T left, T right, T bottom, T top, T near, T far ) 
        in {
            assert( right - left != 0 );
            assert( top - bottom != 0 );
            assert( far - near != 0 );
        } do {
            SMatrix ret;
            ret.clear( 0 );

            ret[0][0] = 2 / ( right - left );
            ret[0][3] = -( right + left ) / ( right - left );
            ret[1][1] = 2 / ( top - bottom );
            ret[1][3] = -( top + bottom ) / ( top- bottom );
            ret[2][2] = -2 / ( far - near );
            ret[2][3] = -( far + near ) / ( far - near );
            ret[3][3] = 1;

            return ret;
        }

        static SMatrix perspective( T fovInRadiants, T aspect, T znear, T zfar ) {
            T f = cast( T )( 1 / Math.tan( fovInRadiants / 2.0f ) );
            T d = cast( T )( 1 / ( znear - zfar ) );

            return SMatrix(
                f / aspect, 0,  0,                       0,
                0,          f,  0,                       0,
                0,          0,  ( zfar + znear ) * d,    2 * d * zfar * znear,
                0,          0,  -1,                      0
            );
        }
    }
}

template SMat2x2( T ) {
    alias SMatrix!( T, 2, 2 ) SMat2x2;
}

template SMat3x3( T ) {
    alias SMatrix!( T, 3, 3 ) SMat3x3;
}

template SMat4x4( T ) {
    alias SMatrix!( T, 4, 4 ) SMat4x4;
}

alias SMat2 = SMat2x2;
alias SMat3 = SMat3x3;
alias SMat4 = SMat4x4;

alias SMat2F = SMat2!float;
alias SMat2D = SMat2!double;

alias SMat3F = SMat3!float;
alias SMat3D = SMat3!double;

alias SMat4F = SMat4!float;
alias SMat4D = SMat4!double;
