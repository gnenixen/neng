module engine.os.linux.file_system;

import core.sys.posix.dirent;
import core.sys.posix.stdio;
import core.sys.posix.stdlib;
import core.sys.posix.poll;
import core.sys.linux.sys.inotify;
import core.sys.linux.unistd;
import core.stdc.limits;
import core.stdc.string;

import engine.core.fs;
import engine.core.object;
import engine.core.log;
import engine.core.bitflags;

class CLFS_Entry : CObject {
    mixin( TRegisterClass!CLFS_Entry );
public:
    String name;
    String fsByDirPath;
    String fsFullPath;
    String fsRelativeToRootPath;
    int inotifyHandler;

    CLFS_Entry parent;

    ~this() {
        close();
    }

    EFSEntryType type() { return EFSEntryType.DIR; }
    uint size() { return 0; }

    bool open( uint flags ) { return false; }
    void close() {}

    bool isOpen() { return false; }
}

class CLFS_Dir : CLFS_Entry {
    mixin( TRegisterClass!CLFS_Dir );
private:
    DIR* stream = null;

    Array!CLFS_File files;
    Array!CLFS_Dir dirs;

public:
    ~this() {
        files.free(
            ( file ) { DestroyObject( file ); }
        );

        dirs.free(
            ( dir ) { DestroyObject( dir ); }
        );
    }

    override EFSEntryType type() { return EFSEntryType.DIR; }
    override uint size() { return cast( uint )(files.length + dirs.length); }

    override bool open( uint flags ) {
        if ( stream ) return true;

        stream = opendir( cast( char* )fsFullPath.toString() );
        if ( !stream ) {
            log.error( "Canno't open dir by path: ", stream );
        }

        return stream !is null;
    }

    override void close() {
        if ( stream ) {
            closedir( stream );
            stream = null;
        }
    }

    override bool isOpen() {
        return stream !is null;
    }

    void add( CLFS_Entry entry ) {
        if ( !entry ) return;

        entry.parent = this;

        CLFS_File file = Cast!CLFS_File( entry );
        if ( file ) {
            files ~= file;
            return;
        }

        CLFS_Dir dir = Cast!CLFS_Dir( entry );
        if ( dir ) {
            dirs ~= dir;
            return;
        }

        assert( false, "Invalid type of entry" );
    }

    CLFS_Entry getLocal( String name ) {
        foreach ( dir; dirs ) {
            if ( dir.name == name ) {
                return dir;
            }
        }

        foreach ( file; files ) {
            if ( file.name == name ) {
                return file;
            }
        }

        return null;
    }

}

class CLFS_File : CLFS_Entry {
    mixin( TRegisterClass!CLFS_File );
private:
    FILE* stream = null;

public:
    override EFSEntryType type() { return EFSEntryType.FILE; }
    override uint size() {
        if ( !stream ) return 0;

        fseek( stream, 0, SEEK_END );
        uint sz = cast( uint )ftell( stream );
        fseek( stream, 0, SEEK_SET );

        return sz;
    }

    override bool open( uint flags_ ) {
        if ( stream ) return true;

        CString flags;
        SBitflags!uint bitset = SBitflags!uint( flags_ );

        if ( bitset.get( EFSEntryFlags.READ ) && bitset.get( EFSEntryFlags.WRITE ) ) { flags ~= "r+"; }
        else
        if ( bitset.get( EFSEntryFlags.READ ) ) { flags ~= 'r'; }
        else
        if ( bitset.get( EFSEntryFlags.WRITE ) ) { flags ~= 'w'; }
        else
        if ( bitset.get( EFSEntryFlags.APPEND ) ) { flags ~= 'a'; }

        stream = fopen( cast( char* )fsFullPath.opCast!char.toString(), cast( char* )flags.toString() );

        if ( !stream ) {
            log.error( "Canno't open file with flags: ", fsFullPath, " : ", cast( char* )flags.toString() );
        }

        return stream !is null;
    }

    override void close() {
        if ( stream ) {
            fclose( stream );
            stream = null;
        }
    }

    override bool isOpen() {
        return stream !is null;
    }

