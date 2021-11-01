module editor.edtiors.animation;

import engine.thirdparty.spine.functions;

import engine.modules.neng_sub_math.curve;

import engine.framework;

import editor.base;

struct SImGUICurveEditorData {
    mixin( TRegisterStruct!SImGUICurveEditorData );
public:
    bool bSelectingQuad = false;
    ImVec2 quadSelection;
    int overCurve = -1;
    int movingCurve = -1;
    bool bScrollingV = false;
    Array!int selection;
    bool bOverSelectedPoint = false;

    bool bPointsMoved = false;
    ImVec2 mousePosOrigin;
    Array!ImVec2 origninalPoints;
}

int curveEditor( CCurve curve, SImGUICurveEditorData* data, SVec2I size, uint id ) {
    // Button draw function with press check functionality
    int drawPoint( ImDrawList* drawList, ImVec2 pos, ImVec2 size, ImVec2 offset, bool edited ) {
        int ret = 0;
        ImGuiIO* io = igGetIO();

        static immutable ImVec2[4] localOffsets = [
            ImVec2( 1, 0 ), ImVec2( 0, 1 ),
            ImVec2( -1, 0 ), ImVec2( 0, -1 )
        ];

        ImVec2[4] offsets;
        for ( int i = 0; i < 4; i++ ) {
            offsets[i].x = pos.x * size.x + localOffsets[i].x * 4.5f + offset.x;
            offsets[i].y = pos.y * size.y + localOffsets[i].y * 4.5f + offset.y;
        }

        ImVec2 center = ImVec2( pos.x * size.x + offset.x, pos.y * size.y + offset.y );
        SRect anchor = SRect( SVec2F( center.x - 5, center.y - 5 ), 10, 10 );

        drawList.AddConvexPolyFilled( offsets.ptr, 4, 0xFF000000 );

        if ( anchor.isInRect( SVec2F( io.MousePos.x, io.MousePos.y ) ) ) {
            igBeginTooltip();
                GImGUI.text( String( "X: ", pos.x ) );
                GImGUI.text( String( "Y: ", pos.y * 2 ) );
            igEndTooltip();

            ret = 1;
            if ( io.MouseDown[0] ) {
                ret = 2;
            }
        }

        if ( edited ) {
            drawList.AddPolyline( offsets.ptr, 4, 0xFFFFFFFF, true, 3.0 );
        } else if ( ret ) {
            drawList.AddPolyline( offsets.ptr, 4, 0xFF80B0FF, true, 2.0 );
        } else {
            drawList.AddPolyline( offsets.ptr, 4, 0xFF0080FF, true, 2.0 );
        }

        return ret;
    }

    assert( curve );

    int ret = 0;

    ImGuiIO* io = igGetIO();
    ImDrawList* drawList = igGetWindowDrawList();

    igPushStyleVarVec2( ImGuiStyleVar_FramePadding, ImVec2( 0, 0 ) );
    igPushStyleColor( ImGuiCol_Border, ImVec4( 0, 0, 0, 255 ) );
    igBeginChildFrame( id, ImVec2( size.x, size.y ) );

    ImVec2 offset = ImVec2( igGetCursorScreenPos().x, igGetCursorScreenPos().y + size.y );
    ImVec2 ssize = ImVec2( size.x, -size.y );
    SRect container;

    ImVec2 min = ImVec2( 0, 0 );
    ImVec2 max = ImVec2( 1, 1 );

    ImVec2 range = ImVec2( max.x - min.x + 1, max.y - min.y ); // +1 because of inclusive last frame
    ImVec2 viewSize = ImVec2( size.x, -size.y );
    ImVec2 sizeOfPixel = ImVec2( 1.0f / viewSize.x, 1.0f / viewSize.y );

    ImVec2 pointToRange( ImVec2 pt ) { return ImVec2( (pt.x - min.x) / range.x, (pt.y - min.y) / range.y ); }
    ImVec2 rangeToPoint( ImVec2 pt ) { return ImVec2( (pt.x * range.x) + min.x, (pt.y * range.y) + min.y ); }

    // Draw grid
    const GRID_SIZE = 10;

    for ( float x = 0.0f; x < viewSize.x; x += GRID_SIZE ) {
        drawList.AddLine(
            ImVec2( x + offset.x, offset.y ),
            ImVec2( x + offset.x, viewSize.y + offset.y ),
            IM_COL32( 200, 200, 200, 40 )
        );

        igSetCursorPos( ImVec2( x, 0.0 ) );
    }

    for ( float y = 0.0f; y > viewSize.y; y -= GRID_SIZE ) {
        drawList.AddLine(
            ImVec2( offset.x, y + offset.y ),
            ImVec2( viewSize.x + offset.x, y + offset.y ),
            IM_COL32( 200, 200, 200, 40 )
        );
    }

    Array!SCurvePoint points = curve.points;
    if ( points.length > 1 ) {
        // Draw curve by interpolated values
        for ( float i = 0.0; i < 1.0f; i += 0.01f ) {
            SVec2F ip1 = curve.interpolate( i );
            SVec2F ip2 = curve.interpolate( i + 0.01 );

            ImVec2 pos1 = ImVec2( i * viewSize.x + offset.x, ip1.y * viewSize.y + offset.y );
            ImVec2 pos2 = ImVec2( (i + 0.01) * viewSize.x + offset.x, ip2.y * viewSize.y + offset.y );

            drawList.AddLine( pos1, pos2, 0xFFFFFFFF, 1.3f );
        }

        foreach ( i, point; points ) {
            int buttonState =
                drawPoint(
                    drawList,
                    pointToRange( ImVec2( point.pos.x * 2, point.pos.y ) ),
                    viewSize,
                    offset,
                    data.selection.has( i )
                );

            if ( buttonState ) {
                data.bOverSelectedPoint = true;

                if ( buttonState == 2 ) {
                    if ( !io.KeyShift && !data.selection.has( i ) ) {
                        data.selection.free();
                    }

                    data.selection.appendUnique( cast( int )i );
                } else {
                    data.selection.free();
                }
            }
        }
    }

    if ( data.bOverSelectedPoint && io.MouseDown[0] ) {
        bool bMouseDeltaNotNull =
            Math.abs( io.MouseDelta.x ) > 0.0f ||
            Math.abs( io.MouseDelta.y ) > 0.0f;

        if ( bMouseDeltaNotNull && data.selection.length != 0 ) {
            if ( !data.bPointsMoved ) {
                data.mousePosOrigin = io.MousePos;
                data.origninalPoints.resize( data.selection.length );

                foreach ( i, sel; data.selection ) {
                    data.origninalPoints[i] = ImVec2( points[sel].pos.x, points[sel].pos.y );
                }
            }

            data.bPointsMoved = true;
            ret = 1;

            Array!int prevSelection = data.selection.copy();
            foreach ( i, sel; prevSelection ) {
                ImVec2 PTR = pointToRange( data.origninalPoints[i] );
                ImVec2 np = ImVec2(
                    PTR.x + (io.MousePos.x - data.mousePosOrigin.x) * sizeOfPixel.x / 2,
                    PTR.y + (io.MousePos.y - data.mousePosOrigin.y) * sizeOfPixel.y
                );

                if ( np.y < 0 ) {
                    np.y = 0;
                } else if ( np.y > 1 ) {
                    np.y = 1;
                }

                ImVec2 p = rangeToPoint( np );

                ulong newIndex = curve.updatePoint( sel, SVec2F( p.x, p.y ) );
                if ( sel != newIndex ) {
                    data.selection.remove( sel );
                    data.selection.appendUnique( cast( int )newIndex );
                }
            }
        }
    }

    if ( data.bOverSelectedPoint && !io.MouseDown[0] ) {
        data.bOverSelectedPoint = false;
        data.bPointsMoved = false;
    }

    if ( io.MouseDoubleClicked[0] ) {
        ImVec2 np = rangeToPoint( ImVec2(
            (io.MousePos.x - offset.x) / viewSize.x / 2,
            (io.MousePos.y - offset.y) / viewSize.y
        ) );

        curve.addPoint( SVec2F( np.x, np.y ) );
        ret = 1;
    }

    igEndChildFrame();
    igPopStyleVar();
    igPopStyleColor();

    return ret;
}

