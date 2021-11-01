module engine.core.typedefs;

import engine.core.containers.array;
import engine.core.containers.dictionary;
import engine.core.variant;
import engine.core.utils.ustruct;
import engine.core.string;

template RawDataN( size_t chunk ) {
    alias RawDataN = Array!( ubyte, chunk );
}

template VArrayN( size_t chunk ) {
    alias VArrayN = Array!( var, chunk );
}

template VDictT( T ) {
    alias VDictT = Dict!( var, T );
}

alias RawData = RawDataN!32;
alias VArray = VArrayN!32;

VArray toVArray( Args... )( Args args ) {
    VArray varray;
    varray.reserve( Args.length );

    foreach ( arg; args ) {
        varray ~= SVariant( arg );
    }

    return varray;
}