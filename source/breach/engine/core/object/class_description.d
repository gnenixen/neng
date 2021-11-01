module engine.core.object.class_description;

import engine.core.memory.memory : allocate, deallocate;
import engine.core.containers.array;
import engine.core.reflection;

abstract class AClassDescriptionCategory {
protected:
    CRSClass rclass;

public:
    void bind( CRSClass irclass ) {
        assert( irclass );
        assert( !rclass );
        rclass = irclass;
    }
}

/**
    Descript class by categories,
    used for MPA, script methods
    export and other
*/
class CClassDescription {
public:
    Array!AClassDescriptionCategory categories;

    CRSClass rclass;

public:
    ~this() {
        categories.free(
            ( cat ) { deallocate( cat ); }
        );
    }

    void bind( rClass irclass ) {
        assert( !rclass );
        rclass = cast()irclass;
    }

    T get( T )() {
        foreach ( cat; categories ) {
            T t = cast( T )cat;
            if ( t ) {
                return t;
            }
        }

        T cat = allocate!T();
        cat.bind( rclass );
        categories ~= cat;
        return cat;
    }

    bool has( T )() {
        foreach ( cat; categories ) {
            T t = cast( T )cat;
            if ( t ) {
                return true;
            }
        }

        return false;
    }
}
