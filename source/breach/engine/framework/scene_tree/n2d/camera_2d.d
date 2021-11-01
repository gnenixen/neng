module engine.framework.scene_tree.n2d.camera_2d;

import engine.framework.scene_tree.base.render;
import engine.framework.scene_tree.n2d.node_2d;

enum ECamera2DCenterMode {
    UP_LEFT_CORNER,
    CENTER,
}

class CCamera2D : CNode2D {
    mixin( TRegisterClass!CCamera2D );
public:
    ECamera2DCenterMode mode = ECamera2DCenterMode.CENTER;

private:
    CSceneTreeRenderCamera lcamera;

public:
    this() {
        lcamera = newObject!CSceneTreeRenderCamera( 1280, 720 );
    }

    ~this() {
        destroyObject( lcamera );
    }

protected:
    override void render( CSceneTreeRender renderer ) {
        renderer.registerCamera( lcamera );

        switch ( mode ) {
        case ECamera2DCenterMode.UP_LEFT_CORNER:
            lcamera.view.position = worldTransform.pos;
            break;
        
        case ECamera2DCenterMode.CENTER:
            lcamera.view.position = worldTransform.pos - (lcamera.view.resolution.tov!float / 2.0f);
            break;
        
        default:
            assert( false );
        }
    }

public:
    @property {
        void size( SVec2I nsize ) { lcamera.view.resolution = nsize; }
        SVec2I size() { return lcamera.view.resolution; }
    }
}
