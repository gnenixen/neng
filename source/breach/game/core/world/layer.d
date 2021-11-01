module game.core.world.layer;

import engine.core.object;

import engine.framework.scene_tree;
import engine.framework.render.r2d;

class CLayer : CObject {
    mixin( TRegisterClass!CLayer );
protected:
    CSceneTree tree;
    CSceneTreeRender treeRender;

public:
    this() {
        tree = newObject!CSceneTree();
        treeRender = newObject!CSceneTreeRender();
    }

    ~this() {
        destroyObject( tree );
        destroyObject( treeRender );
    }

    void render( CR2D_View view ) {
        treeRender.preRender();
        tree.message( ENodeMessageType.RENDER, "", var( treeRender ) );
        
        treeRender.render( view );
    }

    void clear() {}
}
