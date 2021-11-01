module engine.framework.scene_tree.n2d.tilemap;

public:
import engine.core.resource;

import engine.modules.render_device.texture;

import engine.framework.scene_tree.n2d.node_2d;
import engine.framework.scene_tree.n2d.physics_body;
import engine.framework.scene_tree.n2d.physics_shape;

import engine.framework.render;
import engine.framework.tilemap;
import engine.framework.pathfinder;

class CN2DTileMap : CNode2D {
    mixin( TRegisterClass!CTileMap );
public:
    CTileMap tilemap;
    alias tilemap this;

//    Array!CR2D_Sprite sprites;
    //CR2D_SpriteBatcher batcher;

public:
    this( uint size, String path ) {
        tilemap = newObject!CTileMap();
        tilemap.tileSize = SVec2I( size );
        tilemap.texture = GResourceManager.loadStatic!CTexture( path );

        //batcher = newObject!CR2D_SpriteBatcher();
        //batcher.primitive.texture = GResourceManager.load!CTexture( path );
    }

    ~this() {
        destroyObject( tilemap );
        //destroyObject( batcher );
    }

    override void render( CSceneTreeRender render ) {
        //batcher.begin();
        //foreach ( k, v; tilemap.getUsedCells() ) {
            //batcher.render( k.x * tilemap.tileSize.x, k.y * tilemap.tileSize.y );
        //}
        //batcher.end();

        //render.registerPrimitive( batcher.primitive );
        render.registerPrimitive( tilemap.primitive );
    }
}

class CCollisionTileMap : CStaticBody2D {
    mixin( TRegisterClass!CCollisionTileMap );
protected:
    CTileMap ltilemap;
    Array!CBoxShape2D boxes;

    Array!CEdgeShape2D edges;

public:
    this() {
        ltilemap = newObject!CTileMap();
        ltilemap.tileSize = SVec2I( 64 );
    }

    ~this() {
        clear();
    }

    auto getUsedCells() { return ltilemap.getUsedCells(); }

    void generateEdges() {
        void spawnEdge( SVec2I vec0, SVec2I vec3 ) {
            CEdgeShape2D edge = newObject!CEdgeShape2D( vec0.tov!float * ltilemap.tileSize.tov!float, vec3.tov!float * ltilemap.tileSize.tov!float );

            edges ~= edge;

            addChild( edge );
        }

        Dict!( int, SVec2I ) tiles = getUsedCells();
        Array!SVec2I coords = tiles.keys();

        foreach ( tile; coords ) {
            SVec2I left = tile + SVec2I( -1, 0 );
            SVec2I right = tile + SVec2I( 1, 0 );
            SVec2I up = tile + SVec2I( 0, -1 );
            SVec2I down = tile + SVec2I( 0, 1 );

            if ( !coords.has( left ) ) {
                spawnEdge( tile, tile + SVec2I( 0, 1 ) );
            }

            if ( !coords.has( right ) ) {
                spawnEdge( tile + SVec2I( 1, 0 ), tile + SVec2I( 1, 1 ) );
            }

            if ( !coords.has( up ) ) {
                spawnEdge( tile + SVec2I( 0, 0 ), tile + SVec2I( 1, 0 ) );
            }
            
            if ( !coords.has( down ) ) {
                spawnEdge( tile + SVec2I( 0, 1 ), tile + SVec2I( 1, 1 ) );
            }
        }
    }

    void clear() {
        ltilemap.clear();

        foreach ( box; boxes ) {
            destroyObject( box );
        }

        foreach ( edge; edges ) {
            destroyObject( edge );
        }

        boxes.free();
        edges.free();
    }

    void set( int x, int y ) {
        ltilemap.set( x, y, 1 );
        CBoxShape2D box = newObject!CBoxShape2D( ltilemap.tileSize.x / 2 - 1, ltilemap.tileSize.y / 2 - 1 );
        box.transform.pos = SVec2F( x * ltilemap.tileSize.x + ltilemap.tileSize.x / 2, y * ltilemap.tileSize.y + ltilemap.tileSize.y / 2 );

        boxes ~= box;

        addChild( box );
    }

    int get( int x, int y ) {
        return ltilemap.get( x, y );
    }
}
