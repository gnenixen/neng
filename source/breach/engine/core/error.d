/**
    Error system for simplify coe
*/
module engine.core.error;

private {
    import engine.core.log : log;
    import engine.core.memory : allocate, Memory;
}

static struct SError {
pragma( inline, true ) static __gshared:
public:
    void err( bool bVal ) {
        if ( !bVal ) {
            throwEx();
        }
    }

    void msg( Args... )( bool bVal, Args args )  {
        if ( !bVal ) {
            log.warning!Args( args );

            throwEx();
        }
    }

private:
    void throwEx() {
        Exception ex = allocate!Exception( "" );
        Memory.markOneFrame( cast( void* )ex );
        throw ex;
    }
}