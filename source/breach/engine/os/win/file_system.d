module engine.os.win.file_system;

version( Windows ):

private {
    import core.sys.windows.windows;
}

import engine.core.fs;
import engine.core.object;
import engine.core.log;

class CWFS_Entry : CObject {
    mixin( TRegisterClass!CWFS_Entry );
public:
    WString name;
    WString fsByDirPath;
    WString fsFullPath;
    WString fsRelativeToRootPath;

    CWFS_Entry parent;

    ~this() {
        close();
    }

abstract:
    EFSEntryType type();
    uint size();

    bool open( uint flags );
    void close();
}

class CWFS_Dir : CWFS_Entry {
    mixin( TRegisterClass!CWFS_Dir );
public:
    HANDLE handler = INVALID_HANDLE_VALUE; // FindFirstFile handler
    WIN32_FIND_DATA f;
    WIN32_FIND_DATAW fu; // Unicode version

    Array!CWFS_File files;
    Array!CWFS_Dir dirs;
    
public:
    ~this() {
        files.free(
            ( file ) { destroyObject( file ); }
        );

        dirs.free(
            ( dir ) { destroyObject( dir ); }
        );
    }

    override EFSEntryType type() { return EFSEntryType.DIR; }
    override uint size() { return cast( uint )(files.length + dirs.length); }

	override bool open( uint flags ) { return true; }

  override bool isOpen() { return true; }

    override void close() {
        if ( handler != INVALID_HANDLE_VALUE ) {
            FindClose( handler );
            handler = INVALID_HANDLE_VALUE;
        }
    }

    void add( CWFS_Entry entry ) {
        if ( !entry ) return;

        entry.parent = this;

        CWFS_File file = Cast!CWFS_File( entry );
        if ( file ) {
            files ~= file;
            return;
        }

        CWFS_Dir dir = Cast!CWFS_Dir( entry );
        if ( dir ) {
            dirs ~= dir;
            return;
        }

        assert( false, "Invalid type of entry" );
    }
	
