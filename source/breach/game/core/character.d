module game.core.character;

public:
import game.core.base;
import game.core.components;

enum {
    ANIM_COMP_BASE_SCALE_FACTOR = 0.4,
}

class CBaseCharacter : CGameObject {
    mixin( TRegisterClass!CBaseCharacter );
public:
    bool bLockDirection = false;

    CEffectsComponent effects;
    CPhysicsComponent physics;
    CCombatComponent combat;
    CFSMComponent fsm;
    CHealthCompnent health;
    CStaminaComponent stamina;
    CSpineComponent animation;
    CMovementComponent movement;
    CTimerComponent timer;

protected:
    SVec2I ldirection;

    CBoxShape2D lshBody;
    CBoxShape2D lisOnFloorChecker;

public:
    this() {
        super();

        ldirection = SVec2I( 1, 0 );

        effects = newComponent!CEffectsComponent();
        physics = newComponent!CPhysicsComponent();
        combat = newComponent!CCombatComponent();
        fsm = newComponent!CFSMComponent();
        health = newComponent!CHealthCompnent( 100, 100 );
        stamina = newComponent!CStaminaComponent();
        animation = newComponent!CSpineComponent();
        movement = newComponent!CMovementComponent();
        timer = newComponent!CTimerComponent();

        physics.bFixedRotation = true;

        health.damaged.connect( &onDamaged );
        health.damagedUnderDamageResist.connect( &onDamagedUnderDamageResist );
        health.die.connect( &onDie );

        animation.scale( ANIM_COMP_BASE_SCALE_FACTOR, ANIM_COMP_BASE_SCALE_FACTOR );
        animation.transform.pos.y = 95;
    }

    override void postInit() {
        super.postInit();

        //lshBody = NewObject!CBoxShape2D( 30, 70 );
        //lisOnFloorChecker = NewObject!CBoxShape2D( 30, 10 );

        lshBody = NewObject!CBoxShape2D( 10, 70 );
        lisOnFloorChecker = NewObject!CBoxShape2D( 10, 10 );

        addChild( lshBody );
        addChild( lisOnFloorChecker );

        lshBody.transform.pos.y = 25;

        lisOnFloorChecker.bTrigger = true;
        lisOnFloorChecker.transform.pos.y = 95;

        physics.bIsBullet = true;
    }

    override void _ptick( float delta ) {
        if ( !bLockDirection ) {
            SVec2F velocity = physics.linearVelocity;
            ldirection = SVec2I( 
                Math.abs( velocity.x ) > 0.1f ? Math.sign( velocity.x ) : ldirection.x,
                velocity.y != 0 ? Math.sign( velocity.y ) : ldirection.y
            );

            //animation.scale( -ldirection.x * ANIM_COMP_BASE_SCALE_FACTOR, ANIM_COMP_BASE_SCALE_FACTOR );
            animation.scale( ldirection.x * ANIM_COMP_BASE_SCALE_FACTOR, ANIM_COMP_BASE_SCALE_FACTOR );
        }
    }

    void onDamaged() {
        fsm.transition( "hitted" );
    }

    void onDamagedUnderDamageResist() {}

    void onDie() {
        fsm.transition( "die" );
    }

    bool isAlive() {
        return health.current != 0;
    }

    bool isOnFloor() {
        return lisOnFloorChecker.collidingCount > 0;
    }

public:
    @property {
        SVec2I direction() { return ldirection; }

        void direction( SVec2I dir ) {
            if ( ldirection != dir ) {
                ldirection = dir;
                animation.scale( ldirection.x * ANIM_COMP_BASE_SCALE_FACTOR, ANIM_COMP_BASE_SCALE_FACTOR );
            }
        }
    }
}
