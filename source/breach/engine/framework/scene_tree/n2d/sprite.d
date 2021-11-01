module engine.framework.scene_tree.n2d.sprite;

public:
import engine.modules.render_device.texture;

import engine.framework.render.r2d;
import engine.framework.scene_tree.n2d.node_2d;

class CSprite : CNode2D {
    mixin( TRegisterClass!CSprite );
public:
    CR2D_Sprite lsprite;
    alias lsprite this;

    CTexture ltexture;

public:
    this() {
        super();

        lsprite = newObject!CR2D_Sprite();
    }

    ~this() {
        destroyObject( lsprite );
    }

protected:
    override void render( CSceneTreeRender render ) {
        render.registerPrimitive( lsprite );

        STransform2D transform = worldTransform();

        SVec2F halfTextureSize = SVec2F(
            ( ltexture.width * transform.size.x ) / 2,
            ( ltexture.height * transform.size.y ) / 2,
        );

        lsprite.position = transform.pos - halfTextureSize;
        lsprite.scale = transform.size;
        lsprite.angle = transform.angle;
    }

public:
    @property {
        void texture( CTexture itexture ) {
            ltexture = itexture;

            lsprite.texture = ltexture;
        }

        CTexture texture() {
            return ltexture;
        }
    }
}
