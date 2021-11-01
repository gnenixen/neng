module engine.core.object.pool;

import engine.core.containers.array;
import engine.core.memory;
import engine.core.log;
public import engine.core.object._object;

alias GObjectPool = CGlobalObjectPool;

struct SObjectSlot {
    ID nextFreeSlot;
    CObject object;
}

struct SObjectPoolSynchronization {
    void function() lock;
    void function() unlock;
}

/**
    Muse be initialized beore any object allocations!
*/
static __gshared class CGlobalObjectPool {
static __gshared:
public:
    SObjectPoolSynchronization synchronization;

private:
    Array!SObjectSlot objects;
    size_t slotsCount = 0;

public:
    void initialize() {
        objects.policity.onReallocate = ( SObjectSlot* slots, size_t newSize, size_t pos ) {
            SObjectSlot* newArray = cast( SObjectSlot* )allocate( newSize * SObjectSlot.sizeof );
            
            foreach ( i; 0..newSize ) {
                if ( i < pos ) {
                    newArray[i].nextFreeSlot = slots[i].nextFreeSlot;
                    newArray[i].object = slots[i].object;
                } else {
                    newArray[i].nextFreeSlot = i;
                    newArray[i].object = null;
                }
            }

            return newArray;
        };

        // OS free all memory itself
        objects.policity.onFree = ( slot ) {};

        objects.resize( objects.CHUNK_SIZE );
        foreach ( i, elem; objects ) {
            objects.rawdata[i].nextFreeSlot = i;
        }
    }

    void deinitialize() {
        objects.free();
    }

    T newObject( T = CObject, Args... )( Args args )
    if ( is( T : CObject ) ) {
        T obj = allocate!T( args );

        if ( !initObject( obj ) ) {
            log.error( "Failed to initialize object of type ", T.stringof );
            deallocate( obj );
            return null;
        }

        return obj;
    }

    CObject newObjectR( Args... )( rClass rclass, Args, args ) {
        Object robj = rclass.createInstance();
        if ( !robj ) {
            return null;
        }
    
        T obj = cast( T )robj;
    
        if ( !initObject( obj, pool ) ) {
            deallocate( robj );
            log.error( "Failed to initialize object of type ", rclass.name() );
            return null;
        }

        return obj;
    }

    bool initObject( CObject obj ) {
        if ( !Memory.isValid( obj ) ) {
            log.error( "Trying to initialize null object!" );
            return false;
        }

        bool bResult = true;
        CCDC_ObjectInit oi;

        register( obj );

        if ( !obj.classDescription ) {
            goto __exit;
        }

        oi = obj.classDescription.get!CCDC_ObjectInit;
        if ( oi.isNeedCustomInit() ) {
            bResult = oi.objectInit( obj );
            goto __exit;
        }

__exit:
        obj.postInit();
        return bResult;
    }

    void destroyObject( CObject obj ) {
        if ( isCanBeDestroyed( obj ) ) {
            obj.preDelete();
            unregister( obj );
            deallocate( obj );
        }
    }

    bool isCanBeDestroyed( CObject obj ) {
        if ( obj is null ) return false;
        if ( !isValid( obj ) ) return false;

        CClassDescription descr = obj.classDescription();
        if ( !descr ) {
            return true;
        }
        
        CCDC_ObjectInit oi = descr.get!CCDC_ObjectInit;
        return oi.isCanDestroy( obj );
    }

    bool isValid( CObject obj ) {
        if ( !Memory.isValid( cast( void* )obj ) ) {
            return false;
        }
        
        return getObject( obj.id ) !is null;
    }

    bool isValid( ID id ) {
        return getObject( id ) !is null;
    }

    CObject getObject( ID id ) {
        CObject ret = null;

        tryLock();
            if ( id <= objects.length ) {
                ret = objects[id].object;
            }
        tryUnlock();

        return ret;
    }

private:
    void register( CObject obj ) {
        assert( obj.id == ID_INVALID );

        tryLock();
            if ( slotsCount == objects.length ) {
                objects.resize( objects.length + objects.CHUNK_SIZE );
            }

            ID slot = objects[slotsCount].nextFreeSlot;
            assert( objects[slot].object is null );

            objects[slot].object = obj;
            obj.id = slot;

            slotsCount++;
        tryUnlock();
    }

    void unregister( CObject obj ) {
        assert( obj.id != ID_INVALID );
        
        ID slot = obj.id;
        
        tryLock();
            slotsCount--;
            objects[slotsCount].nextFreeSlot = slot;

            objects[slot].object = null;
        tryUnlock();
    }

    void tryLock() {
        if ( synchronization.lock ) {
            synchronization.lock();
        }
    }

    void tryUnlock() {
        if ( synchronization.unlock ) {
            synchronization.unlock();
        }
    }
}


