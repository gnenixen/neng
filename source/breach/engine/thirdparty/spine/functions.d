module engine.thirdparty.spine.functions;

import engine.thirdparty.spine.types;

extern extern(C) @nogc {
    void spRegionAttachment_computeWorldVertices( spRegionAttachment* self, spBone* bone, float* vertices, int offset, int stride );

    void spVertexAttachment_computeWorldVertices( spVertexAttachment* self, spSlot* slot, int strt, int count, float* worldVertived, int offset, int stride );

    void spColor_setFromFloats( spColor* color, float r, float g, float b, float a );

    spAtlas* spAtlas_createFromFile( const( char )* path, void* renderObject );
    spAtlas* spAtlas_create( const( ubyte )* begin, int length, const( char )* dir, void* renderObject );
    void spAtlas_dispose( spAtlas* atlas );

    spAnimationStateData* spAnimationStateData_create( spSkeletonData* skeletonData );
    void spAnimationStateData_dispose( spAnimationStateData* self );
    void spAnimationStateData_setMixByName( spAnimationStateData* self, const( char )* fromName, const( char )* toName, float duration );

    spAnimationState* spAnimationState_create( spAnimationStateData* data );
    void spAnimationState_dispose( spAnimationState* state );
    void spAnimationState_update( spAnimationState* self, float delta );
    int /**bool**/ spAnimationState_apply( spAnimationState* self, spSkeleton* skeleton );
    void* spAnimationState_setAnimation( spAnimationState* self, int trackIndex, spAnimation* animation, int/*bool*/loop );
    void* spAnimationState_addAnimation( spAnimationState* self, int trackIndex, spAnimation* animation, int/*bool*/loop, float delay );
    void spAnimationState_clearTracks( spAnimationState* self );
    void spAnimationState_clearTrack( spAnimationState* self, int trackIndex );
    spTrackEntry* spAnimationState_getCurrent( spAnimationState* self, int trackIndex );

    float spTrackEntry_getAnimationTime( spTrackEntry* entry );

    void spSkeletonData_dispose( spSkeletonData* self );
    spAnimation* spSkeletonData_findAnimation( const spSkeletonData* self, const( char )* animationName );
    spSkin* spSkeletonData_findSkin( const spSkeletonData* self, const( char )* skinName );

    spSkeleton* spSkeleton_create( spSkeletonData* data );
    void spSkeleton_dispose( spSkeleton* self );
    void spSkeleton_updateWorldTransform( spSkeleton* self );
    void spSkeleton_setToSetupPose( const spSkeleton* self );
    void spSkeleton_setSkin( spSkeleton* self, spSkin* skin );
    int spSkeleton_setSkinByName( spSkeleton* self, const( char )* skinName );
    spAttachment* spSkeleton_getAttachmentForSlotName( const spSkeleton* self, const( char )* slotName, const( char )* attachmentName );
    spBone* spSkeleton_findBone( const spSkeleton* self, const( char )* boneName );
    spSlot* spSkeleton_findSlot( const spSkeleton* self, const( char )* slotName );
    int spSkeleton_setAttachment( spSkeleton* self, const( char )* slotName, const( char )* attachmentName );
    void spSkeleton_setSlotsToSetupPose( spSkeleton* self );

    spSkin* spSkin_create( const( char )* skinName );
    void spSkin_dispose( spSkin* self );
    void spSkin_addSkin( spSkin* self, spSkin* other );

    spSkeletonJson* spSkeletonJson_create( spAtlas* atlas );
    void spSkeletonJson_dispose( spSkeletonJson* self );
    spSkeletonData* spSkeletonJson_readSkeletonDataFile( spSkeletonJson* self, const( char )* path );
    spSkeletonData* spSkeletonJson_readSkeletonData( spSkeletonJson* self, const( char )* json );

    float spBone_getWorldRotationX( spBone* self );
    float spBone_getWorldScaleX( spBone* self );
    float spBone_getWorldScaleY( spBone* self );

    void _spSetMalloc( spMallocFunc func );
    void _spSetRealloc( spReallocFunc func );
    void _spSetFree( spFreeFunc func );
    char* _spReadFile( const( char )* path, int* length );
}
