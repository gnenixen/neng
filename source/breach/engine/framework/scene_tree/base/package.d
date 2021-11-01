module engine.framework.scene_tree.base;

public:
import engine.framework.scene_tree.base.node;
import engine.framework.scene_tree.base.tree;
import engine.framework.scene_tree.base.render;
import engine.framework.scene_tree.base.main_loop;

void scene_tree_register_base() {
    import engine.core.symboldb;

    GSymbolDB.register!CNode;
    GSymbolDB.register!CSceneTree;
    GSymbolDB.register!CSceneTreeRender;
    GSymbolDB.register!CSceneTreeRenderCamera;
}
