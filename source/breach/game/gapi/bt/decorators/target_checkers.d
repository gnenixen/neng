module game.gapi.bt.decorators.target_checkers;

import engine.framework.bt;

import game.gapi.character;

class CBTDIsTargetTooFar : CBTDecorator {
    mixin( TRegisterClass!CBTDIsTargetTooFar );
private:
    String target;
    float distance;

public:
    this( String itarget, float idistance ) {
        target = itarget;
        distance = idistance;
    }

protected:
    override EBTNodeStatus onProcess() {
        if (
            !blackboard.has( rs!"character" ) ||
            !blackboard.has( target )
        ) {
            log.error( "Not found some fields in blackboard for decorator!" );
            return EBTNodeStatus.FAILURE;
        }

        CGAPICharacter mainChar = blackboard.get( rs!"character" ).as!CGAPICharacter;
        CGAPICharacter targetChar = blackboard.get( target ).as!CGAPICharacter;
        if ( !mainChar || !targetChar ) {
            log.error( "Invalid blackboard state for decorator!" );
            return EBTNodeStatus.FAILURE;
        }

        float dst = mainChar.transform.pos.distance( targetChar.transform.pos );

        if ( dst <= distance ) {
            return EBTNodeStatus.FAILURE;
        }
        
        return lchild.process();
    }
}
