module game.gapi.bt.leafs.follow_target;

import engine.framework.bt;
import engine.framework.pathfinder;

import game.gapi.character;
import game.gapi.commands;

enum EAIActionExecResult {
    PROCESS,
    FINISH,
    FAILED,
}

class CAIAction : CObject {
    mixin( TRegisterClass!CAIAction );
public:
    CGAPICharacter character;

public:
    void begin() {}
    EAIActionExecResult exec() { return EAIActionExecResult.FINISH; }
}

class CAIAction_Stop : CAIAction {
    mixin( TRegisterClass!CAIAction_Stop );
public:
    override EAIActionExecResult exec() {
        character.controller.newCommand!CMoveCommand( SVec2I( 0, 0 ) );
        //character.movement.forceStopHorizontal();
        return EAIActionExecResult.FINISH;
    }
}

class CAIAction_Move : CAIAction {
    mixin( TRegisterClass!CAIAction_Move );
public:
    SVec2F moveTo;
    float padding = 15.0f;
    float finishPadding = 80.0f;

public:
    this( SVec2F to ) {
        moveTo = to;
    }

    override EAIActionExecResult exec() {
       if ( character.transform.pos.distance( moveTo ) < finishPadding && character.isOnFloor ) {
            return EAIActionExecResult.FINISH;
        }
        
        float pad = padding;

        SVec2I direction = SVec2I( 0 );

        if ( character.transform.pos.x < moveTo.x - pad ) {
            direction.x = 1;
        } else if ( character.transform.pos.x > moveTo.x + pad ) {
            direction.x = -1;
        } else {
            direction.x = 0;
        }

        if ( direction != character.movement.direction ) {
            character.controller.newCommand!CMoveCommand( direction );
        }
        
        return EAIActionExecResult.PROCESS;
    }
}

class CAIAction_Jump : CAIAction {
    mixin( TRegisterClass!CAIAction_Jump );
public:
    SVec2F moveTo;
    bool bJumped = false;

    float padding = 10.0f;
    float finishPadding = 10.0f;

public:
    this( SVec2F to ) {
        moveTo = to;
    }

    override EAIActionExecResult exec() {
        SVec2F chposx = SVec2F( character.transform.pos.x, 0.0f );
        SVec2F mtposx = SVec2F( moveTo.x, 0.0f );

        if ( chposx.distance( mtposx ) < finishPadding && character.isOnFloor && bJumped ) {
            return EAIActionExecResult.FINISH;
        }

        if ( character.isOnFloor && !bJumped ) {
            character.controller.newCommand!CJumpCommand;
            bJumped = true;
        }

        float pad = padding;

        SVec2I direction = SVec2I( 0 );

        if ( character.transform.pos.x < moveTo.x - pad ) {
            direction.x = 1;
        } else if ( character.transform.pos.x > moveTo.x + pad ) {
            direction.x = -1;
        } else {
            direction.x = 0;
        }

        if ( direction != character.movement.direction ) {
            character.controller.newCommand!CMoveCommand( direction );
        }

        return EAIActionExecResult.PROCESS;
    }
}

class CBTLFollowTarget : CBTLeaf {
    mixin( TRegisterClass!CBTLFollowTarget );
private:
    String target;
    float acceptDistance;

    Array!CAIAction actions;
    int index = 0;
    SVec2F lastPos;
    int delayer = 0;

public:
    this( String itarget, float iacceptDistance ) {
        target = itarget;
        acceptDistance = iacceptDistance;

        lastPos = SVec2F( float.max );
    }

protected:
    override void onInit() {
        resetPath();
        lastPos = SVec2F( float.max );
    }

    override void onTerminate() {
        CGAPICharacter chMain = blackboard.get( rs!"character" ).as!CGAPICharacter;
        chMain.controller.newCommand!CMoveCommand( SVec2I( 0 ) );
        chMain.movement.forceStopHorizontal();
    }

