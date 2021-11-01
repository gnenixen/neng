module engine.core.utils.ustruct;

template TRegisterStruct( T ) {
    enum TRegisterStruct = "
    @disable this( this );
        
    this( ref return scope typeof( this ) src ) {
        foreach ( i, ref field; src.tupleof )
            this.tupleof[i] = field;
    }
    ";
}
