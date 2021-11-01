module engine.framework.scene_tree.n2d.spine;

public import engine.framework.spine;

import engine.framework.scene_tree.n2d.node_2d;

class CNodeSpine : CNode2D {
    mixin( TRegisterClass!CNodeSpine );
public:
    CSpinePlayer lspine;
    alias lspine this;

public:
    this() {
        lspine = newObject!CSpinePlayer();
    }

    ~this() {
        destroyObject( lspine );
    }

protected:
    override void tick( float delta ) {
        lspine.update( delta );
    }

    override void render( CSceneTreeRender renderer ) {
        renderer.registerPrimitive( lspine.primitive );

        STransform2D wtransform = worldTransform();

        lspine.primitive.position = wtransform.pos;
        lspine.primitive.scale = wtransform.size;
        lspine.primitive.angle = wtransform.angle;
    }

public:
    @property {
        void resource( CSpineResource resource ) {
            lspine.resource = resource;
        }

        CSpineResource resource() {
            return lspine.resource;
        }
    }
}
