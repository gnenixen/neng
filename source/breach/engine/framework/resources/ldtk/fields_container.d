module engine.framework.resources.ldtk.fields_container;

import engine.core.object;
import engine.core.containers;
import engine.core.variant;

import engine.framework.resources.json;

interface ILDTKField {}

class CLDTKField( T ) : CObject, ILDTKField {
    mixin( TRegisterClass!( CLDTKField!T ) );
public:
    T value;
}

class CLDTKArrayField( T ) : CObject, ILDTKField {
    mixin( TRegisterClass!( CLDTKArrayField!T ) );
public:
    Array!( CLDTKField!T ) values;
}

class CLDTKFieldsContainer : CObject {
    mixin( TRegisterClass!CLDTKFieldsContainer );
private:
    Array!ILDTKField gc;
    Dict!( ILDTKField, String ) fields;
    Dict!( ILDTKField, String ) arrayFields;

public:
    void addField( T )( String name, T field ) {
        CLDTKField!T nfield = newObject!( CLDTKField!T )( field );
        fields.set( name, nfield );
        gc ~= nfield;
    }

    void addField( T )( String name, CLDTKField!T field ) {
        fields.set( name, field );
        gc ~= field;
    }

    CLDTKField!T getField( T )( String name ) {
        if ( !fields.has( name ) ) {
            log.error( "Field \"", name, "\" does not exist" );
            return null;
        }

        CLDTKField!T field = Cast!( CLDTKField!T )( fields.get( name ) );
        if ( !field ) {
            log.error( "Field \"", name, "\" is not of type ", T.typename );
            return null;
        }

        return field;
    }

    void addArrayField( T )( String name, CLDTKArrayField!T field ) {
        arrayFields.set( name, field );
        gc ~= field;
    } 

    CLDTKArrayField!T getArrayField( T )( String name ) {
        if ( !arrayFields.has( name ) ) {
            log.error( "Field \"", name, "\" does not exist" );
            return null;
        }

        CLDTKArrayField!T field = Cast!( CLDTKArrayField!T )( arrayFields.get( name ) );
        if ( !field ) {
            log.error( "Field \"", name, "\" is not of type ", T.typename );
            return null;
        }

        return field;
    }

protected:
    void parseFields( CJSONValue* json ) {
        foreach ( field; json.arr ) {
            String ftype = field.get("__type").as!String;
            String fname = field.get("__identifier").as!String;
            CJSONValue* fvalue = field.get("__value");

            if ( ftype.find( rs!"Array", 0 ) ) {
                if ( ftype == "Array<Int>" ) {
                    CLDTKArrayField!int values = newObject!( CLDTKArrayField!int )();
                    foreach ( v; fvalue.arr ) {
                        if ( v.isNull() ) {
                            //values.values ~= null;
                        } else {
                            CLDTKField!int f = newObject!( CLDTKField!int )();
                            f.value = v.as!int;
                            values.values ~= f;
                        }
                    }

                    addArrayField( fname, values );
                }
                else if ( ftype == "Array<Float>" ) {
                    CLDTKArrayField!float values = newObject!( CLDTKArrayField!float )();
                    foreach ( v; fvalue.arr ) {
                        if ( v.isNull() ) {
                            //values.values ~= null;
                        } else {
                            CLDTKField!float f = newObject!( CLDTKField!float )();
                            f.value = v.as!float;
                            values.values ~= f;
                        }
                    }

                    addArrayField( fname, values );
                }
                else if ( ftype == "Array<Bool>" ) {
                    CLDTKArrayField!bool values = newObject!( CLDTKArrayField!bool )();
                    foreach ( v; fvalue.arr ) {
                        if ( v.isNull() ) {
                            //values.values ~= null;
                        } else {
                            CLDTKField!bool f = newObject!( CLDTKField!bool )();
                            f.value = v.as!bool;
                            values.values ~= f;
                        }
                    }

                    addArrayField( fname, values );
                }
                else if ( ftype == "Array<String>" ) {
                    CLDTKArrayField!String values = newObject!( CLDTKArrayField!String )();
                    foreach ( v; fvalue.arr ) {
                        if ( v.isNull() ) {
                            //values.values ~= null;
                        } else {
                            CLDTKField!String f = newObject!( CLDTKField!String )();
                            f.value = v.as!String;
                            values.values ~= f;
                        }
                    }

                    addArrayField( fname, values );
                }
            }

        }
    }
}
