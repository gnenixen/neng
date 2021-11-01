module engine.core.math.transform;

public import engine.core.math.vec;

struct STransform2D {
    SVec2F pos = SVec2F( 0.0f, 0.0f );
    SVec2F size = SVec2F( 1.0f, 1.0f );
    float angle = 0.0f;

    STransform to3D() {
        return STransform( SVec3F( pos.x, pos.y, 0.0f ), SVec3F( size.x, size.y, 0.0f ) );
    }
}

struct STransform {
    SVec3F pos = SVec3F( 0.0f, 0.0f, 0.0f );
    SVec3F size = SVec3F( 1.0f, 1.0f, 1.0f );

    STransform2D to2D() {
        return STransform2D( SVec2F( pos.x, pos.y ), SVec2F( size.x, size.y ), 0 );
    }
}
