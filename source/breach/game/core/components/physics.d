module game.core.components.physics;

import game.core.base.component;

class CPhysicsComponent : CComponent {
    mixin( TRegisterClass!CPhysicsComponent );
public:
    Signal!( CGameObject ) onCollideBegin;
    Signal!( CGameObject ) onCollideEnd;

    Signal!( CGameObject ) onTriggerEnter;
    Signal!( CGameObject ) onTriggerOut;

public:
    CP2DBody lbody;
    alias lbody this;

private:
    bool bUseCustomHandler = false;
    SVec2F psyncWPos = SVec2F( 0.0f );

public:
    this( EP2DBodyType type = EP2DBodyType.DYNAMIC, bool bUseCustomHandler = false ) {
        super();

        this.bUseCustomHandler = bUseCustomHandler;

        lbody = newObject!CP2DBody( type );

        newChild.connect( &newChildHanlder );
    }

    ~this() {
        destroyObject( lbody );
    }

    override void _begin() {
        object.newChild.connect( &newChildHanlder );
    }

    override void postInit() {
        GPhysics2D.body_connectHandler( lbody.pId, SCallable( rs!"pEventsHandler", id ) );
    }

    override void _ptick( float delta ) {
        SVec2F wpos = object.worldTransform.pos;

        // Somewhere position was updated
        if ( wpos != psyncWPos ) {
            lbody.position = wpos;
        }

        object.transform.pos = psyncWPos;
    }

    override void psync() {
        SVec2F wpos = SVec2F( 0.0f );

        CNode2D par = Cast!CNode2D( object.parent );
        if ( par ) {
            wpos = par.worldTransform.pos;
        }

        object.transform.pos = lbody.position - wpos;

        psyncWPos = object.worldTransform.pos;
    }

    void newChildHanlder( CNode child ) {
        CShape2D shape = Cast!CShape2D( child );

        if ( shape ) {
            lbody.addShape( shape.shape );
        }
    }
    
    void pEventsHandler( EP2DBodyEventType type, VArray args ) {
        CObject cobject = args[0].as!CObject;
        assert( cobject );

        CPhysicsComponent comp = Cast!CPhysicsComponent( cobject );
        if ( !comp ) return;

        CGameObject gobj = comp.object;
        if ( !isValid( gobj ) ) {
            log.warning( "Invalid physics component passed into events handler!" );
            return;
        }

        switch ( type ) {
        case EP2DBodyEventType.COLLIDE_BEGIN:  onCollideBegin.emit( gobj ); break;
        case EP2DBodyEventType.COLLIDE_END:    onCollideEnd.emit( gobj );   break;

        case EP2DBodyEventType.TRIGGER_ENTER:  onTriggerEnter.emit( gobj ); break;
        case EP2DBodyEventType.TRIGGER_OUT:    onTriggerOut.emit( gobj );   break;

        default:
            assert( false );
        }
    }
}

