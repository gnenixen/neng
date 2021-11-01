module engine.framework.bt.bt_decorator;

public import engine.framework.bt.bt_node;

class CBTDecorator : CBTNode {
    mixin( TRegisterClass!CBTDecorator );
protected:
    CBTNode lchild;

public:
    ~this() {
        destroyObject( lchild );
    }

    @property {
        void child( CBTNode ichild ) {
            lchild = ichild;
        }
    }
}