T NewObject( T = CObject, Args... )( Args args )
if ( is( T : CObject ) ) {
    return GObjectPool.newObject!T( args );
}

deprecated( "Use NewObject instead, just for new ideologi" )
T newObject( T = CObject, Args... )( Args args )
if ( is( T : CObject ) ) {
    return GObjectPool.newObject!T( args );
}

T newObjectR( T = CObject )( rClass rclass )
if ( is( T : CObject ) ) {
    Object robj = rclass.createInstance();
    if ( !robj ) {
        log.error( "Failed to create instance of rClass: ", rclass.name );
        return null;
    }

    T obj = cast( T )robj;

    if ( !GObjectPool.initObject( obj ) ) {
        deallocate( robj );
        log.error( "Failed to initialize object of type ", rclass.name() );
        return null;
    }

    return obj;
}

void DestroyObject( CObject obj ) {
    GObjectPool.destroyObject( obj );
}

deprecated( "Use DestroyObject instead, just for new ideologi" )
void destroyObject( CObject obj ) {
    GObjectPool.destroyObject( obj );
}

/**
    Usefull when use:
    array.free( ( CSomeObject* elem ) {
        destroyObject( elem );
    } );
*/
void DestroyObject( T )( T* obj )
if ( is( T : CObject ) ) {
    GObjectPool.destroyObject( *obj );
}

/**
    Usefull when use:
    array.free( ( CSomeObject* elem ) {
        destroyObject( elem );
    } );
*/
deprecated( "Use DestroyObject instead, just for new ideologi" )
void destroyObject( T )( T* obj )
if ( is( T : CObject ) ) {
    GObjectPool.destroyObject( *obj );
}

void DestroyObject( ID id ) {
    GObjectPool.destroyObject( GObjectPool.getObject( id ) );
}

deprecated( "Use DestroyObject instead, just for new ideologi" )
void destroyObject( ID id ) {
    GObjectPool.destroyObject( GObjectPool.getObject( id ) );
}

bool IsValid( CObject obj ) {
    return GObjectPool.isValid( obj );
}

deprecated( "Use IsValid instead, just for new ideologi" )
bool isValid( CObject obj ) {
    return GObjectPool.isValid( obj );
}

bool IsValid( T )( T* obj )
if ( is( T : CObject ) ) {
    return GObjectPool.isValid( *obj );
}

deprecated( "Use IsValid instead, just for new ideologi" )
bool isValid( T )( T* obj )
if ( is( T : CObject ) ) {
    return GObjectPool.isValid( *obj );
}

bool IsValid( ID id ) {
    return GetObjectByID( id ) !is null;
}

deprecated( "Use IsValid instead, just for new ideologi" )
bool isValid( ID id ) {
    return getObjectByID( id ) !is null;
}

T GetObjectByID( T = CObject )( ID id )
if ( is( T : CObject ) ) {
    return Cast!T( GObjectPool.getObject( id ) );
}

deprecated( "Use GetObjectByID instead, just for new ideologi" )
T getObjectByID( T = CObject )( ID id )
if ( is( T : CObject ) ) {
    return Cast!T( GObjectPool.getObject( id ) );
}

Array!T GetObjectsByID( T = CObject )( Array!ID ids )
if ( is( T : CObject ) ) {
    Array!T objects;
    objects.reserve( ids.length );

    foreach ( id; ids ) {
        objects ~= Cast!T( GObjectPool.getObject( id ) );
    }

    return objects;
}

deprecated( "Use GetObjectByID instead, just for new ideologi" )
Array!T getObjectsByID( T = CObject )( Array!ID ids )
if ( is( T : CObject ) ) {
    Array!T objects;
    objects.reserve( ids.length );

    foreach ( id; ids ) {
        objects ~= Cast!T( GObjectPool.getObject( id ) );
    }

    return objects;
}
