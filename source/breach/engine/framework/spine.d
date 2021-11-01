module engine.framework.spine;

import engine.core.object;
import engine.core.resource;
import engine.core.string;
import engine.core.memory;
import engine.core.containers.array;
import engine.core.log;

import engine.modules.render_device;

import engine.framework.render.r2d;

import engine.thirdparty.spine.functions;
public import engine.thirdparty.spine.types;

extern( C ) static __gshared {
    import engine.core.memory;

    void _spine_initialize() {
        _spSetMalloc( &spine_malloc );
        _spSetRealloc( &spine_realloc );
        _spSetFree( &spine_free );
    }

    void _spAtlasPage_createTexture( spAtlasPage* self, const( char )* path ) {
        CTexture texture = cast( CTexture )GResourceManager.loadBasic( String( path ), true );
        assert( texture );

        self.renderObject = Cast!( void* )( texture );
        self.width = texture.width;
        self.height = texture.height;
    }

    void _spAtlasPage_disposeTexture( spAtlasPage* self ) {
        DestroyObject( Cast!CTexture( self.renderObject ) );
    }

    char* _spUtil_readFile( const( char )* path, int* length ) {
        import engine.core.fs;

        RawData rawdata = GFileSystem.fileReadAsRawData( String( path ) );
        *length = Cast!int( rawdata.length * char.sizeof );

        char* data = Cast!( char* )( allocate( rawdata.length * char.sizeof ) );
        Memory.memcpy( data, rawdata.ptr, rawdata.length * char.sizeof );

        return data;
    }

    void* spine_malloc( size_t psize ) {
        if ( psize == 0 ) return null;
        return allocate( psize );
    }

    void* spine_realloc( void* ptr, size_t psize ) {
        if ( psize == 0 ) return null;
        return reallocate( ptr, psize );
    }

    void spine_free( void* ptr ) {
        if ( !ptr ) return;
        deallocate( ptr );
    }
}

class CSpineResource : CResource {
    mixin( TRegisterClass!CSpineResource );
public:
    spAtlas* atlas;
    spSkeletonData* data;

public:
    float getAnimationLength( String name ) {
        if ( loadPhase != EResourceLoadPhase.SUCCESS ) return 0.0f;

        spAnimation* animation = spSkeletonData_findAnimation( data, name.c_str.cstr );
        if ( !animation ) return 0.0f;

        return animation.duration;
    }
}

class CSpineResourceOperator : AResourceOperator {
    mixin( TRegisterClass!CSpineResourceOperator );
public:
override:
    void load( CResource res, String path ) {
        CSpineResource resource = Cast!CSpineResource( res );

        String pathAtlas = String( path.dirname, "/", path.filename, ".atlas" );

        spAtlas* atlas = spAtlas_createFromFile( pathAtlas.c_str.cstr, null );
        spSkeletonJson* json = spSkeletonJson_create( atlas );
        scope ( exit ) spSkeletonJson_dispose( json );

        if ( !json ) {
            log.error( "Filde to load file: ", path );
            res.loadPhase = EResourceLoadPhase.FAILED;
            return;
        }

        json.scale = 1.0f;

        spSkeletonData* skeletonData = spSkeletonJson_readSkeletonDataFile( json, path.c_str.cstr );
        if ( !skeletonData ) {
            log.error( "Failde to load data from file: ", path );
            log.error( json.error );
            res.loadPhase = EResourceLoadPhase.FAILED;
            return;
        }

        resource.atlas = atlas;
        resource.data = skeletonData;
        res.loadPhase = EResourceLoadPhase.SUCCESS;
    }

    void hrSwap( CResource o, CResource n ) {}

    CResource newPreloadInstance() { return NewObject!CSpineResource(); }

    Array!String extensions() {
        return Array!String( "json" );
    }
}

private {
    struct SSpineAnimationInfo {
        mixin( TRegisterStruct!SSpineAnimationInfo );
    public:
        String name;
        uint track;
        bool bLoop;
    }

    struct SSpineState {
        SVec2F scale = SVec2F( 1.0f );

        SSpineAnimationInfo animation;

        String skin;
        spSkin* skinData = null;
        bool bSkinSynced = false;
    }
}

class CSpinePlayer : CObject {
    mixin( TRegisterClass!CSpinePlayer );
private:
    enum ELEMS_PER_VERTEX = 8;

public:
    Signal!( String ) onEventReceived;

public:
    CR2D_Primitive primitive;
    float speed = 1.0f;

private:
    CSpineResource lresource;
    spSkeleton* skeleton;
    spAnimationState* animState;

    SSpineState state;

