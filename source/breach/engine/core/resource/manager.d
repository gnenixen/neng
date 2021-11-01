module engine.core.resource.manager;

import engine.core.containers;
import engine.core.object;
import engine.core.os;
import engine.core.fs;
import engine.core.thread_pool;
import engine.core.log;

import engine.core.resource.res;

private {
    /**
        Message passed to job
    */
    class CResourceLoadMSG {
    public:
        ID resource;
        ID operator;
        String path;
    }
}

class CResourceManager : CObject {
    mixin( TRegisterClass!( CResourceManager, Singleton ) );
protected:
    /**
        Caching loaded resources for future usage,
        also make hot reload mechanism simpler,
        just by updating single instance of resources
    */
    Array!CResource resources;

    /**
        Resource operators, associated with file 
        extension
    */
    Dict!( AResourceOperator, String ) operators;

    /**
        Handles association between path and
        resources for hot reload mechanism
    */
    Dict!( CResource, String ) hrCache;

    /**
        Associate old resource (key) and new resource (value)
        for swapping at update
    */
    Dict!( CResource, CResource ) hrUpdate;

    /**
        Mutex for sinchronization resources and
        files adding in thread pool operation 
        loading process
    */
    Mutex mutex;

public:
    this() {
        mutex = NewObject!Mutex();

        GFileSystem.fileUpdated.connect( &hotReloadFileUpdateWatcher );
    }

    ~this() {
        DestroyObject( mutex );
    }

    void register( AResourceOperator operator ) {
        assert( operator, "Passed invalid resource operator" );

        Array!String extensions = operator.extensions;
        assert( extensions.length > 0, "Resource operator must contains >= 1 extensions" );

        foreach( ext; extensions ) {
            assert( !operators.has( ext ), CString( "Operator for extenstion", ext, "already registered" ) );

            operators.set( ext, operator );
        }
    }

    void update() {
        // Swap old and new resources
        foreach ( k, v; hrUpdate ) {
            if ( v.loadPhase == EResourceLoadPhase.FAILED ) {
                hrUpdate.remove( v );
                continue;
            }
            
            if ( isResourceValid( v ) ) {
                AResourceOperator operator = getOperator( k.path.extension );
                assert( operator );

                operator.hrSwap( k, v );
                DestroyObject( v );
                hrUpdate.remove( k );

                k.hrUpdated.emit();
            }
        }
    }

    /**
        Basic loading function, every other load function
        must fallback to it
        Params:
            path - file loading path
            bStaticLoading - load file in givent thread
            if true, or in separated if is false
    */
    CResource loadBasic( String path, bool bStaticLoading = false, bool bCache = true ) {
        CResource result;

        // Try to get resource from cache
        if ( bCache ) {
            result = getResource( path );
            if ( result ) return result;
        }

        // Check is file exists
        if ( !GFileSystem.isFileExists( path ) ) {
            log.error( "File doesn't exists: ", path );
            return null;
        }

        // Supports only ext based loading, then refuse
        // path if extension is not defined
        String extension = path.extension;
        if ( extension.length == 0 ) {
            log.error( "Not found extension for path: ", path );
            return null;
        }

        // Try to find operator for given extension
        AResourceOperator operator = getOperator( extension );
        if ( !operator ) {
            log.error( "Canno't find operator for extension: ", extension );
            return null;
        }

        result = operator.newPreloadInstance();
        assert( result, "Operator instanced null resource instance!" );

        result.loadPhase = EResourceLoadPhase.LOADING;
        result.path = path;

        // Register resource in pool
        if ( bCache ) {
            addResource( result );
        }

        // Run a job if static loading is false, otherwice just load
        if ( !bStaticLoading ) {
            addLoadJob( result, operator, path );
        } else {
            operator.load( result, path );
        }

        return result;
    }

private:
    void addResource( CResource res ) {
        bool bRes;

        synchronized ( mutex ) {
            bRes = resources.appendUnique( res );
            hrCache.set( res.path, res );
        }

        assert( bRes, "Double adding resource!" );
    }

    void removeResource( CResource res ) {
        synchronized ( mutex ) {
            resources.remove( res );
        }
    }

    /**
        Try to find cached resource by path,
        returns null if resource not in cache
    */
    CResource getResource( String path ) {
        CResource ret;

        synchronized ( mutex ) {
            int idx = resources.find!"a == b.path"( path );
            if ( idx != -1 ) {
                ret = resources[idx];
            }
        }

        return ret;
    }

    AResourceOperator getOperator( String ext ) {
        return operators.get( ext, null );
    }

    void addLoadJob( CResource resource, AResourceOperator operator, String path ) {
        CResourceLoadMSG msg = allocate!CResourceLoadMSG();
        msg.resource = resource.id;
        msg.operator = operator.id;
        msg.path = path;

        GThreadPool.add( &lloadJob, msg );
    }

    /**
        Loading job for thread pool
    */
    static void lloadJob( CResourceLoadMSG msg ) {
        CResource resource = GetObjectByID!CResource( msg.resource );
        AResourceOperator operator = GetObjectByID!AResourceOperator( msg.operator );

        if ( !resource ) {
            log.error( "Invalid resource in load job: ", msg.resource );
            return;
        }

        if ( !operator ) {
            log.error( "Invalid operator in load job: ", msg.operator );
            return;
        }

        operator.load( resource, msg.path );

        deallocate( msg );
    }

    void hotReloadFileUpdateWatcher( SFile* file ) {
        CResource resource = hrCache.get( file.path, null );
        if ( !IsValid( resource ) ) return;
        
        CResource newResource = loadBasic( resource.path, true, false );
        assert( newResource );

        hrUpdate.set( resource, newResource );
    }

public:
    /*   WRAPPERS   */

    T load( T )( String path )
    if ( is( T : CResource ) ) {
        return Cast!T( loadBasic( path ) );
    }
    
    T load( T )( string path )
    if ( is( T : CResource ) ) {
        return Cast!T( loadBasic( path ) );
    }

    T loadStatic( T )( String path )
    if ( is( T : CResource ) ) {
        return Cast!T( loadBasic( path, true ) );
    }

    T loadStatic( T )( string path )
    if ( is( T : CResource ) ) {
        return Cast!T( loadBasic( path, true ) );
    }
}

static __gshared {
    CResourceManager GResourceManager() { return CResourceManager.sig; }
}

bool isResourceValid( CResource resource ) {
    if ( !IsValid( resource ) ) return false;

    return resource.isValid();
}

bool IsResourceValid( CResource resource ) {
    if ( !IsValid( resource ) ) return false;

    return resource.isValid();
}

void WaitUntilResourceBeenLoaded( CResource resource ) {
    if ( !IsValid( resource ) ) return;

    while ( resource.loadPhase == EResourceLoadPhase.LOADING ) {}
}
