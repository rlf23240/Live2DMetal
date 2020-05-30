//
//  shader.metal
//  L2DWallpaper
//
//  Created by Ian Wang on 2020/5/18.
//  Copyright © 2020 ian wang. All rights reserved.
//

#include <metal_stdlib>
#include "L2DShaderType.h"

using namespace metal;

vertex VertexOut basic_vertex(constant float4x4 &transform [[buffer(L2DBufferIndexTransform)]],
                                        VertexIn vertex_in [[stage_in]]) {
    
    return VertexOut(transform*float4(vertex_in.position, 0.0, 1.0),
                     float2(vertex_in.uv.x, -vertex_in.uv.y),
                     vertex_in.opacity);
}

fragment float4 basic_fragment(   VertexOut fragment_in [[stage_in]],
                               texture2d<float> texture [[texture(L2DTextureIndexUniform)]]) {
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);
    
    float4 color = texture.sample(textureSampler, fragment_in.uv);
    
    color.w *= fragment_in.opacity;
    color.xyz *= color.w;
    
    return color;
}

