module engine.core.callable;

import engine.core.object;
import engine.core.log;
import engine.core.reflection;
import engine.core.utils.ustruct;

struct SCallable {
    mixin( TRegisterStruct!SCallable );
public:
    String name;
    ID id = ID_INVALID;

    var call( Args... )( Args args ) {
        CObject obj = GetObjectByID( id );
        if ( !obj ) {
            log.error( "Invalid callable object!" );
            return var();
        }

        return obj.call!Args( name, args );
    }

    bool isNull() { return id == ID_INVALID; }
}

struct SCallableWithParams {
    mixin( TRegisterStruct!SCallableWithParams );
public:
    String name;
    ID id = ID_INVALID;
    rMethod.SInvokeParams params;

    var call( Args... )( Args args ) {
        CObject obj = GetObjectByID( id );
        if ( !obj ) {
            log.error( "Invalid callable object!" );
            return var();
        }

        if ( params.size == 0 ) {
            return obj.call!Args( name, args );
        }

        return obj.call( name, params );
    }

    bool isNull() { return id == ID_INVALID; }
}
