//
//  L2DModel.h
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "RawArray.h"

/// An ObjC wrapper of Live2D model.
@interface L2DModel: NSObject

typedef enum {
    /// Normal blending mode.
    NormalBlending = 0,
    
    /// Additive blending mode.
    AdditiveBlending = 1,
    
    /// Multiplicative blending mode.
    MultiplicativeBlending = 2,
    
} L2DBlendMode;

- (instancetype)initWithJsonPath: (NSString *)jsonPath;

// Model manipluations.
- (void)setModelParameterNamed: (NSString *)name withValue: (float)value;

// Model property inspections.
- (CGSize)modelSize;

// Drawables.
- (int) drawableCount;
- (RawIntArray*) renderOrders;
- (bool) isRenderOrderDidChangedForDrawable: (int)index;

// Vertices.
- (RawFloatArray*) vertexPositionsForDrawable: (int)index;
- (RawUShortArray*) vertexIndicesForDrawable: (int)index;
- (bool) isVertexPositionDidChangedForDrawable: (int)index;

// Textures.
- (NSArray*) textureURLs;
- (int) textureIndexForDrawable: (int)index;
- (RawFloatArray*) vertexTextureCoordinateForDrawable: (int)index;

// Masks.
- (RawIntArray*) masksForDrawable: (int)index;

// Draw modes.
- (bool) cullingModeForDrawable: (int)index;
- (L2DBlendMode) blendingModeForDrawable: (int)index;

// Opacity.
- (float) opacityForDrawable: (int)index;
- (bool) isOpacityDidChangedForDrawable: (int)index;

// Visibility.
- (bool) visibilityForDrawable: (int)index;
- (bool) isVisibilityDidChangedForDrawable: (int)index;

// TODO: Invert mask.

// TODO: Live2D parts.

@end

@interface L2DModel (UpdateAndPhysics)

- (void) update;

- (void) updatePhysics: (NSTimeInterval)dt;

@end
