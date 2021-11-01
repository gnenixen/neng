module game.gapi.characters.player.states._attack;

import game.gapi.components.fsm;

class _CPlayerState_Attack : CGAPICharacterState {
    mixin( TRegisterClass!_CPlayerState_Attack );
protected:
    bool bCanAA = true;
    bool bWantAA = false;
    bool bWantReset = false;
    SVec2I lastDir = SVec2I( -10 );
    CTimer attackSpeed;
    CTimer exitTimer;

    int attackNum = 0;
    int maxAttackNum = 3;

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

        step();

        animation.onEventReceived.connect( &onAnimEvent );
    }

    void onAnimEvent( String name ) {
        if ( name == "AttackProcess" ) {
            character.combat.attack( ESingleAttackType.LIGHT, character.direction );
        }

        if ( name == "CanContinueCombo" ) {
            bCanAA = true;
            if ( bWantAA ) {
                step();
            } else if ( bWantReset ) {
                bWantReset = false;
                transition( "base" );
                exitTimer.stop();
                attackSpeed.stop();
            }
        }
    }

    override void _leave() {
        attackSpeed.stop();
        exitTimer.stop();

        character.combat.reset();

        character.animation.onEventReceived.disconnect( &onAnimEvent );
    }

    override void _tick( float delta ) {
        if ( lastDir != SVec2I( -1 ) && lastDir.x != character.controller.vdirection.x && exitTimer.waitTime == 0.9f ) {
            //exitTimer.pause();
            //exitTimer.waitTime = 0.3f;
            //exitTimer.unpause();
            bWantReset = true;
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
                //exitTimer.pause();
                //exitTimer.waitTime = 0.15f;
                //exitTimer.unpause();
                bWantReset = true;
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
        //movement.direction.x = 0;
        //movement.forceStopHorizontal();

        //if ( bWantAA ) {
            //step();
        //}
    }

    void step() {
        attackSpeed.stop();
        exitTimer.stop();
        attackNum++;
        
        if ( attackNum > maxAttackNum ) {
            attackNum = 1;
        }

        //movement.forceStopHorizontal();
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
