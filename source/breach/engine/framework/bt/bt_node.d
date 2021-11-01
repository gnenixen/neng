module engine.framework.bt.bt_node;

public import engine.core.object;

public import engine.framework.bt;

enum EBTNodeStatus {
    FAILURE = -1,
    INVALID = 0,
    SUCCESS = 1,
    RUNNING = 2,
}

class CBTNode : CObject {
    mixin( TRegisterClass!CBTNode );
public:
    CBehaviorTree tree;
    EBTNodeStatus status;

public:
    EBTNodeStatus process() {
        if ( status != EBTNodeStatus.RUNNING ) {
            onInit();
        }

        status = onProcess();

        if ( status != EBTNodeStatus.RUNNING ) {
            onTerminate();
        }

        return status;
    }

protected:
    void onInit() {}
    void onTerminate() {}
    EBTNodeStatus onProcess() {
        return EBTNodeStatus.SUCCESS;
    }

    BTBlackboard blackboard() {
        assert( tree );
        return tree.blackboard;
    }
}

alias CBTLeaf = CBTNode;
