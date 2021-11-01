module engine.framework.resources.ldtk.layer;

import engine.core.object;
import engine.core.containers;
import engine.core.math;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.layer_def;
import engine.framework.resources.ldtk.level;
import engine.framework.resources.ldtk.entity;
import engine.framework.resources.ldtk.world;

struct SLDTKTile {
    int coordId = 0;
    int tileId = 0;
    SVec2I position;
    SVec2I worldPosition;
    SVec2I texturePosition;
    bool bFlipX = false;
    bool bFlipY = false;
}

class CLDTKLayer : CObject {
    mixin( TRegisterClass!CLDTKLayer );
public:
    CLDTKLayerDef definition;

    CLDTKLevel level;

    bool bVisible;
    SVec2I totalOffset;
    float opacity;
    SVec2I gridSize;
    SVec2I size;

    Array!SLDTKTile tiles;
    Array!CLDTKEntity entities;
    Dict!( SLDTKIntGridValue, int ) intgrid;
    Dict!( SLDTKTile, int ) tilesMap;

public:
    this ( CJSONValue* json, CLDTKWorld world, CLDTKLevel ilevel ) {
        level = ilevel;
        definition = world.getLayerDef( json.get("layerDefUid").as!int );
        bVisible = json.get("visible").as!bool;

        size = SVec2I(
            json.get("__cWid").as!int,
            json.get("__cHei").as!int
        );

        String key;
        key = rs!"gridTiles";
        int coordIdIndex = 0;
        if (
            definition.type == ELDTKLayerType.INT_GRID ||
            definition.type == ELDTKLayerType.AUTO_LAYER
        ) {
            key = rs!"autoLayerTiles";
            coordIdIndex = 1;
        }

        tiles.reserve( json.get(key).arr.length );
        foreach ( tile; json.get(key).arr ) {
            SLDTKTile ntile;
            ntile.coordId = tile.get("d").arr[coordIdIndex].as!int;
            ntile.position.x = tile.get("px").arr[0].as!int;
            ntile.position.y = tile.get("px").arr[1].as!int;

            ntile.tileId = tile.get("t").as!int;
            ntile.texturePosition.x = tile.get("src").get( 0 ).as!int;
            ntile.texturePosition.y = tile.get("src").get( 1 ).as!int;

            uint flip = cast( uint )tile.get( "f" ).as!int;
            ntile.bFlipX = flip & 1u;
            ntile.bFlipY = (flip >> 1u) & 1u;

            tiles ~= ntile;
        }

        foreach ( tile; tiles ) {
            tilesMap[tile.coordId] = tile;
        }

        int coordId = 0;
        foreach ( val; json.get("intGridCsv").arr ) {
            if ( val.as!int != 0 ) {
                intgrid[coordId] = definition.intgridValues[val.as!int - 1];
            }

            coordId++;
        }
    }
}
