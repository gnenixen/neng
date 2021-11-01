module engine.framework.bt.decorators.until_fail;

import engine.framework.bt.bt_decorator;

class CBTDUntilFail : CBTDecorator {
    mixin( TRegisterClass!CBTDUntilFail );
public:
    override EBTNodeStatus onProcess() {
        while ( true ) {
            EBTNodeStatus stat = lchild.process();

            if ( stat == EBTNodeStatus.FAILURE ) {
                return EBTNodeStatus.FAILURE;
            }
        }
    }
}