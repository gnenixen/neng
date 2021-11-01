module engine.core.utils.typeinfo;

/**
    Check if second typeinfo base in some level for first
*/
bool isBaseClassTypeInfoFor( TypeInfo r, TypeInfo l ) {
    TypeInfo_Class cr = cast( TypeInfo_Class )r;
    TypeInfo_Class cl = cast( TypeInfo_Class )l;

    if ( cr && cl ) {
        if ( cr is cl ) {
            return true;
        }

        while ( cr !is null ) {
            if ( cr.base is cl ) {
                return true;
            }

            cr = cr.base;
        }
    }

    return false;
}

bool isSameRawTypes( TypeInfo r, TypeInfo l ) {
    bool checkStringCmp() {
        string rn = r.toString();
        string ln = l.toString();

        return  ( rn == "char[]" || rn == "immutable(char)[]" ) &&
                ( ln == "char[]" || ln == "immutable(char)[]" );
    }
    
    if ( !r || !l ) {
        return false;
    }

    return checkStringCmp() || r is l;
}