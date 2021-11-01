module game.core.components.spine;

public:
import engine.framework.spine;

import game.core.base.component;

class CSpineComponent : CComponent {
    mixin( TRegisterClass!CSpineComponent );
public:
    CSpinePlayer spine;
    alias spine this;

public:
    this() {
        spine = newObject!CSpinePlayer();
    }
    
    ~this() {
        destroyObject( spine );
    }

    override void _tick( float delta ) {
        spine.update( delta );
    }

    override void render( CSceneTreeRender renderer ) {
        renderer.registerPrimitive( spine.primitive );

        STransform2D wtransform = worldTransform;

        spine.primitive.position = wtransform.pos;
        spine.primitive.scale = wtransform.size;
        spine.primitive.angle = wtransform.angle;
    }
}
