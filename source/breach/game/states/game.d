module game.states.game;

import engine.framework.imgui;
import engine.framework.scene_tree;
import engine.framework.postprocess;
import engine.framework.resources.ldtk;
import engine.framework.render.r2d;
import engine.framework.console;

import game.core.base;
import game.core.state;
import game.core.world;
import game.core.objects;

import game.gapi.characters;

SColorRGBA ambient = EColors.WHITE;
bool bSomeStrangeFunc = false;

void stange_func( CConsole console, Array!String args ) {
    bSomeStrangeFunc = !bSomeStrangeFunc;
}

class CDamageTrigger : CTrigger {
    mixin( TRegisterClass!CDamageTrigger );
public:
    this() {
        //super( EP2DBodyType.DYNAMIC );
        super();
    }

    override void onObjectEnter( CGameObject object ) {
        import game.gapi.characters.player;

        CPlayer player = Cast!CPlayer( object );
        if ( player ) {
            player.health.damage( 20 );
        }
    }

    override void onObjectOut( CGameObject obj ) {
    }
}

class _CCamera2D : CNode2D {
    mixin( TRegisterClass!CCamera2D );
public:
    ECamera2DCenterMode mode = ECamera2DCenterMode.CENTER;

private:
    CSceneTreeRenderCamera lcamera;

    CR2D_Light light;

    float _skaleDuration = 0.0f;
    float shakeDuration = 0.0f;
    float shakeMagnitude = 0.0f;
    float shakeNoize = 0.0f;
    SVec2F shakeNoizeStartPoint0;
    SVec2F shakeNoizeStartPoint1;

public:
    this() {
        lcamera = newObject!CSceneTreeRenderCamera( 1280, 720 );
        light = newObject!CR2D_Light();

        light.texture = GResourceManager.load!CTexture( "res/Light512.png" );
        light.color = EColors.BLUE;
    }

    ~this() {
        destroyObject( lcamera );
    }

    override void tick( float delta ) {
        import engine.modules.sound;

        if ( shakeDuration > 0.0f ) {
            shakeDuration -= delta;
        }

        SVec2F pos = worldTransform.pos;

        SSoundListenerData listener;
        listener.position = SVec3F( pos.x + size.x / 2.0f, pos.y + size.y / 2.0f, 0.0f );

        //log.warning( listener.position.x, " ", listener.position.y );

        GSoundServer.listener = listener;
    }

    void shake( float duration, float magnitude, float noize ) {
        _skaleDuration = duration;
        shakeDuration = duration;
        shakeMagnitude = magnitude;
        shakeNoize = noize;

        shakeNoizeStartPoint0 = SVec2F( Math.randf( -1.0f, 1.0f ) * noize );
        shakeNoizeStartPoint1 = SVec2F( Math.randf( -1.0f, 1.0f ) * noize );
    }

protected:
    override void render( CSceneTreeRender renderer ) {
        renderer.registerCamera( lcamera );
        //renderer.registerPrimitive( light );

        switch ( mode ) {
        case ECamera2DCenterMode.UP_LEFT_CORNER:
            lcamera.view.position = worldTransform.pos;
            break;
        
        case ECamera2DCenterMode.CENTER:
            if ( shakeDuration <= 0.0f ) {
                lcamera.view.position = worldTransform.pos - (lcamera.view.resolution.tov!float / 2.0f);
            } else {
                float delta = shakeDuration / _skaleDuration;

                SVec2F currentNoizePoint0 = SVec2F( Math.lerp( shakeNoizeStartPoint0.x, 0, delta ), Math.lerp( shakeNoizeStartPoint0.y, 0, delta ) );
                SVec2F currentNoizePoint1 = SVec2F( Math.lerp( shakeNoizeStartPoint1.x, 0, delta ), Math.lerp( shakeNoizeStartPoint1.y, 0, delta ) );

                SVec2F camPosDelta = SVec2F( Math.perlinNoise( currentNoizePoint0.x, currentNoizePoint0.y ), Math.perlinNoise( currentNoizePoint1.x, currentNoizePoint1.y ) );
                camPosDelta *= shakeMagnitude;

                lcamera.view.position = worldTransform.pos - (lcamera.view.resolution.tov!float / 2.0f) + camPosDelta;
            }
            break;
        
        default:
            assert( false );
        }

        light.position = lcamera.view.position;
    }

public:
    @property {
        void size( SVec2I nsize ) { lcamera.view.resolution = nsize; }
        SVec2I size() { return lcamera.view.resolution; }
    }
}

