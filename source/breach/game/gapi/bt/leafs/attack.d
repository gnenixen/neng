module game.gapi.bt.leafs.attack;

import engine.framework.bt;

import game.gapi.commands;
import game.gapi.character;

class CBTLAttack : CBTLeaf {
    mixin( TRegisterClass!CBTLAttack );
protected:
    override EBTNodeStatus onProcess() {
        if ( !blackboard.has( rs!"character" ) ) {
            log.error( "Not found some fields in blackboard for decorator!" );
            return EBTNodeStatus.FAILURE;
        }

        CGAPICharacter mainChar = blackboard.get( rs!"character" ).as!CGAPICharacter;
        if ( !mainChar ) {
            log.error( "Invalid blackboard state for decorator!" );
            return EBTNodeStatus.FAILURE;
        }

        mainChar.controller.newCommand!CAttackCommand();

        return EBTNodeStatus.SUCCESS;
    }
}