struct SAnimationEvent {
    mixin( TRegisterStruct!SAnimationEvent );
public:
    String name;
    float time;
}

struct SSingleAnimationConfig {
    mixin( TRegisterStruct!SSingleAnimationConfig );
public:
    String name;

    float speed;
    float mix;

    CCurve speedCurve;
    Array!SAnimationEvent events;
}

struct SAnimationEditorSkinsState {
    mixin( TRegisterStruct!SAnimationEditorSkinsState );
public:
    String highName;

    Array!String lowNames;
    uint selected = -1;
}

class CSpineAnimationConfig : CObject {
    mixin( TRegisterClass!CSpineAnimationConfig );
public:
    float defaultSpeed = 1.3f;
    float defaultMix = 0.3f;

protected:
    Dict!( SSingleAnimationConfig, String ) animationsCfg;

public:
    void setupFor( CSpinePlayer player ) {
        foreach ( k, v; animationsCfg ) {
            DestroyObject( v.speedCurve );
        }
        
        animationsCfg.free();

        foreach ( anim; player.animations ) {
            SSingleAnimationConfig basicConfig;
            basicConfig.name = anim;
            basicConfig.speed = defaultSpeed;
            basicConfig.mix = defaultMix;

            basicConfig.speedCurve = NewObject!CCurve();
            basicConfig.speedCurve.addPoint( SVec2F( 0.0f, 0.5f ) );
            basicConfig.speedCurve.addPoint( SVec2F( 1.0f, 0.5f ) );

            animationsCfg.set( anim, basicConfig );
        }
    }

