module game.core.effects.damage_resist;

import engine.modules.render_device;
import engine.framework.render;

import game.core.components.effects;
import game.core.components.health;

import game.core.character;

class CDamageResist : CEffect {
    mixin( TRegisterClass!CDamageResist );
protected:
    ID shader = ID_INVALID;

public:
    this( float duration ) {
        super( duration );
        
        shader = rdMakePipeline(
            rs!"res/game/shaders/damage_protection_vertex.shader",
            rs!"res/game/shaders/damage_protection_pixel.shader"
        );
    }

    ~this() {
        RD.destroy( shader );
    }

    override void update( float delta ) {
        super.update( delta );

        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.params.set( rs!"time", var( lduration ) );
        }
    }

    override void apply() {
        CHealthCompnent health = object.getComponent!CHealthCompnent;
        if ( health ) {
            health.bDamageResist = true;
        }

        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.shader = shader;
        }
    }

    override void end() {
        CHealthCompnent health = object.getComponent!CHealthCompnent;
        if ( health ) {
            health.bDamageResist = false;
        }

        CBaseCharacter character = Cast!CBaseCharacter( object );
        if ( character ) {
            character.animation.primitive.material.shader = ID_INVALID;
        }
    }
}
