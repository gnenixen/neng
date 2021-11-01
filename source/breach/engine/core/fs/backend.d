module engine.core.fs.backend;

public:
import engine.core.define;
import engine.core.object;
import engine.core.string;
import engine.core.callable;
import engine.core.typedefs;
import engine.core.containers;
import engine.core.utils.ustruct;

enum EFSEntryType {
    NONE,
    FILE,
    DIR
}

enum EFSEvent {
    //DELETED,
    //RENAMED,

    FILE_UPDATED,

    //DIR_NEW_ENTRY,
    //DIR_DELETED_ENTRY,
}

enum EFSEntryFlags {
    READ = 0,
    WRITE = 1,
    APPEND = 2,
    TRUNC = 3
}

enum EFSFileSeekPos {
    BEGIN = 0,
    END = 1,
    CURR = 2
}

struct SFSEntryInfo {
    mixin( TRegisterStruct!SFSEntryInfo );
public:
    EFSEntryType type;

    // Entry base name
    String name;
    // Full path from fs root
    String path;
    // Is entry opened
    bool bOpen = false;
    // Size of file in bytes, or count of entries in dir
    size_t size = 0;
    // Read/write/append/trunc
    uint flags = 0;
    // Anyway is a dir
    ID parent = ID_INVALID;
}

abstract class AFSBackend : CObject {
    mixin( TRegisterClass!AFSBackend );
abstract:
    void destroy( ID id );

    bool fs_mount( VArray args );
    bool fs_unmount();
    ID fs_root();
    void fs_update();
    void fs_setEventsHandler( SCallable handler );

    /*   ENTRY API   */    
    ID entry_create( EFSEntryType type, String name, ID parent = ID_INVALID );
    ID entry_get( String path );
    bool entry_open( ID id, uint flags );
    void entry_close( ID id );
    SFSEntryInfo entry_info( ID id );

    bool entry_reparent( ID id, ID nparent );
    void entry_rename( ID id, String name );

    /*   FILE API   */
    size_t file_seek( ID id, size_t offset, EFSFileSeekPos base = EFSFileSeekPos.CURR );
    size_t file_tell( ID id );
    RawData file_read( ID id, size_t nbytes );
    size_t file_write( ID id, RawData data );

    /*   DIR API   */
    /**
        Get all dir entries, files and dirs by
        ids
    */
    Array!ID dir_entries( ID id );
}
