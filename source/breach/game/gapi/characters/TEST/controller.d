module game.gapi.characters.TEST.controller;

import game.gapi.bt;
import game.gapi.character;
import game.gapi.commands;
import game.gapi.components.controller;

class CBTLFollowDirection : CBTLeaf {
    mixin( TRegisterClass!CBTLFollowDirection );
protected:
    override EBTNodeStatus onProcess() {
        if (
            !blackboard.has( rs!"character" ) ||
            !blackboard.has( rs!"target" )
        ) {
            log.error( "Not found some fields in blackboard for leaf!" );
            return EBTNodeStatus.FAILURE;
        }

        CGAPICharacter chMain = blackboard.get( rs!"character" ).as!CGAPICharacter;
        CGAPICharacter chTarget = blackboard.get( rs!"target" ).as!CGAPICharacter;

        if ( 
            !chMain ||
            !chTarget
        ) {
            log.error( "Invalid blackboard state for leaf!" );
            return EBTNodeStatus.FAILURE;
        }

        SVec2F moveTo = chTarget.transform.pos;
        int dir = chMain.direction.x;

        if ( chMain.transform.pos.x < moveTo.x - 25 ) {
            dir = 1;
        } else if ( chMain.transform.pos.x > moveTo.x + 25 ) {
            dir = -1;
        }

        chMain.controller.newCommand!CMoveCommand( SVec2I( dir, 0 ) );

        return EBTNodeStatus.SUCCESS;
    }
}

class CTESTController : CCharacterController {
    mixin( TRegisterClass!CTESTController );
public:
    BTBlackboard blackboard;
    CBehaviorTree bt;

    bool bUpdateBT = true;

public:
    this() {
        bt = newObject!CBehaviorTree();

        CBTBuilder builder = newObject!CBTBuilder( null, bt );

        builder
            .composite!CBTCSelector()
                .decorator!CBTDIsTargetTooFar( rs!"target", 96 )
                    .composite!CBTCSelector()
                        .leaf!CBTLFollowTarget( rs!"target", 90 )
                    .end()
                .end()

                //.decorator!CBTDRepeater()
                    .composite!CBTCSequence()
                        //.leaf!CBTLPrint( rs!"On attack distance" )
                        .leaf!CBTLFollowDirection()
                        .leaf!CBTLAttack()
                    .end()
                //.end()
            .build();

        destroyObject( builder );
    }

    ~this() {
        destroyObject( bt );
    }

    override void _ptick( float delta ) {
        super._ptick( delta );

        if ( bUpdateBT ) {
            bt.process();
        }
    }
}