class CTempGUI : CNode2D {
    mixin( TRegisterClass!CTempGUI );
public:
    Array!CSprite healthBG;
    Array!CSprite staminaBG;

    Array!CSprite health;
    Array!CSprite stamina;

    this() {
        transform.size = SVec2F( 0.5f );

        SVec2I hbgp = SVec2I( 100, 200 );
        SVec2I sbgp = SVec2I( 100, 200 + 84 / 2 + 20 );

        foreach ( i; 0..5 ) {
            CSprite spr = newObject!CSprite();
            spr.texture = GResourceManager.load!CTexture( "res/game/dev_test/gui/Health1.png" );
                
            spr.transform.pos = hbgp.tov!float + SVec2I( i * 84, 0 ).tov!float;
            spr.transform.pos *= transform.size;
            //spr.modulate = getColorFromHex( String( "#ac3334" ) );
            spr.modulate = EColors.RED;

            health ~= spr;

            addChild( spr );
        }

        foreach ( i; 0..6 ) {
            CSprite spr = newObject!CSprite();
            spr.texture = GResourceManager.load!CTexture( "res/game/dev_test/gui/Stamina.png" );
                
            spr.transform.pos = sbgp.tov!float + SVec2I( i * 76, 0 ).tov!float;
            spr.transform.pos *= transform.size;
            spr.modulate = getColorFromHex( String( "#e46e01" ) );

            stamina ~= spr;

            addChild( spr );
        }

        foreach ( i; 0..5 ) {
            CSprite spr = newObject!CSprite();
            spr.texture = GResourceManager.load!CTexture( "res/game/dev_test/gui/HealthBg.png" );

            spr.transform.pos = hbgp.tov!float + SVec2I( i * 84, 0 ).tov!float;
            spr.transform.pos *= transform.size;
            spr.modulate = getColorFromHex( String( "#000002" ) );

            healthBG ~= spr;

            addChild( spr );
        }

        foreach ( i; 0..6 ) {
            CSprite spr = newObject!CSprite();
            spr.texture = GResourceManager.load!CTexture( "res/game/dev_test/gui/StaminaBg.png" );
                
            spr.transform.pos = sbgp.tov!float + SVec2I( i * 76, 0 ).tov!float;
            spr.transform.pos *= transform.size;
            spr.modulate = getColorFromHex( String( "#000002" ) );

            staminaBG ~= spr;

            addChild( spr );
        }
    }

    void reset() {
        foreach ( i; 0..5 ){
            //health[i].modulate = getColorFromHex( String( "#ac3334" ) );
            health[i].modulate = EColors.RED;
        }

        foreach ( i; 0..6 ) {
            stamina[i].modulate = getColorFromHex( String( "#e46e01" ) );
        }
    }

    void onStaminaUpdated( uint current ) {
        current /= 2;

        foreach ( i; current..6 ) {
            stamina[i].modulate = getColorFromHex( String( "#5b2c02" ) );
        }

        foreach ( i; 0..current ) {
            stamina[i].modulate = getColorFromHex( String( "#e46e01" ) );
        }
    }

    void onHealthUpdated( uint current ) {
        current /= 20;

        foreach ( i; current..5 ) {
            health[i].modulate = getColorFromHex( String( "#671f20" ) );
        }

        foreach ( i; 0..current ){
            //health[i].modulate = getColorFromHex( String( "#ac3334" ) );
            health[i].modulate = EColors.RED;
        }
    }
}

import editor.editors.animation;

class CGameState_Game : CGameState {
    mixin( TRegisterClass!CGameState_Game );
protected:
    CGameWorld world;
    _CCamera2D camera;
    CPlayer player;
    CTEST enemy;

    CSceneTree tree;
    CSceneTreeRender treeRender;
    CNode2D charactersNode;

    CPostProcess postprocess;

    bool bReload = false;

    float slowmotion = 0.0f;
    float slowmotionStrength = 2.0f;

    Array!CChangeLevelTrigger triggers;
    Array!CChangeLevelTrigger oldTriggers;

    CTempGUI tempGUI;

    float time = 0.0f;

