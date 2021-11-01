module engine.framework.resources.ldtk.entity_def;

import engine.core.object;
import engine.core.containers;
import engine.core.math;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.tileset;
import engine.framework.resources.ldtk.world;

class CLDTKEntityDef : CObject {
    mixin( TRegisterClass!CLDTKEntityDef );
public:
    String name;
    int uid;
    SVec2I size;
    SColorRGBA color;
    SVec2F pivot;
    CLDTKTileset tileset;
    int tileId;
    Array!String tags;

    this( CJSONValue* json, CLDTKWorld world ) {
        name = json.get("identifier").as!String;
        uid = json.get("uid").as!int;
        size = SVec2I(
            json.get("width").as!int,
            json.get("height").as!int
        );
        color = getColorFromHex( json.get("color").as!String );
    }
}
