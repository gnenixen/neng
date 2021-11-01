module engine.framework.resources.ldtk._enum;

import engine.core.object;
import engine.core.resource;
import engine.core.string;
import engine.core.math.color;
import engine.core.containers;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.tileset;
import engine.framework.resources.ldtk.world;

class CLDTKEnumValue : CObject {
    mixin( TRegisterClass!CLDTKEnumValue );
public:
    String name;
    int id;
    int tileId;
    SColorRGBA color;
    CLDTKEnum _enum;
}

class CLDTKEnum : CObject {
    mixin( TRegisterClass!CLDTKEnum );
public:
    String name;
    int uid;

    int tilesetId;
    CLDTKTileset tileset;

private:
    Dict!( CLDTKEnumValue, String ) values;

public:
    this( CJSONValue* json, CLDTKWorld world ) {
        name = json.get("identifier").as!String;
        uid = json.get("uid").as!int;
        tilesetId = json.get("iconTilesetUid").isNull ? -1 : json.get("iconTilesetUid").as!int;
        tileset = null;

        int id = 0;
        foreach ( _value; json.get("values").arr ) {
            CJSONValue value = *_value;

            CLDTKEnumValue val = newObject!CLDTKEnumValue();
            val.name = value.get("id").as!String;
            val.id = id++;
            val.tileId = value.get("tileId").isNull ? -1 : value.get("tileId").as!int;
            val.color = SColorRGBA( value.get("color").as!int );
            val._enum = this;

            values.set( value.get("id").as!String, val );
        }
    }
}
