module engine.core.object.util_classes;

import engine.core.object._object;
import engine.core.object.pool;

class CVoidPtrObject : CObject {
    mixin( TRegisterClass!CVoidPtrObject );
private:
    static void lclassDescription( CClassDescription descr ) {}

public:
    void* data;

    this( void* idata ) {
        data = idata;
    }
}

class CObjectIdHandler : CObject {
    mixin( TRegisterClass!CObjectIdHandler );
private:
    static void lclassDescription( CClassDescription descr ) {}

public:
    ID hid;

    this( ID iid ) {
        hid = iid;
    }
}

ID wrapToVPO( void* data ) {
    return NewObject!CVoidPtrObject( data ).id;
}
