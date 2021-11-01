module engine.framework.resources.ldtk.tileset;

import engine.core.object;
import engine.core.containers;
import engine.core.math;

import engine.framework.resources.json;
import engine.framework.resources.ldtk._enum;
import engine.framework.resources.ldtk.world;

class CLDTKTileset : CObject {
    mixin( TRegisterClass!CLDTKTileset );
public:
    String name;
    int uid;
    String path;
    SVec2I textureSize;
    int tileSize;
    int spacing;
    int padding;
    CLDTKEnum tags;

private:
    //Dict!( String, int ) customData;
    //Dict!( Array!int, String ) tagTilesMap;

public:
    this( CJSONValue* json, CLDTKWorld world ) {
        name = json.get("identifier").as!String;
        uid = json.get("uid").as!int;
        path = json.get("relPath").as!String;
        textureSize = SVec2I( json.get("pxWid").as!int, json.get("pxHei").as!int );
        tileSize = json.get("tileGridSize").as!int;
        spacing = json.get("spacing").as!int;
        padding = json.get("padding").as!int;
        tags = json.get("tagsSourceEnumUid").isNull ? null : world.getEnum( json.get("tagsSourceEnumUid").as!int );
    }

    SVec2I getTileTexturePos( int tileId ) { return SVec2I(); }
    String getTileData( int tileId ) { return String(); }
}