    int seek( size_t begin, EFSFileSeekPos pos ) {
        assert( stream );

        int origin;
        switch ( pos ) {
        case EFSFileSeekPos.BEGIN:
            origin = SEEK_SET;
            break;

        case EFSFileSeekPos.END:
            origin = SEEK_END;
            break;

        case EFSFileSeekPos.CURR:
            origin = SEEK_CUR;
            break;
        
        default:
            assert( false );
        }

        return fseek( stream, begin, origin );
    }

    size_t tell() {
        assert( stream );
        return ftell( stream );
    }

    ulong read( ref RawData data, size_t n ) {
        assert( stream );

        data.resize( n );
        ulong r = fread( data.ptr, 1, n, stream );

        return r;
    }
}

class CLinuxFSBackend : AFSBackend {
    mixin( TRegisterClass!CLinuxFSBackend );
private:
    enum INOTIFY_MAX_EVENTS = 1024;
    enum INOTIFY_NAME_LEN_MAX = 64;
    enum INOTIFY_EVENT_SIZE = inotify_event.sizeof;
    enum INOTIFY_BUF_LEN = INOTIFY_MAX_EVENTS * ( INOTIFY_EVENT_SIZE + INOTIFY_NAME_LEN_MAX );
        
protected:
    String mountName;
    CLFS_Dir root;

    SCallable eventsHandler;
    int inotifyHandler;
    ubyte[INOTIFY_BUF_LEN] inotifyBuffer;
    Dict!( CLFS_Entry, int ) inotifyMap;

public:
    this() {
        inotifyHandler = inotify_init();
        assert( inotifyHandler >= 0, "Couldn't initialize inotify" );
    }

    this( String path ) {
        inotifyHandler = inotify_init();
        assert( inotifyHandler >= 0, "Couldn't initialize inotify" );

        root = NewObject!CLFS_Dir();

        root.fsFullPath = path;
        reqGenerateFSTree( cast( char* )path.opCast!char.toString(), root );
    }

    ~this() {
        close( inotifyHandler );
    }

private:
    void reqGenerateFSTree( char* path, CLFS_Dir current ) {
        DIR* dir = null;
        dirent* entry = null;
        
        assert( (dir = opendir( path )) !is null, CString( "Invalid dir path: ", path ) );
        
        while ( (entry = readdir(dir)) !is null ) {
            if ( strcmp( entry.d_name.ptr, "." ) == 0 || strcmp( entry.d_name.ptr, ".." ) == 0 ) continue;

            CLFS_Entry nentry;

            char[1024] npath;
            snprintf( npath.ptr, path.sizeof * 1024, "%s/%s", path, entry.d_name.ptr );

            if ( entry.d_type == DT_DIR ) {
                CLFS_Dir ndir = NewObject!CLFS_Dir();
                reqGenerateFSTree( npath.ptr, ndir );

                nentry = ndir;
            } else if ( entry.d_type == DT_REG ) {
                nentry = NewObject!CLFS_File();
            }

            if ( nentry ) {
                nentry.fsByDirPath = String( path );
                nentry.fsFullPath = String( npath );
                nentry.fsRelativeToRootPath = String( npath ).replace( root.fsFullPath, rs!"" );
                nentry.name = String( entry.d_name );
                nentry.inotifyHandler = inotify_add_watch( inotifyHandler, npath.ptr, IN_MODIFY );
                if ( nentry.inotifyHandler == -1 ) {
                    log.warning( "Couldn't add watch to: ", nentry.fsFullPath );
                }

                current.add( nentry );
                inotifyMap.set( nentry.inotifyHandler, nentry );
            }

            current.close();
        }
    }

    CLFS_Entry getEntry( String path ) {
        Array!String lpath = path.split( rs!"/" );
        CLFS_Entry curr = root;

        foreach ( i, val; lpath ) {
            if ( !curr ) return null;

            if ( val == "" ) {
                continue;
            }

            if ( val == ".." ) {
                curr = curr.parent;
                continue;
            }

            if ( CLFS_Dir dir = Cast!CLFS_Dir( curr ) ) {
                curr = dir.getLocal( val );
            } else {
                curr = null;
            }
        }

        return curr;
    }

    void inotifyProcessEvent( inotify_event* event ) {
        CLFS_Entry entry = inotifyMap.get( event.wd, null );
        assert( entry );

        VArray args;
        args ~= mountName;

        if ( event.mask & IN_ISDIR ) {
            args ~= entry.fsRelativeToRootPath;
        } else {
            if ( event.len == 0 ) return;

            args ~= String( entry.fsRelativeToRootPath, "/", event.name.ptr );

            if ( event.mask & IN_MODIFY ) {
                eventsHandler.call( EFSEvent.FILE_UPDATED, args );
            }
        }
    }

public:
override:
    void destroy( ID id ) { DestroyObject( id ); }

