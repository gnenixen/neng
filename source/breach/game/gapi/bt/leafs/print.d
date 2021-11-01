module game.gapi.bt.leafs.print;

import engine.core.log;

import engine.framework.bt;

class CBTLPrint : CBTLeaf {
    mixin( TRegisterClass!CBTLPrint );
private:
    String txt;

public:
    this( String itxt ) {
        txt = itxt;
    }

protected:
    override EBTNodeStatus onProcess() {
        log.info( txt );

        return EBTNodeStatus.SUCCESS;
    }
}