    Array!float worldVertices;

public:
    this() {
        primitive = NewObject!CR2D_Primitive( ERDBufferUpdate.STREAM );
        primitive.setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, ELEMS_PER_VERTEX * float.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, ELEMS_PER_VERTEX * float.sizeof, 2 * float.sizeof ),
            SRDVertexElement( 2, ERDPrimitiveType.FLOAT, 4, ELEMS_PER_VERTEX * float.sizeof, 4 * float.sizeof )
        ) );
    }

    ~this() {
        spineDispose();
        DestroyObject( primitive );
    }

    void update( float delta ) {
        if ( !animState && !spineInitialize() ) return;

        primitive.reset();

        float* uvs = null;
        ushort* indices = null;
        uint vertCount = 0;
        uint indCount = 0;
        
        if ( !state.bSkinSynced ) { skin = state.skin; }

        spAnimationState_update( animState, delta * speed );
        spAnimationState_apply( animState, skeleton );
        spSkeleton_updateWorldTransform( skeleton );

        foreach ( i; 0..skeleton.slotsCount ) {
            spSlot* slot = skeleton.drawOrder[i];

            if ( !slot.attachment ) continue;

            CTexture texture = null;
            SColorRGBA color = SColorRGBA(
                skeleton.color.r * slot.color.r,
                skeleton.color.g * slot.color.g,
                skeleton.color.b * slot.color.b,
                skeleton.color.a * slot.color.a
            );

            switch ( slot.attachment.type ) {
            case spAttachmentType.SP_ATTACHMENT_REGION: {
                static ushort[6] quadTriangles = [0, 1, 2, 2, 3, 0];

                spRegionAttachment* attachment = Cast!( spRegionAttachment* )( slot.attachment );
                vertCount = 8;

                if ( worldVertices.length < vertCount ) {
                    worldVertices.resize( vertCount );
                    Memory.memset( worldVertices.ptr, 0, float.sizeof * vertCount );
                }

                spRegionAttachment_computeWorldVertices( attachment, slot.bone, worldVertices.rawdata.ptr, 0, 2 );
                uvs = attachment.uvs.ptr;
                indices = quadTriangles.ptr;
                indCount = 6;
                texture = Cast!CTexture( (Cast!( spAtlasRegion* )(attachment.rendererObject).page.renderObject ) );
                break;
            }

            case spAttachmentType.SP_ATTACHMENT_MESH: {
                spMeshAttachment* attachment = Cast!( spMeshAttachment* )( slot.attachment );
                vertCount = Cast!( spVertexAttachment* )( slot.attachment ).worldVerticesLength;

                if ( worldVertices.length < vertCount ) {
                    worldVertices.resize( vertCount );
                    Memory.memset( worldVertices.ptr, 0, float.sizeof * vertCount );
                }

                spVertexAttachment_computeWorldVertices(
                    &attachment._super,
                    slot,
                    0,
                    attachment._super.worldVerticesLength,
                    worldVertices.rawdata.ptr,
                    0,
                    2
                );

                uvs = attachment.uvs;
                indices = attachment.triangles;
                indCount = attachment.trianglesCount;
                texture = Cast!CTexture( (Cast!( spAtlasRegion* )(attachment.rendererObject).page.renderObject ) );
                break;
            }

            default: continue;
            }

            addRegion( texture, worldVertices.rawdata.ptr, uvs, vertCount, indices, indCount, color );
        }
    }

    void reset() {
        if ( !skeleton ) return;

        spSkeleton_setToSetupPose( skeleton );
        spAnimationState_update( animState, 0 );
        spAnimationState_apply( animState, skeleton );
        spSkeleton_updateWorldTransform( skeleton );
    }

    void play( String name, uint trackIndex = 0, bool bLoop = false ) {
        state.animation = SSpineAnimationInfo( name, trackIndex, bLoop );
        if ( !skeleton ) return;

        spAnimation* anim = spSkeletonData_findAnimation( skeleton.data, name.c_str.cstr );
        if ( !anim ) {
            log.warning( "Canno't find animation: ", name );
            return;
        }

        spAnimationState_setAnimation( animState, trackIndex, anim, bLoop );
    }

    void scale( float x, float y ) {
        state.scale = SVec2F( x, y );

        if ( !skeleton ) return;

        skeleton.scaleX = x;
        skeleton.scaleY = y * -1.0f;
    }

    Array!String animations() {
        Array!String ret;

        if ( !skeleton ) return ret;

        foreach ( i; 0..animState.data.skeletonData.animationsCount ) {
            ret ~= String( animState.data.skeletonData.animations[i].name );
        }

        return ret;
    }

    Array!String skins() {
        Array!String ret;

        if ( !skeleton ) return ret;

        foreach ( i; 0..animState.data.skeletonData.skinsCount ) {
            ret ~= String( animState.data.skeletonData.skins[i].name );
        }

        return ret;
    }

    spTrackEntry* getTrackEntry( uint num ) {
        if ( !animState ) return null;

        return spAnimationState_getCurrent( animState, num );
    }

