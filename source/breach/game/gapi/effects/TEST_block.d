module game.gapi.effects.TEST_block;

import game.core.components.effects;

import game.gapi.character;

class CTESTBlockEffect : CEffect {
    mixin( TRegisterClass!CTESTBlockEffect );
public:
    this() {
        super( 2.0f );

        bIsEffectStacked = true;
        bIsDurationStacked = true;
    }

    override void apply() {
        //if ( stacks >= 3 ) {
            CGAPICharacter character = Cast!CGAPICharacter( object );
            if ( character ) {
                if ( character.isAlive ) {
                    character.fsm.transition( "block" );
                }
            }
        //}
    }

    override void end() {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character ) {
            if ( character.isAlive ) {
                character.fsm.transition( "base" );
            }
        }
    }
}