	CWFS_Entry getLocal( WString name ) {
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

class CWFS_File : CWFS_Entry {
    mixin( TRegisterClass!CWFS_File );
private:
    HANDLE stream = INVALID_HANDLE_VALUE;

public:
    override EFSEntryType type() { return EFSEntryType.FILE; }
    override uint size() {
		bool bNeedOpenClose = stream == INVALID_HANDLE_VALUE;
        
		uint sz;
		
		open( 0 );
			LARGE_INTEGER size;
			if ( !GetFileSizeEx( stream, &size ) ) {
				sz = 0;
			} else {
				sz = cast( uint )size.QuadPart;
			}
		if ( bNeedOpenClose ) close();

        return sz;
    }
	
	override bool open( uint flags ) {
		if ( stream != INVALID_HANDLE_VALUE ) return true;
		
		stream = CreateFileW( WString( "\\\\?\\", fsFullPath ).cstr, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
		
		if ( stream == INVALID_HANDLE_VALUE ) {
			log.error( "Canno't open file with: ", fsFullPath );
		}
		
		return stream != INVALID_HANDLE_VALUE;
	}

  override bool isOpen() { return strea != INVALID_HANDLE_VALUE; }

    override void close() {
        if ( stream != INVALID_HANDLE_VALUE ) {
            CloseHandle( stream );
            stream = INVALID_HANDLE_VALUE;
        }
    }
	
	int seek( size_t begin, EFSFileSeekPos pos ) {
        assert( stream != INVALID_HANDLE_VALUE );

        DWORD origin;
        switch ( pos ) {
        case EFSFileSeekPos.BEGIN:
            origin = FILE_BEGIN;
            break;

        case EFSFileSeekPos.END:
            origin = FILE_END;
            break;

        case EFSFileSeekPos.CURR:
            origin = FILE_CURRENT;
            break;
        
        default:
            assert( false );
        }
		
		LARGE_INTEGER li;
		li.QuadPart = begin;
		li.LowPart = SetFilePointer( stream, li.LowPart, &li.HighPart, origin );
		
		if ( li.LowPart == INVALID_SET_FILE_POINTER && GetLastError() != NO_ERROR ) {
			li.QuadPart = -1;
		}

        return cast( int )li.QuadPart;
    }

    size_t tell() {
        assert( stream != INVALID_HANDLE_VALUE );
        return SetFilePointer( stream, 0, NULL, FILE_CURRENT );
    }

    ulong read( ref RawData data, size_t n ) {
        assert( stream != INVALID_HANDLE_VALUE );

        data.resize( n );
		uint nBytesRead = 0;
		BOOL bResult = ReadFile( stream, data.ptr, cast( uint )n, &nBytesRead, NULL );

        return nBytesRead;
    }
}

class CWindowsFSBackend : AFSBackend {
    mixin( TRegisterClass!CWindowsFSBackend );
private:
    String mountName;
    CWFS_Dir root;

public:
    this( String path ) {
        root = newObject!CWFS_Dir();

        root.fsFullPath = path.opCast!wchar;
        reqGenerateFSTree( path.opCast!wchar, root );
    }

private:
    void reqGenerateFSTree( WString path, CWFS_Dir current ) {
        WIN32_FIND_DATAW findFileData;
		path = path.replace( WString( "/" ), WString( "\\" ) );
		WString rpath = WString( path, "\\*" );
		
        HANDLE hFind = FindFirstFileW( rpath.cstr, &findFileData );
        if ( hFind == INVALID_HANDLE_VALUE ) {
            log.warning( "FindFirstFileW failed (", GetLastError(), "): ", path );
            return;
        }

        do {
			if ( findFileData.cFileName[0] == '.' ) continue;
			
			CWFS_Entry nentry;
			WString npath = path ~ "\\" ~ findFileData.cFileName;
			
            if ( findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY ) {
				CWFS_Dir ndir = newObject!CWFS_Dir();
				reqGenerateFSTree( npath, ndir );
			
				nentry = ndir;
            } else {
				nentry = newObject!CWFS_File();
            }
			
			if ( nentry ) {
				nentry.fsByDirPath = path;
				nentry.fsFullPath = npath;
				nentry.fsRelativeToRootPath = npath.replace( root.fsFullPath, WString( "" ) );
				nentry.name = WString( findFileData.cFileName );
				
				current.add( nentry );
			}
        } while ( FindNextFile( hFind, &findFileData ) != 0 );

        FindClose( hFind );
    }
	
	CWFS_Entry getEntry( WString path ) {
		Array!WString lpath = path.replace( WString( "/" ), WString( "\\" ) ).split( WString( "\\" ) );
		CWFS_Entry current = root;
		
		foreach ( i, val; lpath ) {
			if ( !current ) return null;
			
			if ( val == ".." ) {
				current = current.parent;
			}
			
			if ( CWFS_Dir dir = Cast!CWFS_Dir( current ) ) {
				current = dir.getLocal( val );
			} else {
				current = null;
			}
		}
		
		return current;
	}
	
public:
override:
    void destroy( ID id ) { destroyObject( id ); }

    bool fs_mount( VArray args ) {
		mountName = args[0].as!String;
        return true;
	}
    
	bool fs_unmount() { return true; }
    
	ID fs_root() {
		if ( root ) return root.id;
		
		return ID_INVALID;
	}
    void fs_update() {}
    void fs_setEventsHandler( SCallable handler ) {}

    /*   ENTRY API   */    
    ID entry_create( EFSEntryType type, String name, ID parent = ID_INVALID ) {
		CWFS_Dir dir = getObjectByID!CWFS_Dir( parent );

        if ( !dir ) {
            log.error( "Invalid parent dir id!" );
            return ID_INVALID;
        }

        CWFS_Entry entry;
        
        switch ( type ) {
        case EFSEntryType.DIR:
            entry = newObject!CWFS_Dir();
            break;
        
        case EFSEntryType.FILE:
            entry = newObject!CWFS_File();
            break;
        
        default:
            assert( false );
        }

        entry.name = name;

        dir.add( entry );

        return entry.id;
	}

    ID entry_get( String path ) {
        CWFS_Entry entry = getEntry( path.opCast!wchar );
        if ( entry is null ) return ID_INVALID;

        return entry.id;
    }
	
    bool entry_open( ID id, uint flags ) {
        CWFS_Entry entry = GetObjectByID!CWFS_Entry( id );
        if ( entry is null ) return ID_INVALID;

        return entry.open( flags );
    }
    
    void entry_close( ID id ) {
        CWFS_Entry entry = getObjectByID!CWFS_Entry( id );
        if ( entry is null ) return;

        entry.close();
    }
	
    SFSEntryInfo entry_info( ID id ) {
        CWFS_Entry entry = getObjectByID!CWFS_Entry( id );
        if ( !entry ) return SFSEntryInfo();

        SFSEntryInfo ret;
        ret.type = entry.type;
        ret.name = entry.name;
        ret.bOpen = entry.isOpen();
        ret.path = entry.fsByDirPath;
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
        CWFS_File file = getObjectByID!CWFS_File( id );
        if ( !file ) return 0;
        
        return file.seek( offset, base );
    }

    size_t file_tell( ID id ) {
        CWFS_File file = getObjectByID!CWFS_File( id );
        if ( !file ) return 0;

        return file.tell();
    }

    RawData file_read( ID id, size_t nbytes ) {
        CWFS_File file = getObjectByID!CWFS_File( id );
        if ( !file ) return RawData();

        RawData ret;
        file.read( ret, nbytes );

        return ret;
    }
    size_t file_write( ID id, RawData data ) { return 0; }

    /*   DIR API   */
    Array!ID dir_entries( ID id ) {
        CWFS_Dir dir = GetObjectByID!CWFS_Dir( id );
        if ( !dir ) return Array!ID();

        Array!ID ret;
        ret.reserve( dir.files.length + dir.dirs.length );
        
        foreach ( entry; dir.files ) {
            ret ~= entry.id;
        }

        foreach ( entry; dir.dirs ) {
            ret ~= entry.id;
        }

        return ret;
    }
}

