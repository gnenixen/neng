module game.gapi.characters.player.states.attack;

import game.gapi.components.fsm;

class CPlayerState_Attack : CGAPICharacterState {
    mixin( TRegisterClass!CPlayerState_Attack );
protected:
    CTimer attackWindowTimer;
    bool bAttackWindow = false;

    bool bCanAttack = false;
    bool bWantAttack = false;
    bool bWantReset = false;

    int attackNum = 0;
    int maxAttackNum = 3;

public:
    override void _enter() {
        animation.mix = 0.0f;

        movement.forceStopHorizontal();

        attackNum = 0;

        moveCfg.maxMoveSpeed = 20;
        movement.direction.x = 0;

        process();

        animation.onEventReceived.connect( &onReceiveAnimEvent );
    }

    override void _leave() {
        animation.mix = 0.1f;

        bCanAttack = false;
        bAttackWindow = false;
        bWantAttack = false;
        bWantReset = false;
        attackNum = 0;

        if ( attackWindowTimer ) {
            attackWindowTimer.stop();
        }

        character.combat.reset();

        character.animation.onEventReceived.disconnect( &onReceiveAnimEvent );
    }

    override void _handle( CCharacterControllerCommand command ) {
        if ( command.isType!CAttackCommand && character.stamina.isCanMin( 2 ) ) {
            if ( bAttackWindow ) {
                process();
            } else {
                bWantAttack = true;
                bWantReset = false;
            }
        }

        if ( command.isType!CMoveCommand ) {
            if ( character.controller.vdirection.x == -character.direction.x ) {
                if ( bAttackWindow ) {
                    transition( "base" );
                } else {
                    bWantReset = true;
                    bWantAttack = false;
                }
            }
        }
    }

    void onReceiveAnimEvent( String name ) {
        if ( name == "AttackProcess" ) {
            character.combat.attack( ESingleAttackType.LIGHT, character.direction );
        }

        if ( name == "CanContinueCombo" ) {
            bCanAttack = true;

            if ( bWantAttack && character.stamina.isCanMin( 2 ) ) {
                process();
            } else if ( bWantReset ) {
                bWantReset = false;
                transition( "base" );
            } else {
                attackWindowTimer = execLater( 0.15f, &attackWindow );
                bAttackWindow = true;
            }
        }

        if ( name == "spAnimationComplete" ) {
            transition( "base" );
        }
    }

protected:
    void process() {
        if ( attackWindowTimer ) {
            attackWindowTimer.stop();
        }

        attackNum++;
        character.stamina.min( 2 );

        if ( attackNum > maxAttackNum ) {
            attackNum = 1;
        }

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

        bCanAttack = false;
        bAttackWindow = false;
        bWantAttack = false;
        bWantReset = false;
    }

    void attackWindow() {
        bAttackWindow = false;
    }
}