    SSingleAnimationConfig* getConfigForAnimation( String name ) {
        if ( !animationsCfg.has( name ) ) {
            SSingleAnimationConfig basicConfig;
            basicConfig.name = name;
            basicConfig.speed = defaultSpeed;
            basicConfig.mix = defaultMix;

            basicConfig.speedCurve = NewObject!CCurve();
            basicConfig.speedCurve.addPoint( SVec2F( 0.0f, 0.5f ) );
            basicConfig.speedCurve.addPoint( SVec2F( 1.0f, 0.5f ) );

            animationsCfg.set( name, basicConfig );
        }

        return animationsCfg[name];
    }

    Array!SAnimationEvent getAnimationEvents( String name ) {
        SSingleAnimationConfig* config = getConfigForAnimation( name );

        return config.events;
    }

    bool isAnimationHasEvent( String name, String eventName ) {
        SSingleAnimationConfig* cfg = getConfigForAnimation( name );

        foreach ( event; cfg.events ) {
            if ( event.name == eventName ) {
                return true;
            }
        }

        return false;
    }

    bool addNewEventForAnimation( String name, SAnimationEvent event ) {
        if ( isAnimationHasEvent( name, event.name ) ) {
            log.error( "Animation '", name, "' already has event named '", event.name, "'" );
            return false;
        }

        SSingleAnimationConfig* cfg = getConfigForAnimation( name );
        
        cfg.events ~= event;
        return true;
    }
}

class CAnimationEditor : CBaseEditor {
    mixin( TRegisterClass!CAnimationEditor );
public:
    Signal!( CSpineResource ) onResourceChanged;
    Signal!( String ) onSkinChanged;

protected:
    CSpinePlayer player;

    CR2D_View lview;
    CR2D_Context lcontext;
    CR2D_SceneProxy lproxy;
    CRenderer2D lrenderer;

    CString inputBuffer;
    bool bEventNamePopup = false;
    bool bSkinsWindowOpen = false;

    bool bPlay = true;
    float speed = 1.0f;
    float mix = 0.3f;
    int animNum = 0;
    int skinNum = 0;
    float time = 0.0f;

    CSpineAnimationConfig config;

    Dict!( bool, String ) modSkins;
    Array!SAnimationEditorSkinsState skinsState;

    SImGUICurveEditorData cedata;

