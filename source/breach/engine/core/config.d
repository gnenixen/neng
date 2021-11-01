module engine.core.config;

import engine.core.object;
import engine.core.containers.dictionary;
import engine.core.signal;
import engine.core.variant;
import engine.core.utils.ustruct;

private struct SConfigVal {
    mixin( TRegisterStruct!SConfigVal );
public:
    bool bConst = false;
    var data;
}

class CConfig : CObject {
    mixin( TRegisterClass!( CConfig ) );
public:
    Signal!( String, var ) onValueUpdated;

private:
    Dict!( SConfigVal, String ) data;

public:
    CConfig set( T )( String name, T val, bool bConst = false ) {
        //if ( SConfigVal* res = name in data ) {
            //if ( !res.bConst ) {
                //res.data = val;
            //}

            return this;
        //}

        //static if ( is( T == var ) ) {
            //data[name] = SConfigVal( bConst, val );
            //onValueUpdated.emit( name, val );
        //} else {
            //var sval = var( val );
            //data[name] = SConfigVal( bConst, sval );
            //onValueUpdated.emit( name, sval );
        //}

        //return this;
    }

    //T get( T )( String name ) {
        //if ( SConfigVal* res = name in data ) {
            //if ( !res.data.isEmpty() ) {
                //return res.data.as!T;
            //}
        //}

        //return T.init;
    //}

    void setv( String name, var val ) {
        set( name, val, false );
    }

    var getv( String name ) {
        //return get!var( name );
        return var();
    }

private:
    static void lclassDescription( CClassDescription descr ) {
        /*import engine.core.script_language;

        CCDC_Script script = descr.get!CCDC_Script;
        script.method( "singleton" );
        script.method( "setv" );
        script.method( "getv" );*/
    }
}