    bool fs_mount( VArray args ) { 
        mountName = args[0].as!String;
        return true;
    }
    bool fs_unmount() { return true; }

    ID fs_root() {
        if ( root ) return root.id;

        return ID_INVALID;
    }

    void fs_update() {
        int i = 0;
        long length;

        pollfd pfd;
        pfd.fd = inotifyHandler;
        pfd.events = POLLIN;
        const code = poll( &pfd, 1, 0 );

        if ( code == 0 ) return;

        length = read( inotifyHandler, inotifyBuffer.ptr, INOTIFY_BUF_LEN );

        while ( i < length ) {
            inotify_event* event = Cast!( inotify_event* )( &inotifyBuffer[i] );

            inotifyProcessEvent( event );
            i += INOTIFY_EVENT_SIZE + event.len;
        }
    }

    void fs_setEventsHandler( SCallable handler ) {
        eventsHandler = handler;
    }

    /*   ENTRY API   */    
    ID entry_create( EFSEntryType type, String name, ID parent ) {
        CLFS_Dir dir = GetObjectByID!CLFS_Dir( parent );

        if ( !dir ) {
            log.error( "Invalid parent dir id!" );
            return ID_INVALID;
        }

        CLFS_Entry entry;
        
        switch ( type ) {
        case EFSEntryType.DIR:
            entry = NewObject!CLFS_Dir();
            break;
        
        case EFSEntryType.FILE:
            entry = NewObject!CLFS_File();
            break;
        
        default:
            assert( false );
        }

        entry.name = name;

        dir.add( entry );

        return entry.id;
    }

    ID entry_get( String path ) {
        CLFS_Entry entry = getEntry( path );
        if ( !entry ) return ID_INVALID;

        return entry.id;
    }

    bool entry_open( ID id, uint flags ) {
        CLFS_Entry entry = GetObjectByID!CLFS_Entry( id );
        if ( entry is null ) return false;

        return entry.open( flags );
    }
    
    void entry_close( ID id ) {
        CLFS_Entry entry = GetObjectByID!CLFS_Entry( id );
        if ( entry is null ) return;

        entry.close();
    }

    SFSEntryInfo entry_info( ID id ) {
        CLFS_Entry entry = GetObjectByID!CLFS_Entry( id );
        if ( !entry ) return SFSEntryInfo();

        SFSEntryInfo ret;
        ret.type = entry.type;
        ret.name = entry.name;
        ret.bOpen = entry.isOpen();
        ret.path = String( mountName, entry.fsRelativeToRootPath );
        ret.size = entry.size;
        ret.flags = 0;

        if ( entry.parent ) {
            ret.parent = entry.parent.id;
        }

        return ret;
    }

    bool entry_reparent( ID id, ID nparent ) { return true; }
    void entry_rename( ID id, String name ) {}

    /*   FILE API   */
    size_t file_seek( ID id, size_t offset, EFSFileSeekPos base ) {
        CLFS_File file = GetObjectByID!CLFS_File( id );
        if ( !file ) return 0;
        
        return file.seek( offset, base );
    }

    size_t file_tell( ID id ) {
        CLFS_File file = GetObjectByID!CLFS_File( id );
        if ( !file ) return 0;

        return file.tell();
    }

    RawData file_read( ID id, size_t nbytes ) {
        CLFS_File file = GetObjectByID!CLFS_File( id );
        if ( !file ) return RawData();

        RawData ret;
        file.read( ret, nbytes );

        return ret;
    }
    size_t file_write( ID id, RawData data ) { return 0; }

    /*   DIR API   */
    Array!ID dir_entries( ID id ) {
        CLFS_Dir dir = GetObjectByID!CLFS_Dir( id );
        if ( !dir ) return Array!ID();

        Array!ID ret;
        ret.reserve( dir.files.length + dir.dirs.length );

        foreach ( file; dir.files ) {
            ret ~= file.id;
        }

        foreach ( _dir; dir.dirs ) {
            ret ~= _dir.id;
        }

        return ret;
    }
}
