//
//  ShaderTypes.h
//  Reindeer
//
//  Created by Ditta on 12/10/2021.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
// Metal API buffer set calls
typedef enum VertexInputIndex
{
    VertexInputIndexVertices     = 0,
    VertexInputIndexViewportSize = 1,
} VertexInputIndex;


// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match
// Metal API texture set calls
typedef enum TextureIndex
{
    TextureIndexBaseColor = 0,
} TextureIndex;

typedef struct {
    // Positions in pixel space. A value of 100 indicates 100 pixels from the origin/center.
    vector_float2 position;
    
    // 2D texture coordinate
    vector_float2 textureCoordinate;
} Vertex;

#endif /* ShaderTypes_h */
