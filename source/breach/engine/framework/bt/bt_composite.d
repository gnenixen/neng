module engine.framework.bt.bt_composite;

import engine.core.containers.array;

public import engine.framework.bt.bt_node;

class CBTComposite : CBTNode {
    mixin( TRegisterClass!( CBTComposite ) );
public:
    Array!CBTNode children;

protected:
    int iteration = 0;

public:
    ~this() {
        children.free(
            ( node ) { destroyObject( node ); }
        );
    }
}