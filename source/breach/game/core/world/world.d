module game.core.world.world;

import engine.core.object;
import engine.core.math;
import engine.core.fs;

import engine.framework.scene_tree;
import engine.framework.tilemap;
import engine.framework.resources;

class CGameWorldVirtualMap : CObject {
    mixin( TRegisterClass!CGameWorldVirtualMap );
public:
    CLDTKWorld world;

    Dict!( CLDTKLevel, SAABB ) vlevels;

    void load( CLDTKWorld iworld ) {
        world = iworld;
        vlevels.free();

        foreach ( level; world.levels ) {
            SVec2I min = (level.position + SVec2I( 0, 0 )) / world.defaultCellSize;
            SVec2I max = (level.position + SVec2I( level.size.x, level.size.y )) / world.defaultCellSize;

            vlevels.set( SAABB( min.tov!float, max.tov!float ), level );
        }
    }

    CLDTKLevel getLevelThatContainsPoint( SVec2F point ) {
        SAABB pnt = SAABB( point, point );

        foreach ( aabb, level; vlevels ) {
            if ( pnt.isIntersection( aabb ) ) {
                return level;
            }
        }

        return null;
    }
}

class CGameWorld : CNode2D {
    mixin( TRegisterClass!CGameWorld );
public:
    Signal!( CLDTKLevel ) onLevelChanged;

public:
    CLDTKWorld world;
    CLDTKLevel currentLevel;
    CCollisionTileMap mcollision;
    CPathFinderMap mpathfinder;
    CGameWorldVirtualMap vmap;

protected:
    //Dict!( CN2DTileMap, String ) mrender;

    CN2DTileMap mrender;

    CJSONParsedData pdata;

public:
    this() {
        mcollision = newObject!CCollisionTileMap();
        mpathfinder = newObject!CPathFinderMap();
        vmap = newObject!CGameWorldVirtualMap();

        mrender = newObject!CN2DTileMap( 64, rs!"res/heh2.png" );

        addChild( mcollision );
        addChild( mrender );
    }

    ~this() {
        destroyObject( mcollision );
        destroyObject( mpathfinder );
        destroyObject( mrender );

        if ( pdata ) {
            destroyObject( pdata );
        }

        if ( world ) {
            destroyObject( world );
        }

        if ( currentLevel ) {
            destroyObject( currentLevel );
        }
    }
    
    bool loadFromFile( String path ) {
        pdata = CJSONParser.parse(
            GFileSystem.fileReadAsString( path )
        );

        if ( !pdata ) {
            log.error( "Not found ldtk world declaration file: ", path );
            return false;
        }

        world = newObject!CLDTKWorld( pdata.root );
        vmap.load( world );
        return true;
    }

    void changeLevel( String name ) {
        if ( currentLevel && currentLevel.name == name ) return;

        clear();

        currentLevel = world.getLevel( name );
        if ( !currentLevel ) return;

        currentLevel.prepare();

        foreach ( layer; currentLevel.layers ) {
            if ( layer.definition.name == "Collision" ) {
                SVec2I lsize = layer.size;
                foreach ( coordId, tile; layer.intgrid ) {
                    if ( tile.name == "walls" ) {
                        SVec2I coord = getCoordinateById( coordId, lsize );

                        mcollision.set( coord.x, coord.y );
                        mpathfinder.set( coord.x, coord.y, 1 );
                    }
                }

                foreach ( tile; layer.tiles ) {
                    mrender.set( tile.position.x / 16, tile.position.y / 16, tile.tileId, SVec2I( tile.bFlipX ? -1 : 1, tile.bFlipY ? -1 : 1 ) );
                }
            }
        }

        mcollision.generateEdges();
        mpathfinder.generateGraph();

        onLevelChanged.emit( currentLevel );
    }

    void clear() {
        mcollision.clear();
        mpathfinder.clear();
        mrender.clear();
    }

protected:
    SVec2I getCoordinateById( int coordId, SVec2I levelSize ) {
        SVec2I ret;

        ret.y = cast( int )Math.floor( coordId / cast( float )levelSize.x );
        ret.x = coordId - ret.y * levelSize.x;

        return ret;
    }
}
