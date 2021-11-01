module engine.modules.physics_2d.basic;

import engine.core.object;

import engine.modules.physics_2d.physics_2d;

class CP2DObject : CObject {
    mixin( TRegisterClass!CP2DObject );
public:
    ID pId = ID_INVALID;

public:
    ~this() {
        GPhysics2D.destroy( pId );
    }
}
