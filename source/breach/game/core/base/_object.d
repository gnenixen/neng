module game.core.base._object;

public:
import engine.core.input;

import engine.framework.scene_tree;

import game.core.base.component;

enum {
    COMPONENTS_NODE_NAME = "COMPONENTS",
}

class CGameObject : CNode2D {
    mixin( TRegisterClass!CGameObject );
protected:
    CNode lcomponentsNode = null;
    Array!CComponent lcomponents;

public:
    this() {
        super();

        lcomponentsNode = getNode!CNode2D( String( COMPONENTS_NODE_NAME ) );

        if ( !lcomponentsNode ) {
            lcomponentsNode = NewObject!CNode2D();
            lcomponentsNode.name = String( COMPONENTS_NODE_NAME );
            addChild( lcomponentsNode );
        }

        foreach ( child; lcomponentsNode.lchildren ) {
            CComponent comp = Cast!CComponent( child );
            if ( !comp ) {
                log.warning( "Non component node in components handler!" );
                continue;
            }

            addComponent( comp );
        }
    }

    void _ptick( float delta ) {}
    void _tick( float delta ) {}
    void _input( CInputAction action ) {}

    CComponent addComponent( CComponent comp ) {
        if ( lcomponents.has( comp ) ) {
            log.warning( "Trying to double register one component!" );
            return null;
        }

        comp.setup( this );
        lcomponents ~= comp;

        lcomponentsNode.addChild( comp );

        comp._begin();

        return comp;
    }

    void removeComponent( CComponent comp ) {
        lcomponents.remove( comp );
    }

    T newComponent( T, Args... )( Args args ) {
        T comp = NewObject!T( args );
        addComponent( comp );

        return comp;
    }

    T getComponent( T )()
    if ( is( T : CComponent ) ) {
        foreach ( comp; lcomponents ) {
            T n = Cast!T( comp );
            if ( n ) return n;
        }

        return null;
    }

protected:
    override void ptick( float delta ) {
        foreach ( comp; lcomponents ) {
            if ( IsValid( comp ) && comp.bActive ) {
                comp._ptick( delta );
            }
        }

        _ptick( delta );
    }

    override void tick( float delta ) {
        foreach ( comp; lcomponents ) {
            if ( IsValid( comp ) && comp.bActive ) {
                comp._tick( delta );
            }
        }

        _tick( delta );
    }

    override void input( CInputAction action ) {
        foreach ( comp; lcomponents ) {
            if ( IsValid( comp ) && comp.bActive ) {
                comp._input( action );
            }
        }

        _input( action );
    }
}
