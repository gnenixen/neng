module engine.framework.bt.behavior_tree;

import engine.core.object;
import engine.core.containers;
import engine.core.string;

import engine.framework.bt.bt_node;
import engine.framework.bt.bt_composite;
import engine.framework.bt.bt_decorator;

alias BTBlackboard = Dict!( var, String );

class CBehaviorTree : CObject {
    mixin( TRegisterClass!CBehaviorTree );
public:
    CBTNode root;
    BTBlackboard blackboard;

protected:
    bool bProcess = true;

public:
    ~this() {
        destroyObject( root );
    }

    EBTNodeStatus process() {
        if ( root && bProcess ) {
            return root.process();
        }

        return EBTNodeStatus.FAILURE;
    }

    void resume() {
        bProcess = true;
    }

    void stop() {
        bProcess = false;
    }
}

class CBTBuilder : CObject {
    mixin( TRegisterClass!CBTBuilder );
protected:
    CBTBuilder parent;
    CBehaviorTree tree;
    CBTNode lroot;

public:
    this( CBTBuilder iparent, CBehaviorTree itree ) {
        parent = iparent;
        tree = itree;
    }

    final CBTBuilder leaf( T, Args... )( Args args )
    if ( is( T : CBTLeaf ) ) {
        T t = newObject!T( args );
        t.tree = tree;

        return leaf( t );
    }

    final CBTBuilder decorator( T, Args... )( Args args )
    if ( is( T : CBTDecorator ) ) {
        T t = newObject!T( args );
        t.tree = tree;

        return decorator( t );
    }

    final CBTBuilder composite( T, Args... )( Args args )
    if ( is( T : CBTComposite ) ) {
        T t = newObject!T( args );
        t.tree = tree;
        
        return composite( t );
    }

    final CBTBuilder end() {
        return parent;
    }

    final CBTNode build() {
        if ( parent ) {
            return parent.build();
        }

        if ( tree ) {
            tree.root = root;
        }

        return root;
    }


    CBTBuilder leaf( CBTLeaf lf ) {
        assert( false, "Cannot use leaf as bt root!" );
    }

    CBTBuilder decorator( CBTDecorator dec ) {
        assert( lroot is null );

        CBTDecoratorBuilder builder = newObject!CBTDecoratorBuilder( this, dec, tree );
        lroot = builder.root;

        return builder;
    }

    CBTBuilder composite( CBTComposite comp ) {
        assert( lroot is null );

        CBTCompositeBuilder builder = newObject!CBTCompositeBuilder( this, comp, tree );
        lroot = builder.root;

        return builder;
    }

    CBTNode root() {
        return lroot;
    }
}

class CBTCompositeBuilder : CBTBuilder {
    mixin( TRegisterClass!CBTCompositeBuilder );
protected:
    CBTComposite lcomposite;

public:
    this( CBTBuilder iparent, CBTComposite icomposite, CBehaviorTree itree ) {
        super( iparent, itree );
        lcomposite = icomposite;
    }

    override CBTBuilder leaf( CBTLeaf lf ) {
        lcomposite.children ~= lf;
        return this;
    }

    override CBTBuilder decorator( CBTDecorator dec ) {
        CBTDecoratorBuilder db = newObject!CBTDecoratorBuilder( this, dec, tree );
        lcomposite.children ~= dec;
        return db;
    }

    override CBTBuilder composite( CBTComposite icomp ) {
        CBTBuilder comp = newObject!CBTCompositeBuilder( this, icomp, tree );
        lcomposite.children ~= icomp;
        return comp;
    }

    override CBTNode root() {
        return lcomposite;
    }
}

class CBTDecoratorBuilder : CBTBuilder {
    mixin( TRegisterClass!CBTDecoratorBuilder );
protected:
    CBTDecorator ldecorator;

public:
    this( CBTBuilder iparent, CBTDecorator idecorator, CBehaviorTree itree ) {
        super( iparent, itree );
        ldecorator = idecorator;
    }

    override CBTBuilder leaf( CBTLeaf lf ) {
        ldecorator.child = lf;
        return this;
    }

    override CBTBuilder decorator( CBTDecorator dec ) {
        CBTDecoratorBuilder db = newObject!CBTDecoratorBuilder( this, dec, tree );
        ldecorator.child = dec;
        return db;
    }

    override CBTBuilder composite( CBTComposite icomp ) {
        CBTBuilder comp = newObject!CBTCompositeBuilder( this, icomp, tree );
        ldecorator.child = icomp;
        return comp;
    }

    override CBTNode root() {
        return ldecorator;
    }
}
