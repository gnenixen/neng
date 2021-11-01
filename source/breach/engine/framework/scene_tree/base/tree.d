module engine.framework.scene_tree.base.tree;

import engine.core.object;

import engine.framework.scene_tree.base.node;

class CSceneTree : CObject {
    mixin( TRegisterClass!CSceneTree );
private:
    CNode lroot;

public:
    ~this() {
        destroyObject( lroot );
    }

    void message( ENodeMessageType type, String custom, var data ) {
        if ( isValid( lroot ) ) {
            lroot.messageProcess( SNodeMessage( type, custom, data ) );
        }
    }

    @property {
        void root( CNode nroot ) { lroot = nroot; }
        CNode root() { return lroot; }
    }
}
