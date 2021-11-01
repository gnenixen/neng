module game.gapi.effects.TEST_slide;

import game.core.components.effects;

import game.gapi.character;

class CTESTSlideEffect : CEffect {
    mixin( TRegisterClass!CTESTSlideEffect );
private:
    SVec2I direction;

public:
    this( SVec2I direction ) {
        super( 2.0f );

        this.direction = direction;
    }

    override void apply() {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character ) {
            character.direction.x = direction.x;
            character.animation.scale( -direction.x * 0.4, 0.4 );
            character.movement.direction = direction;
        }
    }

    override void tick( float delta ) {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character ) {
            if ( lduration / duration > 0.5f ) {
                character.movement.cfg.maxMoveSpeed = MOVEMENT_BASE_MAX_MOVE_SPEED * ((lduration / duration) / 3);
            } else {
                character.movement.cfg.maxMoveSpeed = 0.0f;
            }
        }
    }

    override void end() {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character ) {
            character.movement.direction = SVec2I( 0 );
            character.movement.cfg.maxMoveSpeed = MOVEMENT_BASE_MAX_MOVE_SPEED;
        }
    }
}
