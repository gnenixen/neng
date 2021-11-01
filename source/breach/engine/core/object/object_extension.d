module engine.core.object.object_extension;

import engine.core.object._object;
import engine.core.containers.array;

abstract class AObjectExtension {
protected:
    CObject linstance;

public:
    this( CObject iinstance ) {
        linstance = iinstance;
    }
}

class CObjectExtensionsHandler {
private:
    Array!AObjectExtension lextensions;

public:
    void register( AObjectExtension ext ) {
        lextensions.appendUnique( ext );
    }

    AObjectExtension get( T )()
    if ( is( T : AObjectExtension ) ) {
        return null;
    }
}