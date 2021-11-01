module engine.framework.bt.decorators.until_success;

import engine.framework.bt.bt_decorator;

class CBTDUntilSuccess : CBTDecorator {
    mixin( TRegisterClass!CBTDUntilSuccess );
public:
    override EBTNodeStatus onProcess() {
        while ( true ) {
            EBTNodeStatus stat = lchild.process();

            if ( stat == EBTNodeStatus.SUCCESS ) {
                return EBTNodeStatus.SUCCESS;
            }
        }
    }
}