    int resNum = 0;
    Array!String resources;

public:
    this() {
        player = NewObject!CSpinePlayer();
        config = NewObject!CSpineAnimationConfig();

        SDirRef dir = GFileSystem.dir( "res/game/dev_test" );
        Array!SFSEntry entries = dir.entries();
        foreach ( entry; entries ) {
            if ( entry.path.isEndsWith( ".json" ) ) {
                resources ~= entry.path;
            }
        }

        player.resource = GResourceManager.loadStatic!CSpineResource( resources[resNum] );
        player.skin = rs!"Skin_1";
        player.scale( 0.4f, 0.4f );
        player.update( 0.016 );

        config.setupFor( player );

        lview = NewObject!CR2D_View( 256, 256 );
        lcontext = NewObject!CR2D_Context();
        lproxy = NewObject!CR2D_SceneProxy();
        lrenderer = NewObject!CRenderer2D();

        lproxy ~= player.primitive;

        player.play( "Attack", 0, true );

        inputBuffer.resize( 256 );
        modSkins.set( "Skin_1", true );

        foreach ( skin; player.skins ) {
            Array!String split = skin.split( rs!"/" );

            if ( split.length != 2 ) continue;

            SAnimationEditorSkinsState* state;

            if ( split[0] == "Head" || split[0] == "head" ) {
                skinsState ~= SAnimationEditorSkinsState();

                state = skinsState.pget( skinsState.length - 1 );
                state.highName = split[0];
                state.lowNames ~= split[1];
                continue;
            }

            foreach ( i, st; skinsState ) {
                if ( st.highName == split[0] ) {
                    state = skinsState.pget( i );
                }
            }

            if ( !state ) {
                skinsState ~= SAnimationEditorSkinsState();

                state = skinsState.pget( skinsState.length - 1 );
                state.highName = split[0];
            }

            state.lowNames ~= split[1];
        }
    }

