//
//  shader.h
//  L2DWallpaper
//
//  Created by Ian Wang on 2020/5/22.
//  Copyright © 2020 ian wang. All rights reserved.
//

#ifndef L2DShaderType_h
#define L2DShaderType_h

#include <metal_stdlib>
#include <simd/simd.h>

#include "L2DBufferIndex.h"

using namespace metal;

struct VertexIn {
    float2 position [[attribute(L2DAttributeIndexPosition)]];
    float2 uv       [[attribute(L2DAttributeIndexUV)]];
    
    float opacity   [[attribute(L2DAttributeIndexOpacity)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float opacity;
    
    VertexOut(float4 position, float2 uv, float opacity): position(position), uv(uv), opacity(opacity) {}
};

#endif /* L2DShaderType_h */