    CAnimationEditor animationEditor;
        import engine.core.utils.profile;

public:
    this() {
        super();

        tempGUI = newObject!CTempGUI();

        world = newObject!CGameWorld();
        camera = newObject!_CCamera2D();
        player = createPlayer();
        tree = newObject!CSceneTree();
        treeRender = newObject!CSceneTreeRender();
        postprocess = newObject!CPostProcess();

        world.onLevelChanged.connect( &onLevelChanged );

        postprocess.add(
            rdMakePipeline(
                rs!"res/game/shaders/chromatic_aberration_vertex.shader",
                rs!"res/game/shaders/chromatic_aberration_pixel.shader"
            )
        );

        postprocess.add(
            rdMakePipeline(
                rs!"res/game/shaders/vignette_vertex.shader",
                rs!"res/game/shaders/vignette_pixel.shader"
            )
        );

        postprocess.add(
            rdMakePipeline(
                rs!"res/game/shaders/tilt_shift_vertex.shader",
                rs!"res/game/shaders/tilt_shift_pixel.shader"
            )
        );

        postprocess.add(
            rdMakePipeline(
                rs!"res/game/shaders/light_vertex.shader",
                rs!"res/game/shaders/light_pixel.shader"
            )
        );

        postprocess.set( "lightPos", var( SVec2F( 0 ) ) );

        charactersNode = NewObject!CNode2D();

        player.transform.pos.x = 500;
        player.transform.pos.y = 800;

        CNode root = newObject!CNode();
        tree.root = root;

        CTEST test = newObject!CTEST( player, world.mpathfinder );
        enemy = test;
        test.transform.pos.x = 1200;
        test.transform.pos.y = 800;
        test.physics.filterData = SP2DFilterData( 0x0002, 0x0001 );

        //testDamageTrigger = newObject!CDamageTrigger();
        //testDamageTrigger.resize( 10, 50 );
        //testDamageTrigger.transform.pos = SVec2F( 1000, 1300 );


        root.addChild( charactersNode );
        root.addChild( tempGUI );
        root.addChild( camera );
        //root.addChild( testDamageTrigger );
        //charactersNode.addChild( test );
        charactersNode.addChild( player );
        root.addChild( world );

        world.loadFromFile( "res/breach_dev.ldtk" );
        world.changeLevel( "Level_0" );

        treeRender.context.clearColor = world.currentLevel.bgColor;

        player.stamina.currentUpdated.connect( &tempGUI.onStaminaUpdated );
        player.health.hpUpdated.connect( &tempGUI.onHealthUpdated );

        GConsole.register( "wtf", &stange_func );

        animationEditor = NewObject!CAnimationEditor();
        animationEditor.onResourceChanged.connect( &onResChanged );
        animationEditor.onSkinChanged.connect( &onSkinChanged );
        //profiler.stop();
        //log.warning( profiler.getExecutionTimeInSeconds );
    }

    void onResChanged( CSpineResource res ) {
        player.animation.resource = res;
        player.animation.skin = rs!"Skin_1";
    }

    void onSkinChanged( String anim ) {
        player.animation.skin = anim;
    }

    override void ptick( float delta ) {
        if ( slowmotion >= 0.0f ) {
            delta /= slowmotionStrength;
        }

        if ( oldTriggers.length ) {
            foreach ( trigger; oldTriggers ) {
                destroyObject( trigger );
            }
            oldTriggers.free();
        }

        //if ( enemy ) {
            //testDamageTrigger.transform.pos = enemy.transform.pos + SVec2F( 20 * enemy.direction.x * -1, 0.0f );
        //}

        if ( bReload ) {
                player.stamina.currentUpdated.disconnect( &tempGUI.onStaminaUpdated );
                player.health.hpUpdated.disconnect( &tempGUI.onHealthUpdated );

                DestroyObject( player );
                DestroyObject( enemy );

                player = createPlayer();
                player.transform.pos.x = 200;
                player.transform.pos.y = 800;
                player.stamina.currentUpdated.connect( &tempGUI.onStaminaUpdated );
                player.health.hpUpdated.connect( &tempGUI.onHealthUpdated );

                charactersNode.addChild( player );

                CTEST test = newObject!CTEST( player, world.mpathfinder );
                enemy = test;
                test.transform.pos.x = 1200;
                test.transform.pos.y = 800;
                test.physics.filterData = SP2DFilterData( 0x0002, 0x0001 );

                charactersNode.addChild( enemy );
                tempGUI.reset();
            bReload = false;
        }
        camera.transform.pos = player.transform.pos;

        SVec2F bounds = world.currentLevel.getSize().tov!float * 64;
        // Left up corner pos
        SVec2F lucpos = camera.transform.pos - camera.size.tov!float / 2;

        if ( bounds.y >= camera.size.y ) {
            if ( lucpos.y < 0 ) {
                camera.transform.pos.y = camera.size.y / 2;
            }
            else if ( lucpos.y + camera.size.y > bounds.y ) {
                camera.transform.pos.y = bounds.y - camera.size.y / 2;
            }
        } else {
            camera.transform.pos.y = bounds.y / 2.0f;
        }

        if ( bounds.x >= camera.size.x ) {
            if ( lucpos.x < 0 ) {
                camera.transform.pos.x = camera.size.x / 2;
            }
            else if ( lucpos.x + camera.size.x > bounds.x ) {
                camera.transform.pos.x = bounds.x - camera.size.x / 2;
            }
        } else {
            camera.transform.pos.x = bounds.x / 2.0f;
        }

        lucpos = camera.transform.pos - camera.size.tov!float / 2;
        postprocess.set( "lightPos", var( player.transform.pos - lucpos ) );

        tempGUI.transform.pos = lucpos + SVec2F( 0, 0 );

        tree.message( ENodeMessageType.PHYSICS_TICK, "", var( delta ) );
    }

