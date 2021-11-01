module engine.modules;

public:
import engine.modules.register;
import engine.modules.module_decl;

private import engine.core : destroyObject, log, Array, isValid;

static __gshared struct GModules {
private static __gshared:
    Array!AModuleDeclaration modules;

public static __gshared:
    void registerStaticModules() {
        modules_registerStatic();
    }

    void initialize( EModuleInitPhase initPhase ) {
        foreach ( md; modules ) {
            if ( md.initPhase == initPhase ) {
                md.initialize();
                log.info( md.name, " initialized" );
            }
        }
    }

    void destruct() {
        modules.free(
            ( md ) {
                if ( isValid( md ) ) {
                    md.destruct();
                    destroyObject( md );
                }
            }
        );
    }

    void update( float delta ) {
        foreach ( md; modules ) {
            md.update( delta );
        }
    }

    void regModule( AModuleDeclaration md ) {
        assert( isValid( md ) );
        modules.appendUnique( md );
    }
}
