module game.core.world.layers.render;

import engine.framework.scene_tree;

import game.core.world.layer;

class CTileMapRenderLayer : CLayer {
    mixin( TRegisterClass!CTileMapRenderLayer );
public:
    CN2DTileMap tilemap;
    alias tilemap this;

public:
    this() {
        super();

        tilemap = newObject!CN2DTileMap( 64, rs!"res/heh2.png" );

        tree.root = tilemap;
    }

    ~this() {
        destroyObject( tilemap );
    }
}