    override void draw() {
        player.update( bPlay ? 0.016f : 0.0f );

        lproxy ~= player.primitive;
        player.primitive.position = SVec2F( 128, 230 );
        lrenderer.render( lproxy, lcontext, lview );

        Array!String animations = player.animations;
        Array!String skins = player.skins;

        spTrackEntry* entry = player.getTrackEntry( 0 );
        if( entry ) {
            time = spTrackEntry_getAnimationTime( entry );
        }

        SSingleAnimationConfig* currentConfig = config.getConfigForAnimation( animations[animNum] );
        player.speed = (currentConfig.speedCurve.interpolate( time / entry.animationEnd ) * 2) * currentConfig.speed;

        if ( !GImGUI.begin(
                "Animation",
                null,
                ImGuiWindowFlags_MenuBar |
                ImGuiWindowFlags_AlwaysAutoResize
            ) ) {
            GImGUI.end();
            return;
        }

        igBeginMenuBar();
            if ( igBeginMenu( "File" ) ) {
                foreach ( i, res; resources ) {
                    if ( GImGUI.selectable( res, i == resNum ) ) {
                        resNum = cast( int )i;
                        resource = GResourceManager.loadStatic!CSpineResource( resources[resNum] );
                    }
                }
                igEndMenu();
            }
        igEndMenuBar();

        GImGUI.beginChild( "AnimationsList", SVec2I( 150, 350 ) );
            GImGUI.text( "Animations" );
            GImGUI.separator();
            foreach ( i, anim; animations ) {
                if ( GImGUI.selectable( anim, i == animNum ) ) {
                    bPlay = true;
                    animNum = cast( int )i;
                    player.play( animations[animNum], 0, true );
                }
            }
        GImGUI.endChild();

        GImGUI.sameLine();

        GImGUI.beginChild( "EventsList", SVec2I( 150, 350 ) );
            GImGUI.text( "Events" );
            GImGUI.separator();
            Array!SAnimationEvent events = config.getAnimationEvents( animations[animNum] );
            foreach ( event; events ) {
                if ( GImGUI.selectable( String( event.name, ":", event.time ) ) ) {
                    entry.trackTime = event.time;
                    bPlay = false;
                }
            }
        GImGUI.endChild();

        GImGUI.sameLine();

        GImGUI.beginChild( "AnimEdit", SVec2I( 450, 450 ) );
            GImGUI.image( lview.framebuffer );

            if ( GImGUI.button( "|>/||" ) ) {
                bPlay = !bPlay;
            }

            GImGUI.sameLine();

            if ( GImGUI.button( "New event" ) ) {
                bPlay = false;
                bEventNamePopup = true;
            }

            if ( GImGUI.sliderFloat( "Speed", &currentConfig.speed, 0.0f, 2.0f ) ) {}

            if ( GImGUI.sliderFloat( "Time", &time, 0, player.resource.getAnimationLength( animations[animNum] ) ) ) {
                bPlay = false;
                entry.trackTime = time;
            }

            curveEditor( currentConfig.speedCurve, &cedata, SVec2I( 400, 75 ), 10920 );
        GImGUI.endChild();

        GImGUI.sameLine();

        GImGUI.beginChild( "SkinsEditor", SVec2I( 150, 350 ) );
            bool bNeedUpdateSkin = false;

            foreach ( j, state; skinsState ) {
                if ( igCollapsingHeader( state.highName.c_str.cstr ) ) {
                    foreach ( i, lname; state.lowNames ) {
                        if ( GImGUI.selectable( String( "\t", lname ), state.selected == i ) ) {
                            if ( state.selected == i ) {
                                skinsState[j].selected = -1;
                            } else {
                                skinsState[j].selected = cast( int )i;
                            }
                            bNeedUpdateSkin = true;
                        }
                    }
                }
            }

            String skinCfg;

            if ( bNeedUpdateSkin ) {
                foreach ( state; skinsState ) {
                    if ( state.selected != -1 ) {
                        skinCfg ~= String( state.highName, "/", state.lowNames[state.selected], "|" );
                    }
                }

                if ( player.skin != skinCfg ) {
                    player.skin = skinCfg;
                    onSkinChanged.emit( skinCfg );
                }
            }
        GImGUI.endChild();

        GImGUI.end();

        if ( bEventNamePopup ) {
            igOpenPopup( "Event create" );
        }

        if ( igBeginPopupModal( "Event create", &bEventNamePopup, ImGuiWindowFlags_AlwaysAutoResize ) ) {
            if ( igInputText( "Name", cast( char* )inputBuffer.ptr, inputBuffer.length ) ) {
            }
                
            if ( GImGUI.button( "Create" ) ) {
                String name = String( inputBuffer.cstr );
                if ( name != "" ) {
                    SAnimationEvent event;
                    event.name = name;
                    event.time = time;

                    config.addNewEventForAnimation( animations[animNum], event );

                    inputBuffer = "";
                    inputBuffer.resize( 256 );
                    bEventNamePopup = false;
                    igCloseCurrentPopup();
                }
            }

            GImGUI.sameLine();

            if ( GImGUI.button( "Close" ) ) {
                bEventNamePopup = false;
                igCloseCurrentPopup();
            }

            igEndPopup();
        }
    }

public:
    @resource {
        CSpineResource resource() { return player.resource; }

        void resource( CSpineResource res ) {
            onResourceChanged.emit( res );

            player.resource = res;
            player.skin = rs!"Skin_1";
            player.update( 0.015f );

            config.setupFor( player );

            skinsState.free();
            
            foreach ( skin; player.skins ) {
                Array!String split = skin.split( rs!"/" );

                if ( split.length != 2 ) continue;

                SAnimationEditorSkinsState* state;
            if ( split[0] == "Head" || split[0] == "head" ) {
                skinsState ~= SAnimationEditorSkinsState();

                state = skinsState.pget( skinsState.length - 1 );
                state.highName = split[0];
                state.lowNames ~= split[1];
                continue;
            }

                foreach ( i, st; skinsState ) {
                    if ( st.highName == split[0] ) {
                        state = skinsState.pget( i );
                    }
                }

                if ( !state ) {
                    skinsState ~= SAnimationEditorSkinsState();

                    state = skinsState.pget( skinsState.length - 1 );
                    state.highName = split[0];
                }

                state.lowNames ~= split[1];
            }
        }
    }
}
