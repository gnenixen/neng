module game.core.base.component;

public:
import engine.core.utils.typeinfo;
import engine.core.input;

import engine.framework.scene_tree;

import game.core.base._object;

class CComponent : CNode2D {
    mixin( TRegisterClass!CComponent );
public:
    CGameObject object = null;
    bool bActive = true;

public:
    void setup( CGameObject obj ) {
        object = obj;
    }

    void _begin() {}

    void _ptick( float delta ) {}
    void _tick( float delta ) {}
    void _input( CInputAction action ) {}

    override void* castImpl( TypeInfo typeinfo ) {
        TypeInfo gobjti = typeid( CGameObject );
        if ( isBaseClassTypeInfoFor( typeinfo, gobjti ) ) {
            return cast( void* )object;
        }

        return null;
    }
}
