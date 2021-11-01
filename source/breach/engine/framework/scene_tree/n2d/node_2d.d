module engine.framework.scene_tree.n2d.node_2d;

public:
import engine.core.math;

import engine.framework.scene_tree.base.node;

class CNode2D : CNode {
    mixin( TRegisterClass!CNode2D );
public:
    STransform2D transform;

public:
    this() { super(); }

    STransform2D worldTransform() {
        if ( CNode2D n = Cast!CNode2D( parent ) ) {
            STransform2D rt = transform;
            STransform2D pt = n.worldTransform();

            rt.pos += pt.pos;
            rt.size *= pt.size;
            rt.angle += pt.angle;

            return rt;
        }

        return transform;
    }
}
