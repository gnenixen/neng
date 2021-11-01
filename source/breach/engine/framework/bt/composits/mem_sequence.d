module engine.framework.bt.composits.mem_sequence;

import engine.framework.bt.bt_composite;

class CBTCMemSequence : CBTComposite {
    mixin( TRegisterClass!CBTCMemSequence );
public:
    override EBTNodeStatus onProcess() {
        while ( iteration < children.length ) {
            EBTNodeStatus stat = children[iteration].process();

            if ( stat != EBTNodeStatus.SUCCESS ) {
                return stat;
            }

            iteration++;
        }

        iteration = 0;
        return EBTNodeStatus.SUCCESS;
    }
}