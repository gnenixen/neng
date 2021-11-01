module engine.framework.scene_tree.n2d;

public:
import engine.framework.scene_tree.n2d.node_2d;
import engine.framework.scene_tree.n2d.camera_2d;
import engine.framework.scene_tree.n2d.spine;
import engine.framework.scene_tree.n2d.sprite;
import engine.framework.scene_tree.n2d.tilemap;

import engine.framework.scene_tree.n2d.physics_body;
import engine.framework.scene_tree.n2d.physics_shape;
import engine.framework.scene_tree.n2d.physics_joint;

void scene_tree_register_n2d() {
    import engine.core.symboldb;

    GSymbolDB.register!CNode2D;
    GSymbolDB.register!CCamera2D;
    GSymbolDB.register!CNodeSpine;
    GSymbolDB.register!CSprite;
    GSymbolDB.register!CCollisionTileMap;

    GSymbolDB.register!CPhysicsBody2D;
    GSymbolDB.register!CDynamicBody2D;
    GSymbolDB.register!CStaticBody2D;
    GSymbolDB.register!CShape2D;
    GSymbolDB.register!CBoxShape2D;
    GSymbolDB.register!CCircleShape2D;
    //GSymbolDB.register!CJoint2D;
    //GSymbolDB.register!CRevoluteJoint2D;
}
