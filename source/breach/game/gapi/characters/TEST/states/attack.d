
module game.gapi.characters.TEST.states.attack;

import game.gapi.components.fsm;

class CTESTState_Attack : CGAPICharacterState {
    mixin( TRegisterClass!CTESTState_Attack );
protected:
    bool bCanAA = true;
    bool bWantAA = false;
    SVec2I lastDir = SVec2I( -10 );
    CTimer attackSpeed;
    CTimer exitTimer;

    int attackNum = 0;
    int maxAttackNum = 3;

    bool bConnectedToEvents = false;

public:
    override void _enter() {
        attackSpeed = execLater( 0.2f, &lbCanAA );
        exitTimer = execLater( 0.9f, &lexitToBase );
        movement.forceStopHorizontal();
        attackNum = 0;
        lastDir = SVec2I( -10 );

        moveCfg.maxMoveSpeed = 20;
        //movement.direction = character.direction;
        movement.direction.x = 0;

        if ( !bConnectedToEvents ) {
            animation.onEventReceived.connect( &onAnimEvent );
            bConnectedToEvents = true;
        }

        step();
    }

    void onAnimEvent( String name ) {
        if ( name == "AttackProcess" ) {
            character.combat.attack( ESingleAttackType.LIGHT, character.direction );
            character.combat.reset();
        }

        if ( name == "CanContinueCombo" ) {
            bCanAA = true;
            if ( bWantAA && character.stamina.isCanMin( 2 ) ) {
                step();
            }
        }
    }

    override void _leave() {
        attackSpeed.stop();
        exitTimer.stop();

        character.combat.reset();
    }

    override void _tick( float delta ) {
        if ( lastDir != SVec2I( -10 ) && lastDir.x != character.controller.vdirection.x && exitTimer.waitTime == 0.6f ) {
            exitTimer.pause();
            exitTimer.waitTime = 0.3f;
            exitTimer.unpause();
        }

        lastDir = character.controller.vdirection;
    }

    override void _handle( CCharacterControllerCommand command ) {
        if ( command.isType!CAttackCommand ) {
            if ( bCanAA ) {
                step();
            } else {
                bWantAA = true;
            }
        }

        if ( command.isType!CMoveCommand ) {
            if ( character.controller.vdirection != 0 && character.controller.vdirection.x != character.direction.x ) {
                exitTimer.pause();
                exitTimer.waitTime = 0.15f;
                exitTimer.unpause();
            }
        }
    }

protected:
    void lexitToBase() {
        transition( "base" );
        exitTimer.stop();
    }

    void lbCanAA() {
        //bCanAA = true;
        movement.direction.x = 0;
        movement.forceStopHorizontal();

        //if ( bWantAA ) {
            //step();
        //}
    }

    void step() {
        attackSpeed.stop();
        exitTimer.stop();
        attackNum++;

        character.stamina.min( 2 );
        
        if ( attackNum > maxAttackNum ) {
            attackNum = 1;
        }

        movement.forceStopHorizontal();
        //movement.direction.x = character.direction.x;

        switch ( attackNum ) {
            case 1:
                animation.play( "Combo_hit_1", 0, false );
                //movement.cfg.maxMoveSpeed = 100;
                break;
            case 2:
                animation.play( "Combo_hit_2", 0, false );
                //movement.cfg.maxMoveSpeed = 150;
                break;
            case 3:
                animation.play( "Combo_hit_3", 0, false );
                //movement.cfg.maxMoveSpeed = 200;
                break;

            default: assert( false );
        }

        exitTimer.start();
        attackSpeed.start();
        bCanAA = false;
        bWantAA = false;
    }
}
