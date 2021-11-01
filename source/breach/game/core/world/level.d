module game.core.world.level;

import engine.core.object;
import engine.core.containers;
import engine.core.signal;

import engine.framework.render.r2d;
import engine.framework.resources.ldtk;

import game.core.base;
import game.core.objects;
import game.core.world.layer;
import game.core.world.layers;
import game.core.world.world;

class CLevel : CObject {
    mixin( TRegisterClass!CLevel );
public:
    Signal!( CChangeLevelTrigger, CGameObject, String ) onGameObjectEnterChangeLevelTrigger;

public:
    Array!CLayer layers;

    CCollisionLayer mcollision;
    CPathFinderMap mpathfinder;

    Array!CChangeLevelTrigger changeLevelTriggers;

private:
    CLDTKLevel data;
    CGameWorld world;

public:
    this( CGameWorld world ) {
        this.world = world;

        mcollision = newObject!CCollisionLayer();
        mpathfinder = newObject!CPathFinderMap();

        layers ~= mcollision;
    }

    void render( CR2D_View view ) {
        foreach ( layer; layers ) {
            layer.render( view );
        }
    }

    void load( CLDTKLevel ldtk ) {
        if ( data == ldtk ) return;

        clear();

        data = ldtk;

        foreach ( layer; ldtk.layers ) {
            SVec2I lsize = layer.size;

            if ( layer.definition.name == "Collision" ) {
                foreach ( coordId, tile; layer.intgrid ) {
                    SVec2I coord = getCoordinateById( coordId, lsize );

                    mcollision.set( coord.x, coord.y );
                    mpathfinder.set( coord.x, coord.y, 1 );
                }
            }

            if ( layer.tiles.length ) {
                CTileMapRenderLayer rlayer = newObject!CTileMapRenderLayer();

                foreach ( tile; layer.tiles ) {
                    rlayer.set(
                        tile.position.x / 16,
                        tile.position.y / 16,
                        tile.tileId,
                        SVec2I(
                            tile.bFlipX ? -1 : 1,
                            tile.bFlipY ? -1 : 1
                        )
                    );
                }

                layers ~= rlayer;
            }
        }

        mpathfinder.generateGraph();

        spawnChangeLevelTriggers();
    }

    void clear() {
        mcollision.clear();
        mpathfinder.clear();

        foreach ( layer; layers ) {
            layer.clear();
        }
    }

protected:
    SVec2I getCoordinateById( int coordId, SVec2I levelSize ) {
        SVec2I ret;

        ret.y = cast( int )Math.floor( coordId / cast( float )levelSize.x );
        ret.x = coordId - ret.y * levelSize.x;

        return ret;
    }

    void spawnChangeLevelTriggers() {
        CLDTKLevel level = data;

        SVec2I position = level.position / world.world.defaultCellSize;
        SVec2I size = level.size / world.world.defaultCellSize;

        SVec2I vmappos( SVec2I pos, ELDTKDir dir ) {
            SVec2I outPoint;

            switch ( dir ) {
            case ELDTKDir.NORTH:
                outPoint = SVec2I( pos.x + position.x, position.y - 1 );
                break;
            case ELDTKDir.SOUTH:
                outPoint = SVec2I( pos.x + position.x, position.y + size.y + 1 );
                break;
            case ELDTKDir.WEST:
                outPoint = SVec2I( position.x - 1, pos.y + position.y );
                break;
            case ELDTKDir.EAST:
                outPoint = SVec2I( position.x + size.x + 1, pos.y + position.y );
                break;

            default:
                assert( false );
            }

            return outPoint;
        }

        CLDTKLevel getNeighbour( SVec2I pos, ELDTKDir dir ) {
            return world.vmap.getLevelThatContainsPoint( vmappos( pos, dir ).tov!float );
        }

        bool isTransitionPoint( SVec2I pos, ELDTKDir dir ) {
            CLDTKLevel neighbour = getNeighbour( pos, dir );
            int tileId = world.mcollision.get( pos.x, pos.y );

            return neighbour !is null && tileId == -1;
        }

        void addChangeLevelTrigger( SVec2F position, SVec2I size, ELDTKDir dir, String levelName ) {
            CChangeLevelTrigger trigger = newObject!CChangeLevelTrigger( dir, levelName );
            changeLevelTriggers ~= trigger;

            trigger.onGameObjectEnter.connect( &onObjectEnterChangeLevelTrigger );

            trigger.resize( size.x * 32, size.y * 32 );
            trigger.transform.pos = cast( SVec2F )( position * 64 + 32 );

            //tree.root.addChild( trigger );
        }

        for ( int i = 0; i < size.x; i++ ) {
            ELDTKDir dir = ELDTKDir.NORTH;
            SVec2I point = SVec2I( i, 0 );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( i, 0 );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( length / 2.0f - 0.5f, -1 ),
                    SVec2I( length, 1 ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.x; i++ ) {
            ELDTKDir dir = ELDTKDir.SOUTH;
            SVec2I point = SVec2I( i, size.y - 1 );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( i, size.y - 1 );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( length / 2.0f - 0.5f, 1 ),
                    SVec2I( length, 1 ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.y; i++ ) {
            ELDTKDir dir = ELDTKDir.WEST;
            SVec2I point = SVec2I( 0, i );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( 0, i );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( -1, length / 2.0f - 0.5f ),
                    SVec2I( 1, length ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.y; i++ ) {
            ELDTKDir dir = ELDTKDir.EAST;
            SVec2I point = SVec2I( size.x - 1, i );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( size.x - 1, i );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( 1, length / 2.0f - 0.5f ),
                    SVec2I( 1, length ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }
    }

    void onObjectEnterChangeLevelTrigger( CChangeLevelTrigger trigger, CGameObject obj, String levelName ) {
        onGameObjectEnterChangeLevelTrigger.emit( trigger, obj, levelName );
    }
}

