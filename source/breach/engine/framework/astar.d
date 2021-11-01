module engine.framework.astar;

import engine.core.object;
import engine.core.math;
import engine.core.containers;
import engine.core.utils.ustruct;

struct TAStarConnectionsWithWeights {
    mixin( TRegisterStruct!TAStarConnectionsWithWeights );
public:
    Dict!( double, SVec2I ) data;
    alias data this;
}

class CAStar : CObject {
    mixin( TRegisterClass!CAStar );
protected:
    // Original point as keys, all connected points
    // with weight as value
    Dict!(
        TAStarConnectionsWithWeights,
        SVec2I
    ) lpoints;

public:
     Array!SVec2I points() {
        return lpoints.keys;
    }

    void addPoint( SVec2I pos ) {
        if ( !lpoints.has( pos ) ) {
            lpoints.set( pos, TAStarConnectionsWithWeights() );
        }
    }

    void connectPoints( SVec2I from, SVec2I to, double weight = 1.0f, bool bBiConnect = true ) {
        if ( !lpoints.has( from ) || !lpoints.has( to ) ) return;

        lpoints[from].set( to, weight );

        if ( bBiConnect ) {
            lpoints[to].set( from, weight );
        }
    }

    SVec2I getClosestPoint( SVec2F pos ) {
        SVec2I point;
        real closestDist = 1e20;

        foreach ( pnt; points() ) {
            real d = pos.distanceSqrt( pnt.tov!float );
            if ( d < closestDist ) {
                closestDist = d;
                point = pnt;
            }
        }

        return point;
    }

    double heuristic( SVec2I a, SVec2I b ) {
        return Math.abs( a.x - b.x ) + Math.abs( a.y - b.y );
    }

    Array!SVec2I search( SVec2I start, SVec2I end ) {
        SPriorityQueue!( SVec2I, double ) frontier;
        Dict!( SVec2I, SVec2I ) cameFrom;
        Dict!( double, SVec2I ) costSoFar;

        frontier.push( start, 0 );
        cameFrom.set( start, start );
        costSoFar.set( start, 0 );

        while ( !frontier.empty() ) {
            SVec2I current = frontier.pop();

            if ( current == end ) break;

            foreach ( next, priority; neighbors( current ) ) {
                double newCost = costSoFar.get( current ) + priority + 1;

                if ( !costSoFar.has( next ) || newCost < costSoFar.get( next ) ) {
                    costSoFar.set( next, newCost );
                    cameFrom.set( next, current );
                    frontier.push( next, newCost + heuristic( next, end ) );
                }
            }
        }

        if ( cameFrom.length == 0 ) return Array!SVec2I();

        Array!SVec2I res;
        SVec2I current = end;
        while ( current != start ) {
            if ( current == SVec2I( 0 ) ) {
                break;
            }
            res ~= current;
            current = cameFrom.get( current );
        }
        res ~= start;

        Array!SVec2I _res;
        foreach_reverse ( i, elem; res ) {
            _res ~= elem;
        }

        return _res;
    }

    TAStarConnectionsWithWeights neighbors( SVec2I pos ) {
        return lpoints.get( pos, TAStarConnectionsWithWeights() );
    }

    void clear() {
        lpoints.free();
    }
}
