module engine.core.resource.res;

public {
    import engine.core.object;
    import engine.core.signal;
    import engine.core.containers;
}

enum EResourceLoadPhase {
    NONE,
    LOADING,
    FAILED,
    SUCCESS,
}

abstract class AResourceOperator : CObject {
    mixin( TRegisterClass!AResourceOperator );
public:
abstract:
    void load( CResource res, String path );

    /**
        Returns clear instance of resource,
        thats passed in load method
    */
    CResource newPreloadInstance();

    void hrSwap( CResource o, CResource n );

    /**
        Operator must define handlable extensions
    */
    Array!String extensions();
}

class CResource : CObject {
    mixin( TRegisterClass!CResource );
public:
    Signal!() hrUpdated;

public:
    String path;
    Array!int ints;
    EResourceLoadPhase loadPhase = EResourceLoadPhase.NONE;

private:
    static void lclassDescription( CClassDescription descr ) {
        CCDC_Serialize sr = descr.get!CCDC_Serialize();
        sr.register( "path" );
        sr.register( "ints" );
    }

public:
    bool isValid() {
        return loadPhase == EResourceLoadPhase.SUCCESS && isValidImpl();
    }

protected:
    /**
        Informate about resource
        specific validation
    */
    bool isValidImpl() { return true; }
}
