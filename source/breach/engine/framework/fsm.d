module engine.framework.fsm;

import engine.core.containers;
import engine.core.object;
import engine.core.log;
import engine.core.utils.ustruct;

abstract class AState : CObject {
    mixin( TRegisterClass!AState );
public:
    CFSM fsm;
    String name;

public:
    this() {}

    bool canEnter() { return true; }
    bool canLeave() { return true; }

    void enter() {}
    void leave() {}

    void transition( String name ) {
        assert( fsm );

        fsm.transition( name );
    }
}

private {
    struct SFSMTransition {
        mixin( TRegisterStruct!SFSMTransition );
    public:
        String from;
        Array!String to;
    }
}

class CFSM : CObject {
    mixin( TRegisterClass!CFSM );
protected:
    Array!AState lstates;
    AState lcurrent;

public:
    ~this() {
        lstates.free( ( state ) { destroyObject( state ); } );
    }

    T current( T )()
    if ( is( T : AState ) ) {
        return Cast!T( lcurrent );
    }

    T addState( T )( String name )
    if ( is( T : AState ) ) {
        T state = NewObject!T();
        state.name = name;
        state.fsm = this;

        lstates ~= state;

        return state;
    }

    AState getState( String name ) {
        int idx = lstates.find!"a == b.name"( name );
        if ( idx < 0 ) {
            return null;
        }

        return lstates[idx];
    }

    bool isTransitionAvaible( String name ) {
        AState state = getState( name );
        if ( !state ) return false;

        return lcurrent.canLeave() && state.canEnter();
    }

    bool transition( String to ) {
        if ( lcurrent is null ) {
            lcurrent = getState( to );
            lcurrent.enter();
            return true;
        }

        if ( !isTransitionAvaible( to ) ) {
            log.warning( "Invalid transition from ", lcurrent.name !is null ? lcurrent.name : "<null>", " to ", to );
            return false;
        }

        AState from = lcurrent;
        AState _to = getState( to );

        if ( from == _to ) return true;

        if ( !_to ) {
            log.error( "Invalid to state name: ", to );
            return false;
        }

        if ( from ) {
            from.leave();
        }

        lcurrent = _to;
        _to.enter();

        return true;
    }
}
