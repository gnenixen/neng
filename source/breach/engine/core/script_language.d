module engine.core.script_language;

public:
import engine.core.containers.array;
import engine.core.typedefs;
import engine.core.object;

abstract class AScriptLanguage : CObject {
    mixin( TRegisterClass!( AScriptLanguage, Singleton ) );
public:
    void destroy( ID id );
    void postUpdate();

    ID script_compile( String filepath );
    bool script_execute( ID id );

    bool class_hasMethod( String mname );

    ID instance_create( String classname );
    var instance_call( String mname, VArray args );
}
/*
class CCDC_Script : AClassDescriptionCategory {
    Array!CRSMethod methods;

    ~this() {
        methods.free();
    }

    void method( string name ) {
        assert( rclass );
        rMethod method = rclass.getMethod( name );
        assert( method, "Invalid class method " ~ '"' ~ rclass.name ~ "." ~ name ~ '"' );

        methods ~= cast()method;
    }
}

class COE_Script : AObjectExtension {
private:
    CScript lscript;
    CScriptInstance lscriptInstance;

public:
    this( CObject iinstance ) {
        super( iinstance );
    }

    ~this() {
        destroyObject( lscriptInstance );
    }

    var call( Args... )( string mname, Args args ) {
        return lscriptInstance.call( mname, args );
    }

    @property {
        CScript script() {
            return lscript;
        }

        void script( CScript iscript ) {
            if ( lscript ) {
                destroyObject( lscriptInstance );
                destroyObject( lscript );
            }

            lscript = iscript;
            lscriptInstance = lscript.instance();
        }
    }
}*/

pragma( inline, true )
static __gshared AScriptLanguage GScriptLanguage() {
    return AScriptLanguage.sig;
}
/*
class CScript : CObject {
    mixin( TRegisterClass!CScript );
protected:
    ID scriptId;
    string lpath;

public:
    this( string filepath ) {
        scriptId = GScriptLanguage.script_create( filepath );
    }

    ~this() {
        GScriptLanguage.destroy( scriptId );
    }

    bool hasMethod( string mname ) {
        return GScriptLanguage.script_hasMethod( id, mname );
    }

    CScriptInstance instance() {
        return newObject!CScriptInstance( scriptId );
    }

    @property pragma( inline, true ) {
        string path() {
            return lpath;
        }
    }
}

class CScriptInstance : CObject {
    mixin( TRegisterClass!CScriptInstance );
protected:
    ID scriptId;
    ID instanceId;

public:
    this( ID iscriptId ) {
        scriptId = iscriptId;
        instanceId = GScriptLanguage.instance_create( scriptId );
    }

    ~this() {
        GScriptLanguage.destroy( instanceId );
    }

    var call( Args... )( string mname, Args args ) {
        var res;
        
        if ( hasMethod( mname ) ) {
            res = GScriptLanguage.instance_call( instanceId, mname, toVArray( args ) );
        }

        return res;
    }

    var call( string mname, VArray args ) {
        var res;
        
        if ( hasMethod( mname ) ) {
            res = GScriptLanguage.instance_call( instanceId, mname, args );
        }

        return res;
    }

    bool hasMethod( string mname ) {
        return GScriptLanguage.script_hasMethod( scriptId, mname );
    }
}*/
