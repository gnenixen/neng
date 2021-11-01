module engine.thirdparty.spine.types;

alias spAnimationStateListener = extern( C ) void function( spAnimationState* state, spEventType type, void* entry, spEvent* event );
alias spMallocFunc = extern( C ) void* function( size_t psize );
alias spReallocFunc = extern( C ) void* function( void* ptr, size_t psize );
alias spFreeFunc = extern( C ) void function( void* ptr );

enum spEventType {
    SP_ANIMATION_START,
    SP_ANIMATION_INTERRUPT,
    SP_ANIMATION_END,
    SP_ANIMATION_COMPLETE,
    SP_ANIMATION_DISPOSE,
    SP_ANIMATION_EVENT
}

enum spAtlasFormat {
    SP_ATLAS_UNKNOWN_FORMAT,
    SP_ATLAS_ALPHA,
    SP_ATLAS_INTENSITY,
    SP_ATLAS_LUMINANCE_ALPHA,
    SP_ATLAS_RGB565,
    SP_ATLAS_RGBA4444,
    SP_ATLAS_RGB888,
    SP_ATLAS_RGBA8888
}

enum spAtlasFilter {
    SP_ATLAS_UNKNOWN_FILTER,
    SP_ATLAS_NEAREST,
    SP_ATLAS_LINEAR,
    SP_ATLAS_MIPMAP,
    SP_ATLAS_MIPMAP_NEAREST_NEAREST,
    SP_ATLAS_MIPMAP_LINEAR_NEAREST,
    SP_ATLAS_MIPMAP_NEAREST_LINEAR,
    SP_ATLAS_MIPMAP_LINEAR_LINEAR
}

enum spAtlasWrap {
    SP_ATLAS_MIRROREDREPEAT,
    SP_ATLAS_CLAMPTOEDGE,
    SP_ATLAS_REPEAT
}

enum spTransformMode {
    SP_TRANSFORMMODE_NORMAL,
    SP_TRANSFORMMODE_ONLYTRANSLATION,
    SP_TRANSFORMMODE_NOROTATIONORREFLECTION,
    SP_TRANSFORMMODE_NOSCALE,
    SP_TRANSFORMMODE_NOSCALEORREFLECTION
}

enum spBlendMode {
    SP_BLEND_MODE_NORMAL,
    SP_BLEND_MODE_ADDITIVE,
    SP_BLEND_MODE_MULTIPLY,
    SP_BLEND_MODE_SCREEN
}

enum spPositionMode {
    SP_POSITION_MODE_FIXED,
    SP_POSITION_MODE_PERCENT
}

enum spSpacingMode {
    SP_SPACING_MODE_LENGTH,
    SP_SPACING_MODE_FIXED,
    SP_SPACING_MODE_PERCENT
}

enum spRotateMode {
    SP_ROTATE_MODE_TANGENT,
    SP_ROTATE_MODE_CHAIN,
    SP_ROTATE_MODE_CHAIN_SCALE
}

enum spAttachmentType {
    SP_ATTACHMENT_REGION,
    SP_ATTACHMENT_BOUNDING_BOX,
    SP_ATTACHMENT_MESH,
    SP_ATTACHMENT_LINKED_MESH,
    SP_ATTACHMENT_PATH,
    SP_ATTACHMENT_POINT,
    SP_ATTACHMENT_CLIPPING
}

enum spMixBlend {
    SP_MIX_BLEND_SETUP,
    SP_MIX_BLEND_FIRST,
    SP_MIX_BLEND_REPLACE,
    SP_MIX_BLEND_ADD,
}

enum spMixDirection {
    SP_MIX_DIRECTION_IN,
    SP_MIX_DIRECTION_OUT,
}

struct spAttachmentLoader {
    const( char )* error1;
    const( char )* error2;

    void* vtable;
}

struct spAtlasAttachmentLoader {
    spAttachmentLoader _super;
    spAtlas* atlas;
}

struct spSkeletonJson {
    float scale;
    void* attachmentLoader;
    const( char )* error;
}

struct spColor {
    float r, g, b, a;
}

struct spEventData {
    const( char )* name;
    int intValue;
    float floatValue;
    const( char )* stringValue;
    const( char )* audioPath;
    float volume;
    float balance;
}

