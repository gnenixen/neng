module engine.framework.scene_tree;

public:
import engine.framework.scene_tree.base;
import engine.framework.scene_tree.n2d;

static struct GSceneTree {
static:
    void initialize() {
        scene_tree_register_base();
        scene_tree_register_n2d();

        log.info( "Scene tree initialized" );
    }
}
