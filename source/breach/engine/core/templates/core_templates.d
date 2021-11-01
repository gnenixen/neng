module engine.core.templates.core_templates;

import engine.core.object;

void Swap( T )( ref T a, ref T b ) {
    T t = a;
    a = b;
    b = t;
}

bool isType( T, U )( U obj ) {
    return Cast!T( obj ) !is null;
}
