module game.gapi.bt.leafs.move_stop;


import engine.framework.bt;

import game.gapi.character;

class CBTLMoveStop : CBTLeaf {
    mixin( TRegisterClass!CBTLMoveStop );
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

        mainChar.controller.newCommand!CMoveCommand( SVec2I( 0 ) );
        mainChar.movement.forceStopHorizontal();

        return EBTNodeStatus.SUCCESS;
    }
}
