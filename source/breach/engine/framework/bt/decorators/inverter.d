module engine.framework.bt.decorators.inverter;

import engine.framework.bt.bt_decorator;

class CBTDInverter : CBTDecorator {
    mixin( TRegisterClass!CBTDInverter );
public:
    override EBTNodeStatus onProcess() {
        EBTNodeStatus stat = lchild.process();

        if ( stat == EBTNodeStatus.SUCCESS ) {
            return EBTNodeStatus.FAILURE;
        } else if ( stat == EBTNodeStatus.FAILURE ) {
            return EBTNodeStatus.SUCCESS;
        }

        return stat;
    }
}