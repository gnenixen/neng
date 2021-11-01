module engine.framework.bt.decorators.failer;

import engine.framework.bt.bt_decorator;

class CBTDFailer : CBTDecorator {
    mixin( TRegisterClass!CBTDFailer );
public:
    override EBTNodeStatus onProcess() {
        lchild.process();
        return EBTNodeStatus.FAILURE;
    }
}