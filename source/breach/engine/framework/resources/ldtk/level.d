module engine.framework.resources.ldtk.level;

import engine.core.object;
import engine.core.math;
import engine.core.fs;
import engine.core.containers;

import engine.framework.resources.json;
import engine.framework.resources.ldtk.layer;
import engine.framework.resources.ldtk.fields_container;
import engine.framework.resources.ldtk.world;

class CLDTKLevel : CLDTKFieldsContainer {
    mixin( TRegisterClass!CLDTKLevel );
public:
    CLDTKWorld world;

    String name;
    int uid;
    SVec2I size;
    SVec2I position;
    SColorRGBA bgColor;

    Array!CLDTKLayer layers;
    Dict!( Array!int, ELDTKDir ) neighboursId;
    Dict!( Array!CLDTKLevel, ELDTKDir ) neighbours;

    CJSONValue* json;

private:
    bool bPrepared = false;

public:
    this( CJSONValue* ijson, CLDTKWorld iworld ) {
        json = ijson;

        world = iworld;
        name = json.get("identifier").as!String;
        uid = json.get("identifier").as!int;
        size = SVec2I(
            json.get("pxWid").as!int,
            json.get("pxHei").as!int
        );
        position = SVec2I(
            json.get("worldX").as!int,
            json.get("worldY").as!int
        );
        bgColor = getColorFromHex( json.get("__bgColor").as!String );

        neighboursId.set( ELDTKDir.NORTH, Array!int() );
        neighboursId.set( ELDTKDir.EAST, Array!int() );
        neighboursId.set( ELDTKDir.SOUTH, Array!int() );
        neighboursId.set( ELDTKDir.WEST, Array!int() );

        neighbours.set( ELDTKDir.NORTH, Array!CLDTKLevel() );
        neighbours.set( ELDTKDir.EAST, Array!CLDTKLevel() );
        neighbours.set( ELDTKDir.SOUTH, Array!CLDTKLevel() );
        neighbours.set( ELDTKDir.WEST, Array!CLDTKLevel() );

        foreach ( neighbour; json.get("__neighbours").arr ) {
            String dir = neighbour.get("dir").as!String;
            int levelUid = neighbour.get("levelUid").as!int;

            if ( dir == "n" ) {
                neighboursId[ELDTKDir.NORTH].append( levelUid );
            } else if ( dir == "e" ) {
                neighboursId[ELDTKDir.EAST].append( levelUid );
            } else if ( dir == "s" ) {
                neighboursId[ELDTKDir.SOUTH].append( levelUid );
            } else {
                neighboursId[ELDTKDir.WEST].append( levelUid );
            }
        }

        //prepare();
    }

    void prepare() {
        if ( bPrepared ) return;

        CJSONValue* jl;
        if ( !json.get("externalRelPath").isNull ) {
            jl = CJSONParser.parse( GFileSystem.fileReadAsString( String( "res/", json.get("externalRelPath").as!String ) ) ).root();
        } else {
            jl = json;
        }

        layers.reserve( jl.get("layerInstances").arr.length );
        foreach ( level; jl.get("layerInstances").arr ) {
            layers ~= newObject!CLDTKLayer( level, world, this );
        }

        bPrepared = true;
    }

    SVec2I getSize() {
        if ( !layers.length ) return SVec2I( 0 );

        return layers[0].size;
    }
}
