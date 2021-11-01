module game.gapi.characters.TEST.character;

import engine.core.resource;

import engine.framework.pathfinder;

import game.core.objects.base.trigger;
import game.core.effects;

import game.gapi.effects;
import game.gapi.components;
import game.gapi.character;
import game.gapi.characters.TEST.states;
import game.gapi.characters.TEST.controller;

class CTEST : CGAPICharacter {
    mixin( TRegisterClass!CTEST );
public:
    CGAPICharacter lplayer;
    CGAPIHealthUpHeadRenderComponent healthRender;

public:
    this( CGAPICharacter player, CPathFinderMap pathfinder ) {
        super();
        lplayer = player;

        healthRender = newComponent!CGAPIHealthUpHeadRenderComponent();

        health.max = 100;
        health.heal( 100 );

        movement.cfg.maxMoveSpeed = 400;

        fsm.addState!CTESTState_Base( rs!"base" );
        fsm.addState!CTESTState_BaseRun( rs!"base_run" );
        fsm.addState!CTESTState_Die( rs!"die" );
        fsm.addState!CTESTState_Hitted( rs!"hitted" );
        fsm.addState!CTESTState_Fall( rs!"fall" );
        fsm.addState!CTESTState_Attack( rs!"attack" );
        fsm.addState!CTESTState_Block( rs!"block" );

        fsm.transition( "base" );

        animation.resource = GResourceManager.loadStatic!CSpineResource( "res/game/dev_test/Anim_Worker.json" );
        animation.skin = rs!"Skin_2";
        animation.speed = 1.3f;

        CTESTController contr = NewObject!CTESTController();
        contr.bt.blackboard.set( rs!"character", var( this ) );
        contr.bt.blackboard.set( rs!"target", var( player ) );
        contr.bt.blackboard.set( rs!"pathfinder", var( pathfinder ) );

        changeController( contr );

        stamina.max = 6;
    }

    override void _tick( float delta ) {
        super._tick( delta );

        CTESTController contr = Cast!CTESTController( controller );
        contr.bt.blackboard.set( rs!"delta", var( delta ) );
    }

    override void onDie() {
        fsm.transition( "die" );
        destroyObject( lshBody );
        physics.gravityScale = 0.0f;

        lcomponents.remove( healthRender );

        DestroyObject( healthRender );

        CTESTController contr = Cast!CTESTController( controller );
        if ( contr ) {
            contr.bUpdateBT = false;
        }
    }

    override void onDamaged() {
        effects.add( NewObject!CFlickering( 0.1f ) );
    }

    override void onDamagedUnderDamageResist() {
        if ( fsm.current.name == "block" ) {
            if ( stamina.isCanMin( 3 ) ) {
                effects.add( NewObject!CTESTShakeEffect() );
                stamina.min( 3 );
            } else {
                stamina.min( 3 );
                health.bDamageResist = false;
                health.damage( 20 );
                effects.add( NewObject!CFlickering( 0.1f ) );
            }
        }
    }
}