struct spEvent {
    spEventData* data;
    float time;
    int intValue;
    float floatValue;
    const( char )* stringValue;
    float volume;
    float balance;
}

struct spAnimation {
    const( char )* name;
    float duration;

    int timelinesCount;
    void** timelines;
}

struct spAnimationStateData {
    spSkeletonData* skeletonData;
    float defaultMix;
    void* entries;
}

struct spTrackEntry {
    spAnimation* animation;
    spTrackEntry* next;
    spTrackEntry* mixingFrom;
    spTrackEntry* mixingTo;
    spAnimationStateListener listener;
    int trackIndex;
    int loop;
    int holdPrevious;
    float eventThreshold, attachmentThreshold, drawOrderThreshold;
    float animationStart, animationEnd, animationLast, nextAnimationLast;
    float delay, trackTime, trackLast, nextTrackLast, trackEnd, timeScale;
    float alpha, mixTime, mixDuration, interruptAlpha, totalAlpha;
    spMixBlend mixBlend;
    void* timelineMode;
    void* timelineHoldMix;
    float* timelineRotation;
    int timelineRotationCount;
    void* rendererObject;
    void* userData;
}

struct spAnimationState {
    spAnimationStateData* data;

    int tracksCount;
    spTrackEntry** tracks;

    spAnimationStateListener listener;

    float timeScale;

    void* rendererObject;
    void* userData;

    int unkeyedState;
}

struct spAtlas {
    spAtlasPage* pages;
    spAtlasRegion* regions;

    void* renderObject;
}

struct spAtlasPage {
    const spAtlas* atlas;
    const( char )* name;
    spAtlasFormat format;
    spAtlasFilter minFilter, magFilter;
    spAtlasWrap uWrap, vWrap;

    void* renderObject;
    int width, height;

    spAtlasPage* next;
}

struct spAtlasRegion {
    const( char )* name;
    int x, y, width, height;
    float u, v, u2, v2;
    int offsetX, offsetY;
    int originalWidth, originalHeight;
    int index;
    int rotate; /*bool*/
    int degrees;
    int flip; /*bool*/
    int* splits;
    int* pads;

    spAtlasPage* page;
    spAtlasRegion* next;
}

struct spBoneData {
    const int index;
    const( char )* name;
    spBoneData* parent;
    float length;
    float x, y, rotation, scaleX, scaleY, shearX, shearY;
    spTransformMode transfromMode;
    int skinRequired; /*bool*/
}

struct spBone {
    spBoneData* data;
    spSkeleton* skeleton;
    spBone* parent;
    int childrenCount;
    spBone** children;
    float x, y, rotation, scaleX, scaleY, shearX, shearY;
    float ax, ay, arotation, ascaleX, ascraleY, ashearX, ashearY;
    int appliedValid; /*bool*/

    float a, b, worldX;
    float c, d, worldY;

    int sorted; /*bool*/
    int active; /*bool*/
}

struct spSlotData {
    const int index;
    const( char )* name;
    spBoneData* boneData;
    const( char )* attachmentName;
    spColor color;
    spColor* darkColor;
    spBlendMode blendMode;
}

struct spSlot {
    spSlotData* data;
    spBone* bone;
    spColor color;
    spColor* darkColor;
    spAttachment* attachment;
    int attachmentState;

    int deformCapacity;
    int deformCount;
    float* deform;
}

struct spSkin {
    const( char )* name;

    void* bones;
    void* ikConstraints;
    void* transformConstraints;
    void* pathConstraints;
}

struct spIkConstraintData {
    const( char )* name;
    int order;
    int skinRequired; /*bool*/
    int bonesCount;
    spBoneData** bones;

    spBoneData* target;
    int bendDirection;
    int /*boolean*/ compress;
    int /*boolean*/ stretch;
    int /*boolean*/ uniform;
    float mix;
    float softness;
}

struct spIkConstraint {
    spIkConstraintData* data;

    int bonesCount;
    spBone** bones;

    spBone* target;
    int bendDirection;
    int /*boolean*/ compress;
    int /*boolean*/ stretch;
    float mix;
    float softness;

    int /*boolean*/ active;
}

