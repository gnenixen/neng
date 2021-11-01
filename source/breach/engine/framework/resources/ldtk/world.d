module engine.framework.resources.ldtk.world;

import engine.core.object;
import engine.core.math;
import engine.core.containers;
import engine.core.string;
import engine.core.log;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.tileset;
import engine.framework.resources.ldtk.layer_def;
import engine.framework.resources.ldtk.entity_def;
import engine.framework.resources.ldtk._enum;
import engine.framework.resources.ldtk.level;

enum ELDTKDir {
    NONE,
    NORTH,
    EAST,
    SOUTH,
    WEST
}

enum ELDTKWorldLayout {
    FREE,
    GRID_VANIA,
    LINEAR_HORIZONTAL,
    LINEAR_VERTICAL,
}

class CLDTKWorld : CObject {
    mixin( TRegisterClass!CLDTKWorld );
public:
    String filePath;
    SVec2F defaultPivot;
    int defaultCellSize = 0;
    SColorRGBA backgroundColor;

    ELDTKWorldLayout layout = ELDTKWorldLayout.FREE;

    Array!CLDTKTileset tilesets;
    Array!CLDTKLayerDef layersDefs;
    Array!CLDTKEntityDef entitiesDefs;
    Array!CLDTKEnum enums;

    Array!CLDTKLevel levels;

public:
    this( CJSONValue* json ) {
        defaultPivot = SVec2F(
            json.get("defaultPivotX").as!float,
            json.get("defaultPivotY").as!float,
        );
        defaultCellSize = json.get("defaultGridSize").as!int;
        backgroundColor = SColorRGBA( json.get("bgColor").as!int );

        String slayout = json.get("worldLayout").as!String;
        if ( slayout == "Free" ) {
            layout = ELDTKWorldLayout.FREE;
        } else if ( slayout == "GridVania" ) {
            layout = ELDTKWorldLayout.GRID_VANIA;
        } else if ( slayout == "LinearHorizontal" ) {
            layout = ELDTKWorldLayout.LINEAR_HORIZONTAL;
        } else if ( slayout == "LinearVertical" ) {
            layout = ELDTKWorldLayout.LINEAR_VERTICAL;
        }

        enums.free();
        tilesets.free();
        layersDefs.free();
        entitiesDefs.free();
        levels.free();

        CJSONValue* defs = json.get("defs");
        enums.reserve( defs.get("enums").arr.length );
        foreach ( en; defs.get("enums").arr ) {
            enums ~= newObject!CLDTKEnum( en, this );
        }

        tilesets.reserve( defs.get("tilesets").arr.length );
        foreach ( tileset; defs.get("tilesets").arr ) {
            tilesets ~= newObject!CLDTKTileset( tileset, this );
        }

        foreach ( en; enums ) {
            if ( en.tilesetId != -1 ) {
                en.tileset = getTileset( en.tilesetId );
            }
        }

        layersDefs.reserve( defs.get("layers").arr.length );
        foreach ( layerDef; defs.get("layers").arr ) {
            layersDefs ~= newObject!CLDTKLayerDef( layerDef, this );
        }

        entitiesDefs.reserve( defs.get("entities").arr.length );
        foreach ( entityDef; defs.get("entities").arr ) {
            entitiesDefs ~= newObject!CLDTKEntityDef( entityDef, this );
        }
        
        levels.reserve( json.get("levels").arr.length );
        foreach ( i, level; json.get("levels").arr ) {
            levels ~= newObject!CLDTKLevel( level, this );
        }

        foreach ( level; levels ) {
            foreach ( key, value; level.neighboursId ) {
                foreach ( id; value ) {
                    //level.neighbours[key].append( getLevel( id ) );
                }
            }
        }
    }

    CLDTKLayerDef getLayerDef( int id ) {
        foreach ( ld; layersDefs ) {
            if ( ld.uid == id ) {
                return ld;
            }
        }

        log.error( "LayerDef ID \"", id, "\" not found in World \"", filePath, "\"" );
        return null;
    }

    CLDTKTileset getTileset( int id ) {
        foreach ( ts; tilesets ) {
            if ( ts.uid == id ) {
                return ts;
            }
        }

        log.error( "Tileset ID \"", id, "\" not found in World \"", filePath, "\"" );
        return null;
    }

    CLDTKLevel getLevel( String name ) {
        foreach ( level; levels ) {
            if ( level.name == name ) {
                return level;
            }
        }

        log.error( "Level NAME \"", name, "\" not found in World \"", filePath, "\"" );
        return null;

    }

    CLDTKLevel getLevel( int id ) {
        foreach ( level; levels ) {
            if ( level.uid == id ) {
                return level;
            }
        }

        log.error( "Level ID \"", id, "\" not found in World \"", filePath, "\"" );
        return null;
    }

    CLDTKEnum getEnum( int id ) {
        foreach ( en; enums ) {
            if ( en.uid == id ) {
                return en;
            }
        }

        log.error( "Enum ID \"", id, "\" not found in World \"", filePath, "\"" );
        return null;
    }
}
