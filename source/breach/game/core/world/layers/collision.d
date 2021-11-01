module game.core.world.layers.collision;

import engine.framework.scene_tree;

import game.core.world.layer;

class CCollisionLayer : CLayer {
    mixin( TRegisterClass!CCollisionLayer );
public:
    CCollisionTileMap tilemap;
    alias tilemap this;

public:
    this() {
        super();

        tilemap = newObject!CCollisionTileMap();

        tree.root = tilemap;
    }

    ~this() {
        destroyObject( tilemap );
    }
}
