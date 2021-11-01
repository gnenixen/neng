module engine.core.object.serialize;

//import engine.core.object._object;
import engine.core.object.class_description;
//import engine.core.typedefs;
import engine.core.containers.array;
import engine.core.string;
/*
void test() {
    CObjectsPool op = newObject!CObjectsPool();
    // WOOOOOOORK 
    COE_Serialize se = op.getExtension!COE_Serialize;
    CSerializeBackend backend = newObject!CSerializeBackend;

    RawData res = se.serialize( backend );

    CSomeObject obj = newObject!CSomeObject();
    COE_Health health = obj.addExtension!COE_Health;
    health.setMaxHealth( 100 );
}
*/
/**
    Extends object with custom variables and functions,
    not whole class, just single object
*/

class CCDC_Serialize : AClassDescriptionCategory {
public:
    Array!String lvalues;

public:
    void register( String name ) {
        lvalues ~= name;
    }

    void registerArray( String name ) {}

    void register( string name ) { register( String( name ) ); }
    void registerArray( string name ) { registerArray( String( name ) ); }
}
