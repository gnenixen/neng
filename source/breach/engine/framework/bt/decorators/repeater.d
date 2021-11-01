module engine.framework.bt.decorators.repeater;

import engine.framework.bt.bt_decorator;

class CBTDRepeater : CBTDecorator {
    mixin( TRegisterClass!CBTDRepeater );
protected:
    int limit = 0;
    int counter = 0;

public:
    override void onInit() {
        counter = 0;
    }

    override EBTNodeStatus onProcess() {
        lchild.process();
        if ( limit > 0 && ++counter == limit ) {
            return EBTNodeStatus.SUCCESS;
        }

        return EBTNodeStatus.RUNNING;
    }
}