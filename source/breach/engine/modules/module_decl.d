module engine.modules.module_decl;

private {
    import engine.core.object;
}

enum EModuleInitPhase {
    PRE,        //Init after core initialized
    NORMAL,     //Normal init after engine base setup
    POST,       //Init after framework and scene tree
}

abstract class AModuleDeclaration : CObject {
    mixin( TRegisterClass!AModuleDeclaration );
public:
    string name;
    EModuleInitPhase initPhase;

    void initialize() {}
    void destruct() {}
    void update( float delta ) {}
}