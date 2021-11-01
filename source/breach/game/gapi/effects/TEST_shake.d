module game.gapi.effects.TEST_shake;

import game.core.components.effects;

import game.gapi.character;

import game.gapi.effects.TEST_block;

class CTESTShakeEffect : CEffect {
    mixin( TRegisterClass!CTESTShakeEffect );
public:
    float shakeMagnitude = 10.0f;
    float shakeNoize = 20.0f;
    SVec2F shakeNoizeStartPoint0;
    SVec2F shakeNoizeStartPoint1;

    this() {
        super( 0.2f );
    }

    override void apply() {
        shakeNoizeStartPoint0 = SVec2F( Math.randf( -1.0f, 1.0f ) * shakeNoize );
        shakeNoizeStartPoint1 = SVec2F( Math.randf( -1.0f, 1.0f ) * shakeNoize );
    }

    override void tick( float delta ) {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character && component.has!CTESTBlockEffect ) {
            delta = lduration / duration;

                SVec2F currentNoizePoint0 = SVec2F( Math.lerp( shakeNoizeStartPoint0.x, 0, delta ), Math.lerp( shakeNoizeStartPoint0.y, 0, delta ) );
                SVec2F currentNoizePoint1 = SVec2F( Math.lerp( shakeNoizeStartPoint1.x, 0, delta ), Math.lerp( shakeNoizeStartPoint1.y, 0, delta ) );

                SVec2F camPosDelta = SVec2F( Math.perlinNoise( currentNoizePoint0.x, currentNoizePoint0.y ), Math.perlinNoise( currentNoizePoint1.x, currentNoizePoint1.y ) );
                camPosDelta *= shakeMagnitude;

                character.animation.transform.pos = SVec2F( 0, 95 ) + camPosDelta;
        }
    }

    override void end() {
        CGAPICharacter character = Cast!CGAPICharacter( object );
        if ( character ) {
            character.animation.transform.pos = SVec2F( 0, 95 );
        }
    }
}

