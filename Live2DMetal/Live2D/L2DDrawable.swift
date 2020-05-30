//
//  L2DDrawable.swift
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

import Metal
import MetalKit

/// Internal Live2D drawing data for `L2DRenderer`.
internal class L2DDrawable {
    /// Index for buffer reference.
    public var drawableIndex: Int32 = 0
    
    /// Number of vertex.
    public var vertexCount: Int = 0
    
    /// Number of draw index.
    public var indexCount: Int = 0
    
    // Textures.
    /// Which texture will use for drawable.
    public var textureIndex: Int = 0
    /// How may mask will be use.
    public var maskCount: Int = 0
    
    // Constant flags.
    /// Culling mode. `True` if culling enable.
    public var cullingMode: Bool = false
    /// Blend mode.
    public var blendMode: L2DBlendMode = NormalBlending
    
    /// Vertex buffers. Create by `L2DRenderer`.
    public var vertexPositionBuffer: MTLBuffer?
    /// Vertex UV buffers. Create by `L2DRenderer`.
    public var vertexTextureCoordinateBuffer: MTLBuffer?
    /// Draw index buffers. Create by `L2DRenderer`.
    public var vertexIndexBuffer: MTLBuffer?
    
    /// Masks.
    public var masks: [Int32] = []
    /// Mask texture. Create by `L2DRenderer`.
    public var maskTexture: MTLTexture?
    
    /// Opacity.
    public var opacity: Float = 1.0
    /// Opacity buffer. Create by `L2DRenderer`.
    public var opacityBuffer: MTLBuffer?
    
    /// Visibility.
    public var visibility: Bool = true
}
