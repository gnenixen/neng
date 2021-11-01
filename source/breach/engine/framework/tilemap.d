module engine.framework.tilemap;

public:
import engine.core.object;
import engine.core.containers;
import engine.core.math;

import engine.modules.render_device.texture;

import engine.framework.render.r2d;

class CTileMap : CObject {
    mixin( TRegisterClass!CTileMap );
public:
    SVec2I tileSize;
    CTexture texture;
    CR2D_Primitive primitive;

protected:
    Dict!( int, SVec2I ) ltiles;

public:
    this() {
        primitive = newObject!CR2D_Primitive( ERDBufferUpdate.DYNAMIC );
        primitive.setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, 8 * float.sizeof, 2 * float.sizeof ),
            SRDVertexElement( 2, ERDPrimitiveType.FLOAT, 4, 8 * float.sizeof, 4 * float.sizeof )
        ) );
    }

    ~this() {
        destroyObject( primitive );
    }

    Dict!( int, SVec2I ) getUsedCells() {
        Dict!( int, SVec2I ) ret;
        //ret.reserve( ltiles );

        foreach ( k, v; ltiles ) {
            ret.set( k, v );
        }

        return ret;
    }

    void clear() {
        if ( !ltiles.length ) return;

        ltiles.free();

        primitive.reset();
        primitive.rebuild();
    }

    void set( int x, int y, int id, SVec2I flip = SVec2I( 1 ) ) {
        ltiles.set( SVec2I( x, y ), id );

        primitive.texture = texture;
        if ( !texture ) return;

        SVec2F texPadding = SVec2F(
            tileSize.x / cast( float )texture.width,
            tileSize.y / cast( float )texture.height
        );

        SVec2F textureTilesSize = SVec2F(
            texture.width / cast( float )tileSize.x,
            texture.height / cast( float )tileSize.y
        );

        SVec2F texCoord;
        texCoord.y = Math.floor( id / textureTilesSize.x );
        texCoord.x = id - texCoord.y * textureTilesSize.x;

        texCoord *= tileSize.tov!float;
        texCoord += SVec2F( 1.0f, 1.0f );
        //texCoord /= SVec2F( texture.width, texture.height );
        //texCoord *= texPadding;

        uint initSize = cast( uint )primitive.vertices.length / 8;
        SVec2I cellSize = tileSize;

        if ( flip.x == 1 ) {
            primitive.vertices ~= x * tileSize.x + tileSize.x;
        } else {
            primitive.vertices ~= x * cellSize.x;
        }
        
        if ( flip.y == 1 ) {
            primitive.vertices ~= y * tileSize.y;
        } else {
            primitive.vertices ~= y * cellSize.y + cellSize.y;
        }
        primitive.vertices ~= ( texCoord.x + tileSize.x - 2 ) / texture.width;
        primitive.vertices ~= ( texCoord.y ) / texture.height;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;

        if ( flip.x == 1 ) {
            primitive.vertices ~= x * tileSize.x + tileSize.x;
        } else {
            primitive.vertices ~= x * cellSize.x;
        }

        if ( flip.y == 1 ) {
            primitive.vertices ~= y * cellSize.y + cellSize.y;
        } else {
            primitive.vertices ~= y * tileSize.y;
        }
        primitive.vertices ~= ( texCoord.x + tileSize.x - 2 ) / texture.width;
        primitive.vertices ~= ( texCoord.y + tileSize.y - 2 ) / texture.height;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;

        if ( flip.x == 1 ) {
            primitive.vertices ~= x * cellSize.x;
        } else {
            primitive.vertices ~= x * tileSize.x + tileSize.x;
        }

        if ( flip.y == 1 ) {
            primitive.vertices ~= y * cellSize.y + cellSize.y;
        } else {
            primitive.vertices ~= y * tileSize.y;
        }
        primitive.vertices ~= ( texCoord.x ) / texture.width;
        primitive.vertices ~= ( texCoord.y + tileSize.y - 2 ) / texture.height;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;

        if ( flip.x == 1 ) {
            primitive.vertices ~= x * cellSize.x;
        } else {
            primitive.vertices ~= x * tileSize.x + tileSize.x;
        }

        if ( flip.y == 1 ) {
            primitive.vertices ~= y * tileSize.y;
        } else {
            primitive.vertices ~= y * cellSize.y + cellSize.y;
        }
        primitive.vertices ~= ( texCoord.x ) / texture.width;
        primitive.vertices ~= ( texCoord.y ) / texture.height;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;
        primitive.vertices ~= 1.0f;

        primitive.indices ~= initSize + 0;
        primitive.indices ~= initSize + 1;
        primitive.indices ~= initSize + 3;
        primitive.indices ~= initSize + 1;
        primitive.indices ~= initSize + 2;
        primitive.indices ~= initSize + 3;
    }

    int get( int x, int y ) {
        return ltiles.get( SVec2I( x, y ), -1 );
    }
}

