module game.gapi.components.health_up_head_render;

import engine.framework.scene_tree.n2d.sprite;

import game.gapi.character;

class CGAPIHealthUpHeadRenderComponent : CComponent {
    mixin( TRegisterClass!CGAPIHealthUpHeadRenderComponent );
public:
    CSprite back;
    CSprite front;
    CSprite stamina;

public:
    this() {
    }

    override void _begin() {
        back = NewObject!CSprite();
        front = NewObject!CSprite();
        stamina = NewObject!CSprite();

        back.texture = GResourceManager.load!CTexture( "res/engine/textures/white.png" );
        back.modulate = EColors.BLACK;

        front.texture = GResourceManager.load!CTexture( "res/engine/textures/white.png" );
        front.modulate = EColors.RED;

        stamina.texture = GResourceManager.load!CTexture( "res/engine/textures/white.png" );
        stamina.modulate = getColorFromHex( String( "#e56c00" ) );

        back.transform.size = SVec2F( 0.5f, 0.07f );
        front.transform.size = SVec2F( 0.8f ) * SVec2F( 0.6f, 0.04f );
        stamina.transform.size = SVec2F( 0.8f ) * SVec2F( 0.6f, 0.02f );

        back.transform.pos.y = -100;
        front.transform.pos.y = -105;
        stamina.transform.pos.y = -95;

        addChild( stamina );
        addChild( front );
        addChild( back );
        CHealthCompnent health = object.getComponent!CHealthCompnent();
        CStaminaComponent _stamina = object.getComponent!CStaminaComponent();
        assert( health );
        assert( _stamina );
        health.hpUpdated.connect( &healthUpdated );
        _stamina.currentUpdated.connect( &staminaUpdate );
    }

    void healthUpdated( uint newHp ) {
        CHealthCompnent health = object.getComponent!CHealthCompnent();
        assert( health );

        front.transform.size.x = health.percent() / 100 * 0.8f * 0.6;
    }

    void staminaUpdate( uint current ) {
        CStaminaComponent _stamina = object.getComponent!CStaminaComponent();
        assert( _stamina );

        stamina.transform.size.x = _stamina.percent / 100 * 0.8f * 0.6f;
    }
}

