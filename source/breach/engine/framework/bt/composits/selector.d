module engine.framework.bt.composits.selector;

import engine.framework.bt.bt_composite;

class CBTCSelector : CBTComposite {
    mixin( TRegisterClass!CBTCSelector );
public:
    override void onInit() {
        iteration = 0;
    }

    override EBTNodeStatus onProcess() {
        while ( iteration < children.length ) {
            EBTNodeStatus stat = children[iteration].process();

            if ( stat != EBTNodeStatus.FAILURE ) {
                return stat;
            }

            iteration++;
        }

        return EBTNodeStatus.FAILURE;
    }
}