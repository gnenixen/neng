module engine.modules.render_device.texture;

//import engine.thirdparty.imageformats;
import engine.thirdparty.imagefmt;

import engine.core.memory;
import engine.core.log;
import engine.core.resource;
import engine.core.utils.profile;

import engine.modules.render_device.render_device;

class CTexture : CResource {
    mixin( TRegisterClass!CTexture );
public: 
    alias rId this;

public:
    uint width;
    uint height;
    RawData data;
    ID rdId = ID_INVALID;

    ~this() {
        data.free();
        RD.destroy( rdId );
    }

    ID rId() {
        if ( rdId == ID_INVALID && isResourceValid( this ) ) {
            rdId = RD.texture_create(
                ERDTextureType.TT_2D,
                SRDTextureData( width, height, 0, data, ERDTextureDataFormat.RGBA )
            );
        }

        return rdId;
    }
}

class CTextureOperator : AResourceOperator {
    mixin( TRegisterClass!CTextureOperator );
private:
    Array!String exts;

public:
    this() {
        exts ~= "png";
    }

override:
    void load( CResource res, String path ) {
        CTexture texture = Cast!CTexture( res );
        SFileRef file = GFileSystem.file( path );

        RawData data = file.readAsRawData();
        if ( !data.length ) {
            log.warning( "Invalid file data!" );
            return;
        }

        IFImage img = read_image( data.rawdata, 4 );
        scope( exit ) img.free();

        if ( img.e ) {
            log.error( "PNG load error: ", IF_ERROR[img.e].ptr );
            return;
        }
        
        data.free();

        data.resize( img.buf8.length );
        Memory.memcpy( data.ptr, img.buf8.ptr, img.buf8.length * byte.sizeof );

        texture.width = img.w;
        texture.height = img.h;
        texture.data = data;

        texture.loadPhase = EResourceLoadPhase.SUCCESS;
    }

    void hrSwap( CResource o, CResource n ) {
        CTexture t1 = Cast!CTexture( o );
        CTexture t2 = Cast!CTexture( n );

        uint w = t1.width;
        uint h = t1.height;
        RawData d = t1.data;
        ID rdId = t1.rdId;

        t1.width = t2.width;
        t1.height = t2.height;
        t1.data = t2.data;
        t1.rdId = t2.rdId;

        t2.width = w;
        t2.height = h;
        t2.data = d;
        t2.rdId = rdId;
    }

    CResource newPreloadInstance() { return NewObject!CTexture; }

    Array!String extensions() {
        return exts;
    }
}
