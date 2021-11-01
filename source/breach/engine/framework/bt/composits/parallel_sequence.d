module engine.framework.bt.composits.parallel_sequence;

import engine.framework.bt.bt_composite;

class CBTCParallelSequence : CBTComposite {
    mixin( TRegisterClass!CBTCParallelSequence );
protected:
    bool bUseSuccessFailPolicy = false;
    bool bSuccessOnAll = true;
    bool bFailOnAll = true;

    int minSuccess = 0;
    int minFail = 0;

    override EBTNodeStatus onProcess() {
        int minimumSuccess = minSuccess;
        int minimumFail = minFail;

        if ( bUseSuccessFailPolicy ) {
            if ( bSuccessOnAll ) {
                minimumSuccess = cast( int )children.length;
            } else {
                minimumSuccess = 1;
            }

            if ( bFailOnAll ) {
                minimumFail = cast( int )children.length;
            } else {
                minimumFail = 1;
            }
        }

        int totalSuccess = 0;
        int totalFail = 0;

        foreach ( child; children ) {
            EBTNodeStatus stat = child.process();

            if ( stat == EBTNodeStatus.SUCCESS ) {
                totalSuccess++;
            } else if ( stat == EBTNodeStatus.FAILURE ) {
                totalFail++;
            }
        }

        if ( totalSuccess >= minimumSuccess ) {
            return EBTNodeStatus.SUCCESS;
        } else if ( totalFail >= minimumFail ) {
            return EBTNodeStatus.FAILURE;
        }
        
        return EBTNodeStatus.RUNNING;
    }
}