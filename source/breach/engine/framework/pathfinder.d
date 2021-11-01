module engine.framework.pathfinder;

import engine.framework.tilemap;
import engine.framework.astar;

class CPathFinderMap : CTileMap {
    mixin( TRegisterClass!CPathFinderMap );
public:
    int jumpHeight = 5;
    int jumpDistance = 4;

protected:
    CAStar astar;
    Array!SVec2I lpoints;
    Dict!( SVec2I, SVec2I ) lconnections;

public:
    this() {
        astar = newObject!CAStar();
    }
    
    ~this() {
        destroyObject( astar );
    }

    Array!SVec2I points() {
        return lpoints;
    }

    auto connections() {
        return lconnections;
    }

    void generateGraph() {
        generatePoints();
        generateConnections();
    }

    Array!SVec2I findPath( SVec2F begin, SVec2F end ) {
        Array!SVec2I path;

        SVec2I beginPoint = astar.getClosestPoint( begin );
        SVec2I endPoint = astar.getClosestPoint( end );

        path = astar.search( beginPoint, endPoint );

        return path;
    }

    SVec2I cellType( SVec2I pos, bool bAbove = false ) {
        if ( bAbove ) {
            pos.y += 1; 
        }

        auto cells = getUsedCells();
        if ( cells.has( SVec2I( pos.x, pos.y - 1 ) ) ) {
            return SVec2I( 0 );
        }

        SVec2I res = SVec2I( 0 );

        if ( cells.has( SVec2I( pos.x - 1, pos.y - 1 ) ) ) {
            res.x = 1;
        }
        else if ( !cells.has( SVec2I( pos.x - 1, pos.y ) ) ) {
            res.x = -1;
        }

        if ( cells.has( SVec2I( pos.x + 1, pos.y - 1 ) ) ) {
            res.y = 1;
        }
        else if ( !cells.has( SVec2I( pos.x + 1, pos.y ) ) ) {
            res.y = -1;
        }

        return res;
    }

    override void clear() {
        super.clear();

        astar.clear();
        points.free();
        connections.free();
    }

protected:
    void generatePoints() {
        foreach ( k, v; getUsedCells() ) {
            SVec2I type = cellType( k );

            if ( type == SVec2I( 0 ) ) continue;

            addGraphPoint( k );

            if ( type.x == -1 || type.y == -1 ) {
                SVec2I pos = k;

                if ( type.x == -1 ) {
                    pos.x -= 1;
                }

                if ( type.y == -1 ) {
                    pos.x += 1;
                }

                // For some times declare as constant for 60 block,
                // as maximum height for character "suicide" like
                // jump from corner of the block
                foreach ( i; 0..jumpHeight * 3 ) {
                    if ( get( pos.x, pos.y + i ) != -1 ) {
                        addGraphPoint( SVec2I( pos.x, pos.y + i ) );
                        break;
                    }
                }
            }
        }
    }

    void generateConnections() {
        foreach ( pos; astar.points ) {
            SVec2I closestRight = SVec2I( int.max );
            SVec2I closestLeftDrop = SVec2I( int.max );
            SVec2I closestRightDrop = SVec2I( int.max );
            SVec2I state = cellType( pos, true );

            Array!SVec2I pointsToJoin;
            Array!SVec2I noBiPoints;

            foreach ( newPos; astar.points ) {
                if ( state.y == 0 && newPos.y == pos.y && newPos.x > pos.x ) {
                    if ( newPos.x < closestRight.x ) {
                        closestRight = newPos;
                    }
                }

                if ( state.x == -1 ) {
                    if ( newPos.x == pos.x - 1 && newPos.y > pos.y ) {
                        if ( newPos.y < closestLeftDrop.y ) {
                            closestLeftDrop = newPos;
                        }
                    }

                    if ( newPos.y >= pos.y - jumpHeight && newPos.y <= pos.y &&
                            newPos.x > pos.x - (jumpDistance + 2) && newPos.x < pos.x && cellType( newPos, true ).y == -1 ) {
                        pointsToJoin ~= newPos;
                    }
                }

                if ( state.y == -1 ) {
                    if ( newPos.x == pos.x + 1 && newPos.y > pos.y ) {
                        if ( newPos.y < closestRightDrop.y ) {
                            closestRightDrop = newPos;
                        }
                    }

                    if ( newPos.y >= pos.y - jumpHeight && newPos.y <= pos.y && 
                            newPos.x < pos.x + (jumpDistance + 2) && newPos.x > pos.x && cellType( newPos, true ).x == -1 ) {
                        pointsToJoin ~= newPos;
                    }
                }
            }

            if ( closestRight != SVec2I( int.max ) ) {
                pointsToJoin ~= closestRight;
            }

            if ( closestLeftDrop != SVec2I( int.max ) ) {
                float diffX = Math.max( closestLeftDrop.x, pos.x ) - Math.min( closestLeftDrop.x, pos.x );
                float diffY = Math.max( closestLeftDrop.y, pos.y ) - Math.min( closestLeftDrop.y, pos.y );

                if ( diffX <= jumpDistance && diffY <= jumpHeight ) {
                    pointsToJoin ~= closestLeftDrop;
                } else {
                    noBiPoints ~= closestLeftDrop;
                }
            }

            if ( closestRightDrop != SVec2I( int.max ) ) {
                float diffX = Math.max( closestRightDrop.x, pos.x ) - Math.min( closestRightDrop.x, pos.x );
                float diffY = Math.max( closestRightDrop.y, pos.y ) - Math.min( closestRightDrop.y, pos.y );

                if ( diffX <= jumpDistance && diffY <= jumpHeight ) {
                    pointsToJoin ~= closestRightDrop;
                } else {
                    noBiPoints ~= closestRightDrop;
                }
            }

            foreach ( pnt; pointsToJoin ) {
                astar.connectPoints( pos, pnt );
                //lconnections.set( pos, pnt );
            }

            foreach ( pnt; noBiPoints ) {
                astar.connectPoints( pos, pnt, 2.0f, false );
                //astar.connectPoints( pnt, pos, 3.0f, false );
                //lconnections.set( pos, pnt );
                //lconnections.set( pnt, pos );
            }
        }
    }

    void addGraphPoint( SVec2I point ) {
        point.y -= 1;

        astar.addPoint( point );
        lpoints ~= point;
    }
}
