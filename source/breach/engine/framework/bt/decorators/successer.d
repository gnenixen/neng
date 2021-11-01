module engine.framework.bt.decorators.successer;

import engine.framework.bt.bt_decorator;

class CBTDSuccesser : CBTDecorator {
    mixin( TRegisterClass!CBTDSuccesser );
public:
    override EBTNodeStatus onProcess() {
        lchild.process();
        return EBTNodeStatus.SUCCESS;
    }
}