struct spTransformConstraintData {
    const( char )* name;
    int order;
    int/*bool*/ skinRequired;
    int bonesCount;
    spBoneData** bones;
    spBoneData* target;
    float rotateMix, translateMix, scaleMix, shearMix;
    float offsetRotation, offsetX, offsetY, offsetScaleX, offsetScaleY, offsetShearY;
    int /*boolean*/ relative;
    int /*boolean*/ local;
}

struct spTransformConstraint {
    spTransformConstraintData* data;
    int bonesCount;
    spBone** bones;
    spBone* target;
    float rotateMix, translateMix, scaleMix, shearMix;
    int /*boolean*/ active;
}

struct spPathConstraintData {
    const( char )* name;
    int order;
    int/*bool*/ skinRequired;
    int bonesCount;
    spBoneData** bones;
    spSlotData* target;
    spPositionMode positionMode;
    spSpacingMode spacingMode;
    spRotateMode rotateMode;
    float offsetRotation;
    float position, spacing, rotateMix, translateMix;
}

struct spPathConstraint {
    spPathConstraintData* data;
    int bonesCount;
    spBone** bones;
    spSlot* target;
    float position, spacing, rotateMix, translateMix;

    int spacesCount;
    float* spaces;

    int positionsCount;
    float* positions;

    int worldCount;
    float* world;

    int curvesCount;
    float* curves;

    int lengthsCount;
    float* lengths;

    float[10] segments;

    int /*boolean*/ active;
}

struct spSkeletonData {
    const( char )* _version;
    const( char )* hash;
    float x, y, width, height;

    int stringsCount;
    char** strings;

    int bonesCount;
    spBoneData** bones;

    int slotsCount;
    spSlotData** slots;

    int skinsCount;
    spSkin** skins;
    spSkin* defaultSkin;

    int eventsCount;
    spEventData** events;

    int animationsCount;
    spAnimation** animations;

    int ikConstraintsCount;
    spIkConstraintData** ikConstraints;

    int transformConstraintsCount;
    spTransformConstraintData** transformConstraints;

    int pathConstraintsCount;
    spPathConstraintData** pathConstraints;
}

struct spSkeleton {
    spSkeletonData* data;

    int bonesCount;
    spBone** bones;
    spBone* root;

    int slotsCount;
    spSlot** slots;
    spSlot** drawOrder;

    int ikConstraintsCount;
    spIkConstraint** ikConstraints;

    int transformConstraintsCount;
    spTransformConstraint** transformConstraints;

    int pathConstraintsCount;
    spPathConstraint** pathConstraints;

    spSkin* skin;
    spColor color;
    float time;
    float scaleX, scaleY;
    float x, y;
}

struct spAttachment {
    const( char )* name;
    const spAttachmentType type;
    const void* vtable;
    int refCount;
    void* attachmentLoader;
}

struct spRegionAttachment {
    spAttachment _super;
    const( char )* path;
    float x, y, scaleX, scaleY, rotation, width, height;
    spColor color;

    void* rendererObject;
    int regionOffsetX, regionOffsetY; /* Pixels stripped from the bottom left, unrotated. */
    int regionWidth, regionHeight; /* Unrotated, stripped pixel size. */
    int regionOriginalWidth, regionOriginalHeight; /* Unrotated, unstripped pixel size. */

    float[8] offset;
    float[8] uvs;
}

struct spVertexAttachment {
    spAttachment _super;

    int bonesCount;
    int* bones;

    int verticesCount;
    float* vertices;

    int worldVerticesLength;

    spVertexAttachment* deformAttachment;

    int id;
}

struct spMeshAttachment {
    spVertexAttachment _super;

    void* rendererObject;
    int regionOffsetX, regionOffsetY; /* Pixels stripped from the bottom left, unrotated. */
    int regionWidth, regionHeight; /* Unrotated, stripped pixel size. */
    int regionOriginalWidth, regionOriginalHeight; /* Unrotated, unstripped pixel size. */
    float regionU, regionV, regionU2, regionV2;
    int/*bool*/regionRotate;
    int regionDegrees;

    const( char )* path;

    float* regionUVs;
    float* uvs;

    int trianglesCount;
    ushort* triangles;

    spColor color;

    int hullLength;

    spMeshAttachment* parentMesh;

    /* Nonessential. */
    int edgesCount;
    int* edges;
    float width, height;
}

