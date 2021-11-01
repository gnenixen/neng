module game.core.components.movement;

import engine.modules.physics_2d;

import game.core.actions;
import game.core.base.component;
import game.core.components.physics;

const float MOVEMENT_BASE_MAX_MOVE_SPEED = 500.0f;
const float MOVEMENT_BASE_MIN_MOVE_SPEED = 100.0f;
const float MOVEMENT_BASE_MAX_VERTICAL_UP_SPEED = 1200.0f;
const float MOVEMENT_BASE_MAX_VERTICAL_DOWN_SPEED = 1000.0f;
const float MOVEMENT_BASE_IMPULCE_MODIFICATOR = 0.2f;
const float MOVEMENT_BASE_FALLOF_MODIFICATOR = 0.0f;
const float MOVEMENT_BASE_JUMP_HEIGHT = 525 * 1.5f;
const int MOVEMENT_BASE_MAX_JUMP_STEPS = 12;

struct SMovementConfig {
    float maxMoveSpeed;
    float minMoveSpeed;
    float maxVertialUpSpeed;
    float maxVertialDownSpeed;
    float impulceModificator;
    float fallofModificator;

    float jumpHeight;
    int maxJumpSteps;
}

class CMovementComponent : CComponent {
    mixin( TRegisterClass!CMovementComponent );
public:
    SVec2I direction = SVec2I( 0 );

    SMovementConfig cfg;

    bool bJumpActive = false;
    int jumpSteps = 0;

protected:
    CPhysicsComponent physics;

public:
    this() {
        super();
        resetValues();
    }

    override void _begin() {
        physics = object.getComponent!CPhysicsComponent();
        assert( physics );
    }

    override void _ptick( float delta ) {
        SVec2F newVelocity = velocity;

        // No direction - just smooth fallof speed to 0
        if ( direction.x == 0 ) {
            if ( Math.abs( newVelocity.x ) < cfg.maxMoveSpeed * cfg.impulceModificator ) {
                newVelocity *= SVec2F( 0.0f, 1.0f );
            } else {
                newVelocity *= SVec2F( cfg.fallofModificator, 1.0f );
            }
        } else if ( Math.sign( newVelocity.x ) != Math.sign( direction.x ) ) {
            newVelocity.x = Math.abs( newVelocity.x ) * direction.x;
        }

        // Cap max speed
        if ( Math.abs( newVelocity.x ) > cfg.maxMoveSpeed ) {
            newVelocity.x = Math.sign( newVelocity.x ) * cfg.maxMoveSpeed;
        }

        if ( newVelocity.y < -cfg.maxVertialUpSpeed ) {
            newVelocity.y = Math.sign( newVelocity.y ) * cfg.maxVertialUpSpeed;
        }

        if ( newVelocity.y > cfg.maxVertialDownSpeed ) {
            newVelocity.y = Math.sign( newVelocity.y ) * cfg.maxVertialDownSpeed;
        }

        physics.linearVelocity = newVelocity;

        // Small impulce for start moving
        if ( direction.x != 0 && Math.abs( newVelocity.x ) < cfg.maxMoveSpeed ) {
            physics.applyLinearImpulse( SVec2F( cfg.maxMoveSpeed * physics.mass * cfg.impulceModificator * direction.x, 0.0f ) );
        }

        // Process various jump heigth
        //if ( bJumpActive && jumpSteps > 0 ) {
            //float force = physics.mass * cfg.jumpHeight / delta;
            //force /= 4.0f;
            //physics.applyForce( SVec2F( 0, -force ), physics.getWorldCenter );
            //jumpSteps -= 1;
        //}

        if ( !bJumpActive ) {
            jumpSteps = 0;
        }
    }

    void forceStopHorizontal() {
        physics.linearVelocity = SVec2F( 0.0f, velocity.y );
    }

    void resetValues() {
        direction = SVec2I( 0 );

        cfg.maxMoveSpeed = MOVEMENT_BASE_MAX_MOVE_SPEED;
        cfg.minMoveSpeed = MOVEMENT_BASE_MIN_MOVE_SPEED;
        cfg.maxVertialUpSpeed = MOVEMENT_BASE_MAX_VERTICAL_UP_SPEED;
        cfg.maxVertialDownSpeed = MOVEMENT_BASE_MAX_VERTICAL_DOWN_SPEED;
        cfg.impulceModificator = MOVEMENT_BASE_IMPULCE_MODIFICATOR;
        cfg.fallofModificator = MOVEMENT_BASE_FALLOF_MODIFICATOR;

        cfg.jumpHeight = MOVEMENT_BASE_JUMP_HEIGHT;
        cfg.maxJumpSteps = MOVEMENT_BASE_MAX_JUMP_STEPS;
    }

    void applyImpulce( SVec2F impulce ) {
        physics.applyLinearImpulse( impulce * physics.mass );
    }

    void jump() {
        //jumpSteps = cfg.maxJumpSteps;
        //physics.applyLinearImpulse( SVec2F( 0, -cfg.jumpHeight / 2 * physics.mass ) );
        physics.applyLinearImpulse( SVec2F( 0, -cfg.jumpHeight * physics.mass ) );
    }

public:
    SVec2F velocity() { return physics.linearVelocity; }
}
