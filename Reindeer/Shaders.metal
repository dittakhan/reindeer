//
//  Shaders.metal
//  Reindeer
//
//  Created by Ditta on 12/10/2021.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

//#include "ShaderTypes.h"

struct RasterizerData
{
    // The [[position]] attribute qualifier of this member indicates this value is
    // the clip space position of the vertex when this structure is returned from
    // the vertex shader
    float4 position [[position]];

    // Since this member does not have a special attribute qualifier, the rasterizer
    // will interpolate its value with values of other vertices making up the triangle
    // and pass that interpolated value to the fragment shader for each fragment in
    // that triangle.
    float2 textureCoordinate [[user(texturecoord)]];

};

// Vertex Function
vertex RasterizerData vertexShader(constant float4 *position [[ buffer(0)]],
                                   constant packed_float2 *textureCoordinates [[ buffer(1) ]],
                                   constant float4x4 *vertices [[ buffer(2) ]],
                                   uint vid [[ vertex_id ]])
{
    RasterizerData out;

    out.position = position[vid];
    out.textureCoordinate = textureCoordinates[vid];

    return out;
}

// Fragment function
fragment half4 samplingShader(RasterizerData in [[stage_in]],
                              texture2d<half> colorTexture [[ texture(0) ]])
{
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);

    // return the color of the texture
    return colorSample;
}

