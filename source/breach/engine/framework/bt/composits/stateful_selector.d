module engine.framework.bt.composits.stateful_selector;

import engine.framework.bt.bt_composite;

class CBTCStatefulSelector : CBTComposite {
    mixin( TRegisterClass!CBTCStatefulSelector );
public:
    override EBTNodeStatus onProcess() {
        while ( iteration < children.length ) {
            EBTNodeStatus stat = children[iteration].process();

            if ( stat != EBTNodeStatus.FAILURE ) {
                return stat;
            }

            iteration++;
        }

        iteration = 0;
        return EBTNodeStatus.FAILURE;
    }
}