module engine.framework.imgui.render;

import engine.thirdparty.derelict.imgui;

import engine.core.math;
import engine.core.object;
import engine.core.gengine;
import engine.core.fs;

import engine.framework.render.r2d;
import engine.framework.imgui.imgui;

private struct SImDrawVect_Patched {
    float x, y;
    float uvx, uvy;
    float r, g, b, a;
}

class CImGUIRender_Primitive : CR2D_Primitive {
    mixin( TRegisterClass!CImGUIRender_Primitive );
protected:
    ID mainShader;
    ID imageShader;

public:
    this() {
        super( ERDBufferUpdate.STREAM );

        setup( VertexDescriptor(
            SRDVertexElement( 0, ERDPrimitiveType.FLOAT, 2, SImDrawVect_Patched.sizeof, 0 ),
            SRDVertexElement( 1, ERDPrimitiveType.FLOAT, 2, SImDrawVect_Patched.sizeof, 2 * float.sizeof ),
            SRDVertexElement( 2, ERDPrimitiveType.FLOAT, 4, SImDrawVect_Patched.sizeof, 4 * float.sizeof ),
        ));

        mainShader = rdMakePipeline(
            rs!"res/engine/ogl_render/imgui/vertex.glsl",
            rs!"res/engine/ogl_render/imgui/fragment.glsl"
        );

        imageShader = rdMakePipeline(
            rs!"res/engine/ogl_render/imgui/vertex_image.glsl",
            rs!"res/engine/ogl_render/imgui/fragment_image.glsl"
        );

        bRenderInCameraSpace = true;
    }

    void draw( SRect scis, int idx, ImDrawList* cmdList ) {
        reset();

        auto countVertices = cmdList.VtxBuffer.Size;
        auto countIndices = cmdList.IdxBuffer.Size;
    
        ImDrawVert* vertexPtr = cmdList.VtxBuffer.Data;
        vertices.reserve( countVertices * 8 );
        foreach ( elem; vertexPtr[0..countVertices] ) {
            ImVec4 color = igColorConvertU32ToFloat4( elem.col );

            vertices ~= elem.pos.x;
            vertices ~= elem.pos.y;
            vertices ~= elem.uv.x;
            vertices ~= elem.uv.y;
            vertices ~= color.x;
            vertices ~= color.y;
            vertices ~= color.z;
            vertices ~= color.w;
        }
    
        ImDrawIdx* indexPtr = cmdList.IdxBuffer.Data;
        indices.reserve( countVertices );
        foreach ( elem; indexPtr[0..countIndices] ) {
            indices ~= elem;
        }

        auto cmdCnt = cmdList.CmdBuffer.Size;
        //foreach ( cmd; 0..cmdCnt ) {
            auto pcmd = cmdList.CmdBuffer[idx];

            if ( pcmd.UserCallback ) {
                pcmd.UserCallback( cmdList, &pcmd );
            } else {
                if ( pcmd.TextureId !is null ) {
                    texture = null;
                    rtTexture = cast( ID )pcmd.TextureId;
                    material.shader = imageShader;
                } else {
                    material.shader = mainShader;
                }

                scissors = scis;
            }
        //}
        
        markDirty();
    }

    /*void draw() {
        reset();

        ImDrawData* data = GImGUI.render();
        if ( !data ) return;
    
        auto io = igGetIO();
        int fbWidth = cast( int )( io.DisplaySize.x * io.DisplayFramebufferScale.x );
        int fbHeight = cast( int )( io.DisplaySize.y * io.DisplayFramebufferScale.y );
    
        if ( fbWidth == 0 || fbHeight == 0 ) return;
    
        data.ScaleClipRects( io.DisplayFramebufferScale );
    
        foreach ( i; 0..data.CmdListsCount ) {
            ImDrawList* cmdList = data.CmdLists[i];
            ImDrawIdx* idxBufferOffset;
    
            auto countVertices = cmdList.VtxBuffer.Size;
            auto countIndices = cmdList.IdxBuffer.Size;
            uint beginIndex = cast( uint )vertices.length / 8;
    
            ImDrawVert* vertexPtr = cmdList.VtxBuffer.Data;
            vertices.reserve( vertices.length + countVertices * 8 );
            foreach ( elem; vertexPtr[0..countVertices] ) {
                ImVec4 color = igColorConvertU32ToFloat4( elem.col );

                vertices ~= elem.pos.x;
                vertices ~= elem.pos.y;
                vertices ~= elem.uv.x;
                vertices ~= elem.uv.y;
                vertices ~= color.x;
                vertices ~= color.y;
                vertices ~= color.z;
                vertices ~= color.w;
            }
    
            ImDrawIdx* indexPtr = cmdList.IdxBuffer.Data;
            indices.reserve( indices.length + countVertices );
            foreach ( elem; indexPtr[0..countIndices] ) {
                indices ~= beginIndex + elem;
            }

            auto cmdCnt = cmdList.CmdBuffer.Size;
            foreach ( cmd; 0..cmdCnt ) {
                auto pcmd = cmdList.CmdBuffer[cmd];
                if ( pcmd.UserCallback ) {
                    pcmd.UserCallback( cmdList, &pcmd );
                }
            }
        }
    }*/
}

