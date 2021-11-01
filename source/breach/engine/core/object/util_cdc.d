module engine.core.object.util_cdc;

import engine.core.object._object;

import engine.core.variant;
import engine.core.containers;

class CCDC_ClassDebugInfo : AClassDescriptionCategory {
private:
    Dict!( var, string ) values;

public:
    T get( T )( string name, T defVal ) {
        if ( !values.has( name ) ) {
            values.set( name, var( defVal ) );
            return defVal;
        }

        return values[name].as!T;
    }

    void set( T )( string name, T val ) {
        values.set( name, var( val ) );
    }
}

/**
    Associate member with property,
    usefull when property set realize
    some logic, like prhysics position
    set
*/
class CCDC_MPA : AClassDescriptionCategory {
    Dict!( string, string ) data;

    ~this() {
        data.free();
    }

    void register( string mem, string prop ) {
        assert( !data.has( mem ), "Member already registered: " ~ mem );
        data.set( mem, prop );
    }

    rProperty getMemberAssociatedProperty( string mem ) {
        return rclass.getProperty( data.get( mem, "" ) );
    }
}

class CCDC_ObjectInit : AClassDescriptionCategory {
    bool bCanOverride = true;

    bool function() isNeedCustomInit;
    bool function( CObject ) objectInit;
    bool function( CObject ) isCanDestroy;

    ~this() {
        this.isNeedCustomInit = null;
        this.objectInit = null;
        this.isCanDestroy = null;
    }
}