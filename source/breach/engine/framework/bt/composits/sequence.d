module engine.framework.bt.composits.sequence;

import engine.framework.bt.bt_composite;

class CBTCSequence : CBTComposite {
    mixin( TRegisterClass!CBTCSequence );
public:
    override void onInit() {
        iteration = 0;
    }

    override EBTNodeStatus onProcess() {
        while ( iteration < children.length ) {
            EBTNodeStatus stat = children[iteration].process();

            if ( stat != EBTNodeStatus.SUCCESS ) {
                return stat;
            }

            iteration++;
        }

        return EBTNodeStatus.SUCCESS;
    }
}