class CImGUIRender : CObject {
    mixin( TRegisterClass!CImGUIRender );
public:
    CR2D_SceneProxy proxy;
    CR2D_Context context;
    CGUIRenderer2D pipeline;

    //CImGUIRender_Primitive primitive;
    Array!CImGUIRender_Primitive primitives;
    int amount = 0;

    CTexture texture;

public:
    this() {
        proxy = NewObject!CR2D_SceneProxy();
        context = NewObject!CR2D_Context();
        pipeline = NewObject!CGUIRenderer2D();
        //primitive = newObject!CImGUIRender_Primitive();

        //proxy ~= primitive;

        ImGuiIO* io = igGetIO();
        io.BackendRendererName = "rn_neng";
        {
            ubyte* pixels;
            int width;
            int height;
            ImFontAtlas_GetTexDataAsAlpha8( io.Fonts, &pixels, &width, &height, null );
            
            Array!ubyte data;
            data.reserve( width * height );
            foreach ( elem; pixels[0..width*height] ) {
                data ~= elem;
            }

            texture = NewObject!CTexture();
            texture.rdId = RD.texture_create( ERDTextureType.TT_2D, SRDTextureData( width, height, 0, data, ERDTextureDataFormat.R ) );
            texture.width = width;
            texture.height = height;
            texture.loadPhase = EResourceLoadPhase.SUCCESS;

            ImFontAtlas_SetTexID( io.Fonts, null );
        }
    }

    void render( CR2D_View view ) {
        amount = 0;

        proxy.clear();

        ImDrawData* data = GImGUI.render();
        if ( !data ) return;
    
        auto io = igGetIO();
        int fbWidth = cast( int )( io.DisplaySize.x * io.DisplayFramebufferScale.x );
        int fbHeight = cast( int )( io.DisplaySize.y * io.DisplayFramebufferScale.y );
    
        if ( fbWidth == 0 || fbHeight == 0 ) return;
    
        data.ScaleClipRects( io.DisplayFramebufferScale );

        ImVec2 clipOff = data.DisplayPos;
        ImVec2 clipScale = data.FramebufferScale;

        foreach ( i; 0..data.CmdListsCount ) {
            ImDrawList* cmdList = data.CmdLists[i];
            auto cmdCnt = cmdList.CmdBuffer.Size;
            ImDrawIdx* idxBufferOffset = null;

            foreach ( j; 0..cmdCnt ) {
                auto pcmd = cmdList.CmdBuffer[j];

                SVec2I clipMin = SVec2I( (pcmd.ClipRect.x - clipOff.x) * clipScale.x, (pcmd.ClipRect.y - clipOff.y) * clipScale.y );
                SVec2I clipMax = SVec2I( (pcmd.ClipRect.z - clipOff.x) * clipScale.x, (pcmd.ClipRect.w - clipOff.y) * clipScale.y );

                if ( clipMax.x < clipMin.x || clipMax.y < clipMin.y ) continue;

                SRect scissors = SRect(
                    SVec2F( clipMin.x, fbHeight - clipMax.y ),
                    clipMax.x - clipMin.x,
                    clipMax.y - clipMin.y
                );

                if( scissors.pos != SVec2F( 0.0f ) ) {
                    scissors.pos.y = clipMin.y;
                }

                CImGUIRender_Primitive primitive = getPrimitive();
                primitive.texture = texture;
                primitive.draw(
                    scissors,
                    j, cmdList
                );

                primitive.raw.offset = pcmd.IdxOffset;
                primitive.raw.count = pcmd.ElemCount;

                proxy ~= primitive;

                idxBufferOffset += pcmd.ElemCount;
            }
        }

        pipeline.render( proxy, context, view );
    }

protected:
    CImGUIRender_Primitive getPrimitive() {
        if ( amount + 1 >= primitives.length ) {
            CImGUIRender_Primitive prim = NewObject!CImGUIRender_Primitive();
            primitives ~= prim;
            amount++;
            return prim;
        }

        amount++;
        return primitives[amount];
    }
}