    override EBTNodeStatus onProcess() {
        if (
            !blackboard.has( rs!"character" ) ||
            !blackboard.has( rs!"pathfinder" ) ||
            !blackboard.has( target )
        ) {
            log.error( "Not found some fields in blackboard for leaf!" );
            return EBTNodeStatus.FAILURE;
        }

        CGAPICharacter chMain = blackboard.get( rs!"character" ).as!CGAPICharacter;
        CGAPICharacter chTarget = blackboard.get( target ).as!CGAPICharacter;
        CPathFinderMap pathfinder = blackboard.get( rs!"pathfinder" ).as!CPathFinderMap;

        if ( 
            !chMain ||
            !chTarget ||
            !pathfinder
        ) {
            log.error( "Invalid blackboard state for leaf!" );
            return EBTNodeStatus.FAILURE;
        }

        SVec2F start = chMain.transform.pos;
        SVec2F end = chTarget.transform.pos;
        if ( lastPos == SVec2F( float.max ) ) {
            lastPos = start;
        }

        if ( start.distance( end ) <= acceptDistance ) {
            return EBTNodeStatus.SUCCESS;
        }

        if ( chMain.isOnFloor ) {
            bool bTooShortMoveDelta = false;
            bool bAllActionsExecuted = false;
            bool bNotReachEnd = false;

            delayer++;
            if ( delayer >= 10 ) {
                SVec2F moveDelta = start - lastPos;
                lastPos = start;
                delayer = 0;

                bTooShortMoveDelta = SVec2F( 0.0f ).distance( moveDelta ) < (chMain.movement.cfg.maxMoveSpeed / 10.0f);
            }

            bAllActionsExecuted = index == -1;
            bNotReachEnd = start.distance( end ) > acceptDistance;

            if ( bTooShortMoveDelta || ( bAllActionsExecuted && bNotReachEnd ) ) {
                resetPath();
                updatePath(
                    pathfinder,
                    chMain,
                    findPath(
                        pathfinder,
                        start,
                        end
                    ),
                    start,
                    end
                );
            }
        } else {
            delayer = 0;
        }

        if ( index != -1 && actions.length > 0 ) {
            EAIActionExecResult res = actions[index].exec();

            switch ( res ) {
            case EAIActionExecResult.PROCESS:
                break;

            case EAIActionExecResult.FINISH:
                delayer = 0;

                if ( index == actions.length - 1 ) {
                    index = -1;
                    return EBTNodeStatus.SUCCESS;
                } else {
                    index++;
                    delayer = 0;
                }
                break;

            case EAIActionExecResult.FAILED:
                index = -1;
                return EBTNodeStatus.FAILURE;

            default:
                break;
            }
        }
        
        return EBTNodeStatus.RUNNING;
    }

    void resetPath() {
        index = -1;
        delayer = 0;

        foreach ( act; actions ) {
            destroyObject( act );
        }

        actions.free();
    }

    Array!SVec2I findPath( CPathFinderMap pathfinder, SVec2F start, SVec2F end ) {
        start /= 64;
        end /= 64;

        return pathfinder.findPath( start, end );
    }

    T action( T, Args... )( CGAPICharacter ch, Args args ) {
        T act = newObject!T( args );
        act.character = ch;

        return act;
    }

    void updatePath( CPathFinderMap pathfinder, CGAPICharacter ch, Array!SVec2I npath, SVec2F start, SVec2F end ) {
        Array!CAIAction nactions;

        if ( npath.length == 0 ) {
            index = -1;
            return;
        }

        SVec2I lPos = SVec2I( int.max );
        foreach ( i, pos; npath ) {
            if ( npath.length == 1 ) break;

            SVec2I type = pathfinder.cellType( pos, true );
            SVec2F cpos = pos.tov!float * 64 + SVec2F( 32 );

            if ( lPos != SVec2I( int.max ) && lPos.y >= pos.y - pathfinder.jumpHeight && ((lPos.x < pos.x && type.x < 0) || (lPos.x > pos.x && type.y < 0)) ) {
                nactions ~= action!CAIAction_Jump( ch, cpos );
            }

            lPos = pos;

            if ( i == 0 && npath.length > 1 ) {
                SVec2F nextPoint = npath[1].tov!float * 64 + SVec2F( 32 );

                if ( start.distance( nextPoint ) > cpos.distance( nextPoint ) ) {
                    nactions ~= action!CAIAction_Move( ch, cpos );
                }
            } else if ( i == npath.length - 1 && npath.length > 1 ) {
                SVec2F pm2 = npath[npath.length - 2].tov!float * 64 + SVec2F( 32 );

                if ( pm2.distance( end ) < cpos.distance( end ) ) {
                    nactions ~= action!CAIAction_Move( ch, cpos );
                }
            } else {
                nactions ~= action!CAIAction_Move( ch, cpos );
            }
        }
        nactions ~= action!CAIAction_Move( ch, end );
        //nactions ~= action!CAIAction_Stop( ch );

        if ( actions.length != nactions.length ) {
            resetPath();

            actions.free();
            index = 0;

            foreach ( act; nactions ) {
                actions ~= act;
            }
        }
    }
}
