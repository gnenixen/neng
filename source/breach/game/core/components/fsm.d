module game.core.components.fsm;

public:
import engine.framework.input;
import engine.framework.fsm;

import game.core.base.component;

class CState : AState {
    mixin( TRegisterClass!CState );
public:
    CFSMComponent owner;

public:
    this() { super(); }

    void ptick( float delta ) {}
    void tick( float delta ) {}
    void input( CInputAction action ) {}
}

class CFSMComponent : CComponent {
    mixin( TRegisterClass!CFSMComponent );
public:
    CFSM fsm;

public:
    this() {
        fsm = NewObject!CFSM;
    }

    ~this() {
        destroyObject( fsm );
    }

    T addState( T )( String name )
    if ( is( T : CState ) ) {
        T state = fsm.addState!T( name );
        state.owner = this;

        return state;
    }

    CState current() { return fsm.current!CState; }
    void transition( String name ) { fsm.transition( name ); }

    override void _ptick( float delta ) {
        CState curr = current();

        if ( curr ) curr.ptick( delta );
    }

    override void _tick( float delta ) {
        CState curr = current();

        if ( curr ) curr.tick( delta );
    }

    override void _input( CInputAction action ) {
        CState curr = current();

        if ( curr ) curr.input( action );
    }
}