private:
    void addRegion( CTexture texture, float* vertices, float* uvs, uint verticesCount, ushort* indices, uint indicesCount, SColorRGBA color ) {
        uint beginSize = Cast!uint( primitive.vertices.length / ELEMS_PER_VERTEX );
        primitive.texture = texture;

        foreach ( i; 0..verticesCount ) {
            primitive.vertices ~= vertices[i * 2];
            primitive.vertices ~= vertices[i * 2 + 1];
            primitive.vertices ~= uvs[i * 2];
            primitive.vertices ~= uvs[i * 2 + 1];
            primitive.vertices ~= color.r;
            primitive.vertices ~= color.g;
            primitive.vertices ~= color.b;
            primitive.vertices ~= color.a;
        }

        foreach ( i; 0..indicesCount ) {
            primitive.indices ~= beginSize + indices[i];
        }
    }

    bool spineInitialize() {
        assert( animState is null );

        if ( !lresource ) return false;
        if ( lresource.loadPhase != EResourceLoadPhase.SUCCESS ) return false;

        skeleton = spSkeleton_create( lresource.data );

        skeleton.scaleX = state.scale.x;
        skeleton.scaleY = state.scale.y * -1.0f;

        animState = spAnimationState_create( spAnimationStateData_create( skeleton.data ) );
        animState.rendererObject = Cast!( void* )( this );
        animState.listener = &spineAnimationCallback;

        animState.data.defaultMix = 0.1f;

        if ( state.skin != "" ) {
            skin = state.skin;
        }

        if ( state.animation.name != "" ) {
            play( state.animation.name, state.animation.track, state.animation.bLoop );
        }

        return true;
    }

    void spineDispose() {
        if ( animState ) {
            spAnimationStateData_dispose( animState.data );
            spAnimationState_dispose( animState );
        }

        if ( skeleton ) {
            spSkeleton_dispose( skeleton );
        }

        skeleton = null;
        animState = null;
    }

    extern( C )
    static void spineAnimationCallback( spAnimationState* pstate, spEventType ptype, void* ptrack, spEvent* pevent ) {
        CSpinePlayer player = Cast!CSpinePlayer( pstate.rendererObject );
        assert( player );

        switch ( ptype ) {
        case spEventType.SP_ANIMATION_EVENT:
            player.onEventReceived.emit( String( pevent.data.name ) );
            break;

        case spEventType.SP_ANIMATION_END:
            player.onEventReceived.emit( String( "spAnimationEnd" ) );
            break;

        case spEventType.SP_ANIMATION_COMPLETE:
            player.onEventReceived.emit( String( "spAnimationComplete" ) );
            break;

        default:
            break;
        }
    }

public:
    String currentAnim() { return state.animation.name; }

    @property {
        CSpineResource resource() { return lresource; }
        String skin() { return state.skin; }
        float mix() { return animState.data.defaultMix; }

        void resource( CSpineResource res ) {
            if ( res == lresource ) return;

            spineDispose();
            if ( res is null ) return;
            if ( res.loadPhase == EResourceLoadPhase.FAILED ) return;

            lresource = res;
        }

        void skin( String iskin ) {
            if ( skeleton is null ) {
                state.skin = iskin;
                state.bSkinSynced = false;
                return;
            }

            if ( state.skinData ) {
                //TODO: find why this is cause crash on windows
                //spSkin_dispose( state.skinData );
                state.skinData = null;
            }

            Array!String askins = iskin.split( rs!"|" );

            if ( askins.length == 1 ) {
                spSkeleton_setSkinByName( skeleton, iskin.c_str.cstr );
                state.bSkinSynced = true;
                return;
            }

            spSkin* nskin = spSkin_create( iskin.c_str.cstr );
            foreach ( single; askins ) {
                if ( !single.length ) continue;

                spSkin* t = spSkeletonData_findSkin( skeleton.data, single.c_str.cstr );
                if ( !t ) {
                    log.warning( "Invalid skin name: ", single );
                    continue;
                }

                spSkin_addSkin( nskin, t );
            }

            spSkeleton_setSkin( skeleton, nskin );
            spSkeleton_setSlotsToSetupPose( skeleton );
            spAnimationState_apply( animState, skeleton );

            state.skinData = nskin;
            state.bSkinSynced = true;
        }

        void mix( float value ) {
            if ( !animState ) return;

            animState.data.defaultMix = value;
        }
    }
}