    override void psync() {
        tree.message( ENodeMessageType.PHYSICS_SYNC, "", var() );
    }

    override void tick( float delta ) {
        if ( slowmotion >= 0.0f ) {
            slowmotion -= delta;
            delta /= slowmotionStrength;
        }
        
        tree.message( ENodeMessageType.TICK, "", var( delta ) );
    }

    override CR2D_View render( SVec2I resolution, float delta ) {
        import engine.core.memory;
        import engine.thirdparty.derelict.imgui;

        GImGUI.setNextWindowPos( SVec2I( 0, 0 ) );
        if ( GImGUI.begin( "info", null,
            EImGUIWinFlags.NO_TITLE_BAR |
            EImGUIWinFlags.NO_RESIZE |
            EImGUIWinFlags.NO_MOVE |
            EImGUIWinFlags.NO_SAVED_SETTINGS
        ) ) {
            //GImGUI.text( String( "Allocated mem(MB): ", Math.round( (Memory.allocatedMemory / 1024.0f / 1024.0f) * 100 ) / 100 ) );
            //GImGUI.text( String( "Allocations count: ", Memory.allocationsCount ) );
            GImGUI.text( String( "FPS: ", 1.0f / delta ) );

            GImGUI.separator();
            GImGUI.text(
                "Input:\n Esc - exit\n\n Left/Right Arrows - movement\n Space - jump\n Z - attack\n Shift - block\n V - dodge \n R - randomize palyer skin"
            );

            bool bDrawPhysics2DDebug = GPhysics2D.bDebugDraw;
            GImGUI.checkbox( "Physics2D debug", &bDrawPhysics2DDebug );
            GPhysics2D.bDebugDraw = bDrawPhysics2DDebug;

            GImGUI.separator();
            if ( GImGUI.button( "Refresh" ) ) {
                bReload = true;
            }
            
            time += delta;

            if ( bSomeStrangeFunc ) {
                ambient.r = Math.sin( time );
                ambient.g = Math.cos( time );
                ambient.b = Math.sin( time * 2 );
            }

            //SColorRGBA ambient = treeRender.context.ambient;
            //GImGUI.colorPicker4( "Ambient", &ambient );
            //treeRender.context.ambient = ambient;
        }
        GImGUI.end();

        animationEditor.draw();

        treeRender.preRender();
        tree.message( ENodeMessageType.RENDER, "", var( treeRender ) );

        CR2D_View mview = treeRender.render().get( rs!"main", null );
        if ( mview ) {
            if ( resolution.x > 0 && resolution.y > 0 ) {
                mview.resolution = resolution;
            }

            SVec2F pos = mview.position;

            mview = postprocess.render( mview );
            mview.position = pos;
        }

        return mview;
    }

    override void input( CInputAction action ) {
        tree.message( ENodeMessageType.INPUT, "", var( action ) );
    }

private:
    CPlayer createPlayer() {
        CPlayer ret = NewObject!CPlayer();
        ret.physics.filterData = SP2DFilterData( 0x0004, 0x0001 );

        ret.combat.onHit.connect( &onPlayerHit );
        ret.combat.onComboHit.connect( &onPlayerComboHit );
        ret.health.damaged.connect( &onPlayerDamaged );
        ret.health.damagedUnderDamageResist.connect( &onPlayerDamaged );

        return ret;
    }

    void onPlayerHit() {
        camera.shake( 0.2f, 15.0f, 1.0f );
    }

    void onPlayerComboHit() {
        camera.shake( 0.6, 20.0f, 5.0f );
        //slowmotion = 0.8f;
    }

