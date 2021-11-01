module engine.modules.render.util;

import engine.core.object;
import engine.core.fs;
import engine.core.log;

import engine.modules.render_device.render_device;

ID rdMakePipeline( String vertexFile, String pixelFile ) {
    String vertexCode;
    String pixelCode;
    ID vertexShader;
    ID pixelShader;
    ID pipeline;

    if ( !GFileSystem.isFileExists( vertexFile ) ) return ID_INVALID;
    if ( !GFileSystem.isFileExists( pixelFile ) ) return ID_INVALID;

    vertexCode = GFileSystem.fileReadAsString( vertexFile );
    pixelCode = GFileSystem.fileReadAsString( pixelFile );

    vertexShader = RD.shader_create( ERDShaderType.VERTEX, vertexCode );
    pixelShader = RD.shader_create( ERDShaderType.PIXEL, pixelCode );

    pipeline = RD.pipeline_create( vertexShader, pixelShader );

    RD.destroy( vertexShader );
    RD.destroy( pixelShader );

    return pipeline;
}

VertexDescriptor rdMakeDescriptor( T )()
if ( is( T == struct ) ) {
    VertexDescriptor descriptor;

    foreach ( i, ref field; T().tupleof ) {
        ERDPrimitiveType type;
        //descriptor ~= SRDVertexElement( i, type, 0, sizeof(  ) );
    }
}
