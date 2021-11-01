module game.states.test.new_render;

import engine.core;
import engine.framework;

import game.core;

class CTestState_NewRender : CGameState {
    mixin( TRegisterClass!CGameState );
protected:
    CR2D_View _view;
    CR2D_Context _context;
    CR2D_SceneProxy _proxy;
    CR2D_Sprite _sprite;
    CR2D_Sprite _sprite2;
    CR2D_Light _light;
    CR2D_Light _light2;
    CR2D_Sprite _sl;
    //CRenderer2D renderer2D;
    CRenderer2D _renderer2D;

    CSpinePlayer spine;

    CR2D_View lview;

public:
    this() {
        super();

        {
            lview = newObject!CR2D_View( 1920, 1080 );
            _view = newObject!CR2D_View( 1920, 1080 );
            _context = newObject!CR2D_Context();
            _proxy = newObject!CR2D_SceneProxy();
            _sprite = newObject!CR2D_Sprite();
            _sprite2 = newObject!CR2D_Sprite();
            _light = newObject!CR2D_Light();
            _light2 = newObject!CR2D_Light();
            _sl = newObject!CR2D_Sprite();
            //renderer2D = newObject!CRenderer2D();
            _renderer2D = newObject!CRenderer2D();

            _sprite.texture = GResourceManager.load!CTexture( "res/brickwall.png" );
            //_sprite.normal = GResourceManager.load!CTexture( "res/brickwall_normal.png" );
            _sprite.normal = GResourceManager.load!CTexture( "res/flat_normal.png" );

            _sprite2.texture = GResourceManager.load!CTexture( "res/brickwall.png" );
            _sprite2.normal = GResourceManager.load!CTexture( "res/brickwall_normal.png" );
            _sprite2.position = SVec2F( 1024, 0 );

            _light.texture = GResourceManager.load!CTexture( "res/Light512.png" );
            _light2.texture = GResourceManager.load!CTexture( "res/framework/render_2d/light_system/pointLightTexture.png" );
            _light2.position = SVec2F( 200, 300 ) - SVec2F( 1024 / 2.0f );

            _sl.selfIllumination = GResourceManager.load!CTexture( "res/Light_Pointer.png" );
            _sl.position = SVec2F( 200, 200 );
            _sl.scale = SVec2F( 10f, 10f );
            _sl.modulate = EColors.GREEN;

            _proxy ~= _sprite;
            _proxy ~= _sprite2;
            _proxy ~= _light;
            _proxy ~= _light2;
            _proxy ~= _sl;

            //renderer2D.lightMaterial.shader = rdMakePipeline(
                //rs!"res/framework/render_2d/blend_vertex.shader",
                //rs!"res/framework/render_2d/blend_pixel.shader"
            //);

            //renderer2D._lightMaterial.shader = rdMakePipeline(
                //rs!"res/framework/render_2d/light_blend_vertex.shader",
                //rs!"res/framework/render_2d/light_blend_pixel.shader"
            //);

            //renderer2D.blur.shader = rdMakePipeline(
                //rs!"res/framework/render_2d/bloom_vertex.shader",
                //rs!"res/framework/render_2d/bloom_pixel.shader"
            //);

            //renderer2D.bloom.shader = rdMakePipeline(
                //rs!"res/framework/render_2d/_blur_vertex.shader",
                //rs!"res/framework/render_2d/_blur_pixel.shader"
            //);
        }
    }

override:
    void ptick( float delta ) {}
    void psync() {}
    void tick( float delta ) {}
    void input( CInputAction action ) {}

    CR2D_View render( SVec2I resolution, float delta ) {
        lview.resolution = resolution;
        _view.resolution = resolution;

        GImGUI.setNextWindowPos( SVec2I( 0, 0 ), EImGUICond.FIRST_START );
        if ( GImGUI.begin( "info", null,
            EImGUIWinFlags.NO_TITLE_BAR |
            EImGUIWinFlags.NO_RESIZE |
            EImGUIWinFlags.NO_MOVE |
            EImGUIWinFlags.NO_SAVED_SETTINGS
        ) ) {
            GImGUI.text( String( "Allocated mem(MB): ", Math.round( (Memory.allocatedMemory / 1024.0f / 1024.0f) * 100 ) / 100 ) );
            GImGUI.text( String( "Allocations count: ", Memory.allocationsCount ) );
        }
        GImGUI.end();

        SVec2F mousepos = GInput.mouse.position;

        SVec3F lightPos = SVec3F( mousepos.x, mousepos.y, 0.075f );

        Array!SVec3F lightPoses;
        lightPoses ~= lightPos;
        lightPoses ~= SVec3F( 200.0f, 300.0f, 0.075f );
        //lightPoses ~= SVec3F( 500.0f, 300.0f, 0.075f );
        //lightPoses ~= SVec3F( 350.0f, 500.0f, 0.075f );

        Array!SColorRGBA lightColors;
        lightColors ~= EColors.WHITE;
        lightColors ~= SColorRGBA( 0.2f, 1.0f, 0.6f, 0.5f );
        //lightColors ~= SColorRGBA( 0.2f, 0.0f, 1.0f, 0.5f );
        //lightColors ~= SColorRGBA( 1.0f, 0.2f, 0.0f, 0.5f );

        _light.position = mousepos - SVec2F( _light.texture.width / 2, 0 );
        //_sl.position = mousepos - SVec2F( _sl.texture.width * 2.2f / 2, _sl.texture.height * 0.2f );

        foreach ( i, elem; lightPoses ) {
            String nname = String( "lPoses[", i, "]" );
            String nnameColors = String( "lColors[", i, "]" );

            _renderer2D.matLight.params[nname] = var( lightPoses[i] );
            _renderer2D.matLight.params[nnameColors] = var( lightColors[i] );
        }

        _renderer2D.matLight.params["lNum"] = var( cast( int )lightPoses.length );
        _renderer2D.matLight.params["resolution"] = var( resolution );

        _renderer2D.render( _proxy, _context, _view );

        lview.framebuffer = _view.framebuffer;

        return lview;
    }
}
