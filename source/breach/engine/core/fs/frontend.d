module engine.core.fs.frontend;

import engine.core.fs.backend;

import engine.core.signal;
import engine.core.bitflags;
import engine.core.define;
import engine.core.object;
import engine.core.string;
import engine.core.log;
import engine.core.utils.ustruct;
import engine.core.memory;

struct SFileSystemSynchronization {
    void function() lock;
    void function() unlock;
}

struct SFSPath {
    mixin( TRegisterStruct!SFSPath );
public:
    String path;

    String fs() {
        Array!String npath = path.split( rs!"/" );
        if ( npath.length < 1 ) return String();

        return npath[0];
    }

    //String absolute() {}
}

struct SFSEntry {
    mixin( TRegisterStruct!SFSEntry );
protected:
    String lpath;
    AFSBackend lfs = null;
    ID lfsId = ID_INVALID;
    EFSEntryType ltype = EFSEntryType.NONE;

public:
    this( AFSBackend backend, ID entryId, String ipath, EFSEntryType itype ) {
        lfs = backend;
        lfsId = entryId;
        lpath = ipath;
        ltype = itype;
    }

    String path() { return lpath; }
    AFSBackend fs() { return lfs; }
    ID fsId() { return lfsId; }
    EFSEntryType type() { return ltype; }

    bool open( uint flags ) { return fs.entry_open( fsId, flags ); }
    void close() { fs.entry_close( fsId ); }
}

struct SFile {
    mixin( TRegisterStruct!SFile );
public:
    SFSEntry entry;
    alias entry this;

    this( AFSBackend backend, ID entryId, String ipath ) {
        entry = SFSEntry( backend, entryId, ipath, EFSEntryType.FILE );
    }

    RawData readAsRawData() {
        RawData ret;
        long lsize;
		
        fs.file_seek( fsId, 0, EFSFileSeekPos.END );
        lsize = fs.file_tell( fsId );
        fs.file_seek( fsId, 0, EFSFileSeekPos.BEGIN );

        if ( lsize == -1 ) return ret;

        ret = fs.file_read( fsId, lsize );

        return ret;
    }

    String readAsString() {
        return String( readAsRawData() );
    }
}

struct SFileRef {
public:
    SFile* entry;
    alias entry this;

    this( SFile* ientry ) {
        entry = ientry;
    }

    ~this() {
        if ( entry ) {
            entry.close();
            deallocate( entry );
        }
    }
}

struct SDir {
    mixin( TRegisterStruct!SDir );
public:
    SFSEntry entry;
    alias entry this;

    this( AFSBackend backend, ID entryId, String ipath ) {
        entry = SFSEntry( backend, entryId, ipath, EFSEntryType.DIR );
    }

    Array!SFSEntry entries() {
        Array!ID ids = fs.dir_entries( fsId );
        Array!SFSEntry ret;

        if ( !ids.length ) return ret;

        ret.reserve( ids.length );

        foreach ( eid; ids ) {
            SFSEntryInfo info = fs.entry_info( eid );
            ret ~= GFileSystem.entry( info.path );
        }

        return ret;
    }
}

struct SDirRef {
public:
    SDir* entry;
    alias entry this;

    this( SDir* ientry ) {
        entry = ientry;
    }

    ~this() {
        if ( entry ) {
            entry.close();
            deallocate( entry );
        }
    }
}

class CFileSystem : CObject {
    mixin( TRegisterClass!( CFileSystem, Singleton ) );
public:
    Signal!( SFile* ) fileUpdated;

    SFileSystemSynchronization mutex;

protected:
    Dict!( AFSBackend, String ) roots;

public:
    bool mount( String name, AFSBackend fs ) {
        mutex.lock();

        assert( IsValid( fs ), "Trying to mount null fs" );
        assert( roots.get( name, null ) is null, CString( "File system root with name `", name, "` already mounted" ) );

        roots.set( name, fs );

        // TODO: Fix copying of string in args, because this not raise refc++
        VArray args;
        var v = var(name);
        args ~= v;

        if ( !fs.fs_mount( args ) ) {
            log.error( "Canno't mount fs: ", name );
            return false;
        }

        fs.fs_setEventsHandler( SCallable( rs!"eventsHandler", this.id ) );

        log.info( "Mounted new root: ", name );

        mutex.unlock();
        
        return true;
    }

    void update() {
        foreach ( k, v; roots ) {
            v.fs_update();
        }
    }

    SFSEntry entry( String path ) {
        mutex.lock();

        Array!String split = path.split( rs!"/" );
        if ( split.length < 2 ) {
            log.error( "Cannot't find root name: ", path );
            return SFSEntry();
        }

        String fs = split[0];

        AFSBackend root = getRoot( fs );
        if ( root is null ) {
            log.error( "Invalid entry root: ", fs );
            return SFSEntry();
        }

        // Fix path - remove root dir name and first separator
        String rpath = path.substr( fs.length + 1, path.length - fs.length - 1 );
        ID entryId = root.entry_get( rpath );
        if ( entryId == ID_INVALID ) {
            log.error( "Not found entry in root: (", fs, ") ", rpath );
            return SFSEntry();
        }

        SFSEntryInfo info = root.entry_info( entryId );

        mutex.unlock();

        return SFSEntry( root, entryId, path, info.type );
    }

    SFile* file( String path, BitFlags flags = BitFlags() ) {
        SFSEntry entry = entry( path );
        if ( entry.fsId == ID_INVALID ) return null;
        if ( entry.type != EFSEntryType.FILE ) return null;

        if ( flags == 0 ) {
            flags.set( EFSEntryFlags.READ, true );
            flags.set( EFSEntryFlags.WRITE, true );
        }

        SFile* ret = allocate!SFile();
        ret.entry = entry;
        
        ret.open( flags );

        return ret;
    }

    SDir* dir( String path, BitFlags flags = BitFlags() ) {
        SFSEntry entry = entry( path );
        if ( entry.fsId == ID_INVALID ) return null;
        if ( entry.type != EFSEntryType.DIR ) return null;

        if ( flags == 0 ) {
            flags.set( EFSEntryFlags.READ, true );
            flags.set( EFSEntryFlags.WRITE, true );
        }

        SDir* ret = allocate!SDir();
        ret.entry = entry;
        
        ret.open( flags );

        return ret;
    }

    RawData fileReadAsRawData( String path ) {
        RawData ret;

        SFileRef f = file( path );
        if ( f is null ) return ret;

        ret = f.readAsRawData();

        return ret;
    }

    String fileReadAsString( String path ) {
        String ret;

        SFileRef f = file( path );
        if ( f is null ) return ret;

        ret = f.readAsString();

        return ret;
    }

    bool isFileExists( String path ) {
        SFileRef f = file( path );

        return f.entry !is null;
    }

protected:
    AFSBackend getRoot( String rname ) {
        return roots.get( rname, null );
    }

    void eventsHandler( EFSEvent type, VArray args ) {
        switch ( type ) {
        case EFSEvent.FILE_UPDATED:
            String mountName = args[0].as!String;
            String rpath = args[1].as!String;

            SFileRef f = file( String( mountName, rpath ) );
            log.warning( String( mountName, rpath ) );
            assert( f, CString( "Invalid file path: ", mountName, rpath ) );

            fileUpdated.emit( f );
            break;

        default:
            assert( false );
        }
    }
}

static __gshared {
    CFileSystem GFileSystem() { return CFileSystem.sig; }
}
