module game.core.effects.flickering;

import engine.modules.render_device;
import engine.framework.render;

import game.core.components.effects;
import game.core.components.health;

import game.core.character;

class CFlickering : CEffect {
    mixin( TRegisterClass!CFlickering );
protected:
    ID shader = ID_INVALID;

public:
    this( float duration ) {
        super( duration );
        
        shader = rdMakePipeline(
            rs!"res/game/shaders/flickering_vertex.shader",
            rs!"res/game/shaders/flickering_pixel.shader"
        );
    }

    ~this() {
        RD.destroy( shader );
    }

    override void update( float delta ) {
        super.update( delta );

        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.params.set( rs!"time", var( lduration / duration ) );
        }
    }

    override void apply() {
        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.shader = shader;
        }
    }

    override void end() {
        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.shader = ID_INVALID;
        }
    }
}