    void onPlayerDamaged() {
        camera.shake( 0.4f, 20.0f, 5.0f );
    }

    void onLevelChanged( CLDTKLevel level ) {
        SVec2I position = level.position / world.world.defaultCellSize;
        SVec2I size = level.size / world.world.defaultCellSize;

        SVec2I vmappos( SVec2I pos, ELDTKDir dir ) {
            SVec2I outPoint;

            switch ( dir ) {
            case ELDTKDir.NORTH:
                outPoint = SVec2I( pos.x + position.x, position.y - 1 );
                break;
            case ELDTKDir.SOUTH:
                outPoint = SVec2I( pos.x + position.x, position.y + size.y + 1 );
                break;
            case ELDTKDir.WEST:
                outPoint = SVec2I( position.x - 1, pos.y + position.y );
                break;
            case ELDTKDir.EAST:
                outPoint = SVec2I( position.x + size.x + 1, pos.y + position.y );
                break;

            default:
                assert( false );
            }

            return outPoint;
        }

        CLDTKLevel getNeighbour( SVec2I pos, ELDTKDir dir ) {
            return world.vmap.getLevelThatContainsPoint( vmappos( pos, dir ).tov!float );
        }

        bool isTransitionPoint( SVec2I pos, ELDTKDir dir ) {
            CLDTKLevel neighbour = getNeighbour( pos, dir );
            int tileId = world.mcollision.get( pos.x, pos.y );

            return neighbour !is null && tileId == -1;
        }

        void addChangeLevelTrigger( SVec2F position, SVec2I size, ELDTKDir dir, String levelName ) {
            CChangeLevelTrigger trigger = newObject!CChangeLevelTrigger( dir, levelName );
            triggers ~= trigger;

            trigger.onGameObjectEnter.connect( &onObjectEnterChangeLevelTrigger );

            trigger.resize( size.x * 32, size.y * 32 );
            trigger.transform.pos = cast( SVec2F )( position * 64 + 32 );

            tree.root.addChild( trigger );
        }

        for ( int i = 0; i < size.x; i++ ) {
            ELDTKDir dir = ELDTKDir.NORTH;
            SVec2I point = SVec2I( i, 0 );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( i, 0 );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( length / 2.0f - 0.5f, -1 ),
                    SVec2I( length, 1 ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.x; i++ ) {
            ELDTKDir dir = ELDTKDir.SOUTH;
            SVec2I point = SVec2I( i, size.y - 1 );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( i, size.y - 1 );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( length / 2.0f - 0.5f, 1 ),
                    SVec2I( length, 1 ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.y; i++ ) {
            ELDTKDir dir = ELDTKDir.WEST;
            SVec2I point = SVec2I( 0, i );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( 0, i );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( -1, length / 2.0f - 0.5f ),
                    SVec2I( 1, length ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }

        for ( int i = 0; i < size.y; i++ ) {
            ELDTKDir dir = ELDTKDir.EAST;
            SVec2I point = SVec2I( size.x - 1, i );

            if ( isTransitionPoint( point, dir ) ) {
                int start = i;
                SVec2I beginPoint = point;
                while ( isTransitionPoint( point, dir ) ) {
                    i++;
                    point = SVec2I( size.x - 1, i );
                }

                int length = i - start;

                addChangeLevelTrigger(
                    beginPoint.tov!float + SVec2F( 1, length / 2.0f - 0.5f ),
                    SVec2I( 1, length ),
                    dir,
                    getNeighbour( beginPoint, dir ).name
                );
            }
        }
    }

    void onObjectEnterChangeLevelTrigger( CChangeLevelTrigger trigger, CGameObject obj, String levelName ) {
        const SWEEP = 75.0f;

        if ( obj is player ) {
            foreach ( tr; triggers ) {
                oldTriggers ~= tr;
            }
            triggers.free();

            CLDTKLevel old = world.currentLevel;

            world.changeLevel( levelName );

            if ( world.currentLevel ) {
                SVec2F npos = (player.transform.pos + old.position.tov!float * 4) - world.currentLevel.position.tov!float * 4;
                switch ( trigger.dir ) {
                case ELDTKDir.NORTH:
                    npos.y -= SWEEP;
                    break;
                case ELDTKDir.SOUTH:
                    npos.y += SWEEP;
                    break;
                case ELDTKDir.WEST:
                    npos.x -= SWEEP;
                    break;
                case ELDTKDir.EAST:
                    npos.x += SWEEP;
                    break;

                default: break;
                }

                player.transform.pos = npos;
            }
        }
    }
}
