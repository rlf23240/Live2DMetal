//
//  L2DShaderType.h
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

#ifndef L2DBufferIndex_h
#define L2DBufferIndex_h

/// Shader buffer index.
typedef enum L2DBufferIndex {
    L2DBufferIndexTransform    = 0,
    L2DBufferIndexPosition     = 1,
    L2DBufferIndexUV           = 2,
    L2DBufferIndexOpacity      = 3
} L2DBufferIndex;

/// Shader attribute index.
typedef enum L2DAttributeIndex {
    L2DAttributeIndexPosition   = 0,
    L2DAttributeIndexUV         = 1,
    L2DAttributeIndexOpacity    = 2
} L2DAttributeIndex;

/// Shader texture index.
typedef enum L2DTextureIndex {
    L2DTextureIndexUniform  = 0,
    L2DTextureIndexMask     = 1
} L2DTextureIndex;

#endif /* L2DBufferIndex_h */
