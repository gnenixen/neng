module game.gapi.characters.player.character;

import engine.core.resource;

import game.core.effects;

import game.gapi.components;
import game.gapi.character;
import game.gapi.characters.player.states;
import game.gapi.characters.player.controller;

import engine.modules.sound;

class CPlayer : CGAPICharacter {
    mixin( TRegisterClass!CPlayer );
public:
    CSpineComponent anim2;

    CSound sound;

    this() {
        super();

        sound = GResourceManager.loadStatic!CSound( "res/S27.ogg" );
        
        //newComponent!CGAPIHealthUpHeadRenderComponent();

        //anim2 = newComponent!CSpineComponent();
        //anim2.resource = GResourceManager.loadStatic!CSpineResource( "res/game/dev_test/Anim_Worker.json" );
        //anim2.scale( 0.4f, 0.4f );
        //anim2.speed = 0.2f;

        //anim2.transform.pos.x += 500;

        player_states_register();

        fsm.addState!CPlayerState_Base( rs!"base" );
        fsm.addState!CPlayerState_BaseRun( rs!"base_run" );
        fsm.addState!CPlayerState_Block( rs!"block" );
        fsm.addState!CPlayerState_Fall( rs!"fall" );
        fsm.addState!CPlayerState_Jump( rs!"jump" );
        fsm.addState!CPlayerState_Attack( rs!"attack" );
        fsm.addState!CPlayerState_Hitted( rs!"hitted" );
        fsm.addState!CPlayerState_Die( rs!"die" );
        fsm.addState!CPlayerState_Dodge( rs!"dodge" );

        fsm.fsm.transition( "base_run" );

        //animation.resource = GResourceManager.loadStatic!CSpineResource( "res/game/dev_test/Anim_Worker.json" );
        //animation.skin = rs!"body/body_skin_4|head/head|weapon/knives|l_hand/l_hand_skin_3|l_leg/l_leg_skin_2|r_hand/r_hand_skin_2|r_leg/r_leg_skin_3";
        animation.resource = GResourceManager.loadStatic!CSpineResource( "res/game/dev_test/Anim_Worker_Fem.json" );
        animation.skin = rs!"body/body_skin_4|head/head|weapon/knives|l_hand/l_hand_skin_3|l_leg/l_leg_skin_2|r_hand/r_hand_skin_2|r_leg/r_leg_skin_3";
        animation.speed = 1.3f;

        changeController( newObject!CPlayerController() );
    }

    override void _input( CInputAction action ) {
        //Array!String skins = animation.skins;
        //foreach ( skin; skins ) {
            //log.warning( skin );
        //}

        //log.error("");
        if ( action.isActionPressed( "r" ) ) {
            sound.play( SVec3F( 1920, 1080, 0 ) );
        /*
            String res;

            res ~= "Body/Body_Skin_";
            res ~= Math.rand( 1, 5 );
            res ~= "|";

            res ~= "Head/Head_Skin_";
            res ~= Math.rand( 1, 5 );
            res ~= "|";

            res ~= "Weapon/Knife_";
            res ~= Math.rand( 1, 3 );
            res ~= "|";

            res ~= "L_hand/L_hand_Skin_";
            res ~= Math.rand( 1, 5 );
            res ~= "|";

            res ~= "R_hand/R_hand_Skin_";
            res ~= Math.rand( 1, 5 );
            res ~= "|";

            res ~= "L_leg/L_leg_Skin_";
            res ~= Math.rand( 1, 5 );
            res ~= "|";

            res ~= "R_leg/R_leg_Skin_";
            res ~= Math.rand( 1, 5 );

            animation.skin = res;*/
        }
    }

    override void onDamagedUnderDamageResist() {
        if ( fsm.current.name == "block" ) {
            if ( stamina.isCanMin( 2 ) ) {
                stamina.min( 2 );
            } else {
                health.bDamageResist = false;
                health.damage( 20 );
            }
        }
    }
}
