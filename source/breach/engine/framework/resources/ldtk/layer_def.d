module engine.framework.resources.ldtk.layer_def;

import engine.core.object;
import engine.core.containers;
import engine.core.math;
import engine.core.utils.ustruct;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.tileset;
import engine.framework.resources.ldtk.world;

enum ELDTKLayerType {
    INT_GRID,
    ENTITIES,
    TILES,
    AUTO_LAYER,
}

struct SLDTKIntGridValue {
    mixin( TRegisterStruct!SLDTKIntGridValue );
public:
    int value;
    String name;
    SColorRGBA color;
}

class CLDTKLayerDef : CObject {
    mixin( TRegisterClass!CLDTKLayerDef );
public:
    ELDTKLayerType type;
    String name;
    int uid;
    int cellSize;
    float opacity;
    SVec2I offset;
    SVec2F tilePivot;
    CLDTKTileset tileset;
    Array!SLDTKIntGridValue intgridValues;

public:
    this( CJSONValue* json, CLDTKWorld world ) {
        type = getLayerTypeFromString( json.get("type").as!String );
        name = json.get("identifier").as!String;
        uid = json.get("uid").as!int;
        cellSize = json.get("gridSize").as!int;
        opacity = json.get("displayOpacity").as!float;
        offset = SVec2I(
            json.get("pxOffsetX").as!int,
            json.get("pxOffsetY").as!int
        );
        tilePivot = SVec2F(
            json.get("tilePivotX").as!float,
            json.get("tilePivotY").as!float
        );

        if ( !json.get("tilesetDefUid").isNull ) {
            tileset = world.getTileset( json.get("tilesetDefUid").as!int );
        } else if ( !json.get("autoTilesetDefUid").isNull ) {
            tileset = world.getTileset( json.get("autoTilesetDefUid").as!int );
        }

        int i = 0;
        foreach ( _val; json.get("intGridValues").arr ) {
            CJSONValue val = *_val;

            intgridValues ~= SLDTKIntGridValue(
                i++,
                val.get("identifier").isNull ? String( "" ) : val.get("identifier").as!String,
                getColorFromHex( val.get("color").as!String )
            );
        }
    }

private:
    ELDTKLayerType getLayerTypeFromString( String str ) {
        if ( str == "IntGrid" ) {
            return ELDTKLayerType.INT_GRID;
        } else if ( str == "Entities" ) {
            return ELDTKLayerType.ENTITIES;
        } else if ( str == "Tiles" ) {
            return ELDTKLayerType.TILES;
        } else if ( str == "AutoLayer" ) {
            return ELDTKLayerType.AUTO_LAYER;
        }

        return ELDTKLayerType.TILES;
    }
}
