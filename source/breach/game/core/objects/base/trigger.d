module game.core.objects.base.trigger;

import game.core.base;
import game.core.components;

class CTrigger : CGameObject {
    mixin( TRegisterClass!CTrigger );
protected:
    CPhysicsComponent physics;
    CBoxShape2D shape;

public:
    this( EP2DBodyType mode = EP2DBodyType.STATIC ) {
        physics = newComponent!CPhysicsComponent( mode );

        physics.onTriggerEnter.connect( &onObjectEnter );
        physics.onTriggerOut.connect( &onObjectOut );
    }

    override void postInit() {
        shape = newObject!CBoxShape2D( 10, 10 );
        addChild( shape );

        shape.bTrigger = true;
    }

    void onObjectEnter( CGameObject obj ) {}
    void onObjectOut( CGameObject obj ) {}

    void resize( uint width, uint height ) {
        Cast!CP2DBoxShape( shape.shape ).update( width, height );
    }
}
