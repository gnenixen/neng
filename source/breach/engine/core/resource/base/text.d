module engine.core.resource.base.text;

public {
    import engine.core.resource.res;
    import engine.core.fs;
}

class CTextFileOperator : AResourceOperator {
    mixin( TRegisterClass!CTextFileOperator );
private:
    Array!String exts;

public:
    this() {
        exts ~= "txt";
    }

override:
    void load( CResource res, String path ) {
        CTextFile resource = Cast!CTextFile( res );

        resource.text = GFileSystem.fileReadAsString( path );
        resource.loadPhase = EResourceLoadPhase.SUCCESS;
    }

    CResource newPreloadInstance() { return NewObject!CTextFile(); }

    void hrSwap( CResource o, CResource n ) {
        CTextFile f1 = Cast!CTextFile( o );
        CTextFile f2 = Cast!CTextFile( n );

        String tmp = f1.text;
        f1.text = f2.text;
        f2.text = tmp;
    }

    Array!String extensions() { return exts; }
}

class CTextFile : CResource {
    mixin( TRegisterClass!CTextFile );
public:
    String text;
}
