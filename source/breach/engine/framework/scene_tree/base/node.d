module engine.framework.scene_tree.base.node;

public:
import engine.core.object;
import engine.core.error;
import engine.core.containers;
import engine.core.typedefs;
import engine.core.log;
import engine.core.string;
import engine.core.signal;

import engine.framework.input;
import engine.framework.scene_tree.base.render;

enum ENodeMessageType {
    TICK,
    INPUT,
    RENDER,
    PHYSICS_TICK,
    PHYSICS_SYNC,
}

struct SNodeMessage {
    ENodeMessageType type;
    String custom;
    var data;

    this( ENodeMessageType type, String custom, var data ) {
        this.type = type;
        this.custom = custom;
        this.data = data;
    }

    this( ref return scope SNodeMessage from ) {
        type = from.type;
        custom = from.custom;
        data = from.data;
    }

    @disable this( this );
}

template TRegisterNodeMessageHandler( T ) {
    import std.string : format;

    enum TRegisterNodeMessageHandler = format(q{
        import std.stdio;
            if ( (%1$s).check( msg ) ) {
                if ( !(%1$s).isReverseProcess() ) {
                    (%1$s).process( msg, this );
                    foreach_reverse ( i, node; lchildren ) { node.messageProcess( msg ); }
                } else {
                    foreach_reverse ( i, node; lchildren ) { node.messageProcess( msg ); }
                    (%1$s).process( msg, this );
                }
            }
        },
        T.stringof
    );
}

private struct SNMPTick {
static:
    bool isReverseProcess() { return true; }
    bool check( SNodeMessage msg ) { return msg.type == ENodeMessageType.PHYSICS_TICK; }

    void process( SNodeMessage msg, CNode node ) {
        float delta = msg.data.as!float;
        node.ptick( delta );
    }
}

private struct SNMPSync {
static:
    bool isReverseProcess() { return false; }
    bool check( SNodeMessage msg ) { return msg.type == ENodeMessageType.PHYSICS_SYNC; }

    void process( SNodeMessage msg, CNode node ) {
        node.psync();
    }
}

private struct SNMTick {
static:
    bool isReverseProcess() { return false; }
    bool check( SNodeMessage msg ) { return msg.type == ENodeMessageType.TICK; }

    void process( SNodeMessage msg, CNode node ) {
        float delta = msg.data.as!float;
        node.tick( delta );
    }
}

private struct SNMInput {
static:
    bool isReverseProcess() { return false; }
    bool check( SNodeMessage msg ) { return msg.type == ENodeMessageType.INPUT; }

    void process( SNodeMessage msg, CNode node ) {
        CInputAction event = msg.data.as!CInputAction;
        node.input( event );
    }
}

private struct SNMRender {
static:
    bool isReverseProcess() { return false; }
    bool check( SNodeMessage msg ) { return msg.type == ENodeMessageType.RENDER; }

    void process( SNodeMessage msg, CNode node ) {
        if ( !node.bVisible ) {
            return;
        }

        CSceneTreeRender render = msg.data.as!CSceneTreeRender;
        assert( render );

        node.render( render );
    }
}

class CNode : CObject {
    mixin( TRegisterClass!CNode );
public:
    Signal!( CNode ) newChild;

protected:
    bool lbVisible = true;
    String lname;

    CNode lparent;
    Array!CNode lchildren;

public:
    ~this() {
        if ( isValid( lparent ) ) {
            lparent.removeChild( this );
        }

        lfreeChildrens();
    }

    void messageProcess( SNodeMessage msg ) {
        mixin(
            TRegisterNodeMessageHandler!SNMPTick,
            TRegisterNodeMessageHandler!SNMPSync,
            TRegisterNodeMessageHandler!SNMTick,
            TRegisterNodeMessageHandler!SNMInput,
            TRegisterNodeMessageHandler!SNMRender,
        );

        lmessageProcess( msg );
    }

    // Simple wrappers for messages
    protected {
        void lmessageProcess( SNodeMessage msg ) {}

        void ptick( float delta ) {}
        void psync() {}
        void tick( float delta ) {}
        void input( CInputAction action ) {}
        void render( CSceneTreeRender renderer ) {}
    }

    void addChild( CNode child ) {
        scope( failure ) return;
            SError.msg( !!child, "Trying to add null node" );
            SError.msg( child !is this, "Trying to add node ", lname, " to itself" );
            SError.msg( child.lparent !is this, "Trying to add node ", lname, " to it parent twice" );
            SError.msg( !child.hasNode( this ), "Trying to make circular reference of parent and child: ", lname, ", ", child.lname );
        
        if ( child.lparent ) {
            child.lparent.removeChild( child );
        }

        lchildren ~= child;
        child.lparent = this;

        newChild.emit( child );
    }

    bool removeChild( CNode child ) {
        scope( failure ) return false;
            SError.msg( !!child, "Trying to remove null node" );
            SError.msg( child !is this, "Trying to remove itself ", lname );
            SError.msg( child.lparent is this, "Trying to remove node ", lname, " but this node is not parent" );
        
        lchildren.remove( child );
        child.lparent = null;

        return true;
    }

    T getNode( T = CNode )( String path )
    if ( is( T : CNode ) ) {
        return Cast!T( lgetNodeReqursive( path.split( "/", true, 0 ) ) );
    }

    bool hasNode( String path ) {
        return getNode( path ) !is null;
    }

    bool hasNode( CNode node ) {
        scope( failure ) return false;
            SError.msg( !!node, "Trying to check null node" );
        
        return node.lparent is this;
    }


protected:
    void lfreeChildrens() {
        lchildren.free(
            ( node ) {
                if ( isValid( node ) ) {
                    node.lparent = null;
                    destroyObject( node );
                }
            }
        );
    }
    
    CNode lgetNodeReqursive( Array!String names ) {
        assert( names.length > 0 );

        uint i = 0;
        String cname;
        CNode cnode = this;

        while ( i < names.length ) {
            cname = names[i];
            i++;

            if ( cname == ".." ) {
                if ( !cnode.lparent ) {
                    return null;
                }

                cnode = cnode.lparent;
                continue;
            }

            foreach ( CNode n; cnode.lchildren ) {
                if ( n.lname == cname ) {
                    if ( i < names.length - 1 ) {
                        cnode = n;
                        break;
                    } else {
                        return cnode;
                    }
                }

                return null;
            }
        }

        return null;
    }

public:
    @property {
        void bVisible( bool bValue ) { lbVisible = bValue; }
        bool bVisible() { return lbVisible; }

        void parent( CNode nparent ) { lparent = nparent; }
        CNode parent() { return lparent; }

        void name( String nname ) { lname = nname; }
        String name() { return lname; }
    }
}
