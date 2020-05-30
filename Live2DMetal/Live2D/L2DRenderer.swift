//
//  L2DRenderer.swift
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

public class L2DRenderer {
    public weak var delegate: L2DRendererDelegate?
    
    public var model: L2DModel? {
        didSet {
            if let view = self.view, model != nil {
                self.createBuffers(for: view)
                self.createTextures(for: view)
            }
        }
    }
    
    /// Model rendering origin, in normalized device coordinate (NDC).
    ///
    /// Default is `(0,0)`.
    ///
    /// Set this property will reset `transform` matrix.
    public var origin: CGPoint = .zero
    
    /// Model rendering scale.
    ///
    /// Default is `1.0`.
    ///
    /// Set this property will reset `transform` matrix.
    public var scale: Float = 1.0
    
    /// Transform matrix of model.
    ///
    /// Note that set `origin` or `scale` will reset transform matrix.
    public var transform: float4x4 = matrix_identity_float4x4 {
        didSet {
            if let buffer = self.transformBuffer {
                buffer.contents().copyMemory(
                    from: &transform,
                    byteCount: MemoryLayout<float4x4>.size
                )
            }
        }
    }
    
    private weak var view: MTKView?
    
    // Render pipelines.
    private var pipelineStateBlendingAdditive: MTLRenderPipelineState!
    private var pipelineStateBlendingMultiplicative: MTLRenderPipelineState!
    private var pipelineStateBlendingNormal: MTLRenderPipelineState!
    private var pipelineStateMasking: MTLRenderPipelineState!
    
    // Live2D drawable parts.
    private var drawables: [L2DDrawable] = []
    private var drawableSorted: [L2DDrawable] = []
    
    // Buffers.
    private var transformBuffer: MTLBuffer!
    
    // Textures.
    private var textures: [MTLTexture?] = []
}

extension L2DRenderer: MetalRenderer {
    public func start(for view: MTKView) {
        self.view = view
        
        self.createPipelineStates(for: view)
        
        if self.model != nil {
            self.createBuffers(for: view)
            self.createTextures(for: view)
        }
    }
    
    public func drawableSizeWillChange(for view: MTKView, size: CGSize) {
        guard let device = view.device else {
            return
        }
        
        /// Reset mask texture.
        for drawable in self.drawables {
            if drawable.maskCount > 0 {
                let maskTextureDesc = MTLTextureDescriptor()
                maskTextureDesc.pixelFormat = .bgra8Unorm
                maskTextureDesc.storageMode = .private
                maskTextureDesc.usage = [.renderTarget, .shaderRead]
                maskTextureDesc.width = Int(size.width)
                maskTextureDesc.height = Int(size.height)
                
                drawable.maskTexture = device.makeTexture(descriptor: maskTextureDesc)
            }
        }
    }
    
    public func update(dt: TimeInterval) {
        self.delegate?.rendererUpdate(self, dt: dt)
        
        self.model?.updatePhysics(dt)
        self.model?.update()
        
        self.updateDrawables()
    }
    
    public func render(
        dt: TimeInterval,
        viewport: MTLViewport,
        commandBuffer: MTLCommandBuffer,
        passDescriptor: MTLRenderPassDescriptor
    ) {
        self.renderMasks(
            viewport: viewport,
            commandBuffer: commandBuffer
        )
        
        self.renderDrawables(
            viewport: viewport,
            commandBuffer: commandBuffer,
            passDescriptor: passDescriptor
        )
    }
}

/// Transform matrix modifications.
extension L2DRenderer {
    /// Set scale of model.
    ///
    /// This function will reset transform matrix.
    public func setScale(_ scale: CGFloat) {
        self.scale = Float(scale)
        
        let scaleMatrix = float4x4(diagonal: SIMD4<Float>(self.scale, self.scale, 1.0, 1.0))
        let translationMatrix = float4x4(rows: [
            SIMD4<Float>(1.0, 0.0, 0.0, Float(origin.x)),
            SIMD4<Float>(0.0, 1.0, 0.0, Float(origin.y)),
            SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        ])
        
        self.transform = translationMatrix * scaleMatrix
    }
    
    /// Set position of model.
    ///
    /// This function will reset transform matrix.
    public func setOrigin(_ origin: CGPoint) {
        //self.transform *= float4x4(diagonal: SIMD4<float>(origin.x, origin.y, 0.0, 1.0))
        //float4x4(translationBy: origin)
        self.origin = origin
        
        let scaleMatrix = float4x4(diagonal: SIMD4<Float>(self.scale, self.scale, 1.0, 1.0))
        let translationMatrix = float4x4(rows: [
            SIMD4<Float>(1.0, 0.0, 0.0, Float(origin.x)),
            SIMD4<Float>(0.0, 1.0, 0.0, Float(origin.y)),
            SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        ])
        
        self.transform = translationMatrix * scaleMatrix
    }
}

extension L2DRenderer {
    private func createPipelineStates(for view: MTKView) {
        guard let device = view.device else {
            return
        }
        
        // Library for shaders.
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle(for: L2DRenderer.self)) else {
            return
        }

        // Pipeline.
        let pipelineDesc = MTLRenderPipelineDescriptor()
        
        // MARK: Normal Blending.
        
        // Config shaders.
        let vertexShader = library.makeFunction(name: "basic_vertex")
        let fragmentShader = library.makeFunction(name: "basic_fragment")
        pipelineDesc.vertexFunction = vertexShader
        pipelineDesc.fragmentFunction = fragmentShader
        
        // Vertex descriptor.
        let vertexDesc = MTLVertexDescriptor()

        // Vertex attributes.
        vertexDesc.attributes[L2DAttributeIndex.position].bufferIndex = L2DBufferIndex.position
        vertexDesc.attributes[L2DAttributeIndex.position].format = .float2
        vertexDesc.attributes[L2DAttributeIndex.position].offset = 0

        vertexDesc.attributes[L2DAttributeIndex.uv].bufferIndex = L2DBufferIndex.uv
        vertexDesc.attributes[L2DAttributeIndex.uv].format = .float2
        vertexDesc.attributes[L2DAttributeIndex.uv].offset = 0

        vertexDesc.attributes[L2DAttributeIndex.opacity].bufferIndex = L2DBufferIndex.opacity
        vertexDesc.attributes[L2DAttributeIndex.opacity].format = .float
        vertexDesc.attributes[L2DAttributeIndex.opacity].offset = 0
        
        // Buffer layouts.
        vertexDesc.layouts[L2DBufferIndex.position].stride = MemoryLayout<Float>.stride*2
        
        vertexDesc.layouts[L2DBufferIndex.uv].stride = MemoryLayout<Float>.stride*2
        
        vertexDesc.layouts[L2DBufferIndex.opacity].stride = MemoryLayout<Float>.stride
        vertexDesc.layouts[L2DBufferIndex.opacity].stepFunction = .constant
        vertexDesc.layouts[L2DBufferIndex.opacity].stepRate = 0
        
        pipelineDesc.vertexDescriptor = vertexDesc
        
        // Color attachments.
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Blending.
        pipelineDesc.colorAttachments[0].isBlendingEnabled = true
        
        pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        self.pipelineStateBlendingNormal = try? device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        // MARK: Additive Blending.
        pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .one
        
        pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .one
        
        self.pipelineStateBlendingAdditive = try? device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        // MARK: Multiplicative Blending.
        pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .destinationColor
        pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .zero
        pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .one

        self.pipelineStateBlendingMultiplicative = try? device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        // MARK: Masking.
        let maskVertexShader = library.makeFunction(name: "basic_vertex")
        let maskFragmentShader = library.makeFunction(name: "mask_fragment")
        pipelineDesc.vertexFunction = maskVertexShader
        pipelineDesc.fragmentFunction = maskFragmentShader
        
        pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
        pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        self.pipelineStateMasking = try? device.makeRenderPipelineState(descriptor: pipelineDesc)
    }
    
    private func createBuffers(for view: MTKView) {
        guard let device = view.device else {
            return
        }
        
        guard let model = self.model else {
            return
        }
        
        // Gloabal geometry.
        self.transformBuffer = device.makeBuffer(
            bytes: &(self.transform),
            length: MemoryLayout<float4x4>.size,
            options: []
        )
        
        let drawableCount = model.drawableCount()
        for i in 0..<drawableCount {
            let drawable = L2DDrawable()
            
            drawable.drawableIndex = i
            
            if let vertexPositions = model.vertexPositions(forDrawable: i) {
                drawable.vertexCount = Int(vertexPositions.count)
                
                if drawable.vertexCount > 0 {
                    drawable.vertexPositionBuffer = device.makeBuffer(
                        bytes: vertexPositions.floats,
                        length: 2*Int(vertexPositions.count)*MemoryLayout<Float>.size,
                        options: []
                    )
                }
            }
            
            if let vertexTextureCoords = model.vertexTextureCoordinate(forDrawable: i) {
                if drawable.vertexCount > 0 {
                    drawable.vertexTextureCoordinateBuffer = device.makeBuffer(
                        bytes: vertexTextureCoords.floats,
                        length: 2*Int(vertexTextureCoords.count)*MemoryLayout<Float>.size,
                        options: []
                    )
                }
            }
            
            if let vertexIndices = model.vertexIndices(forDrawable: i) {
                drawable.indexCount = Int(vertexIndices.count)
                
                if drawable.indexCount > 0 {
                    drawable.vertexIndexBuffer = device.makeBuffer(
                        bytes: vertexIndices.ushorts,
                        length: Int(vertexIndices.count)*MemoryLayout<ushort>.size,
                        options: []
                    )
                }
            }
            
            // Textures.
            drawable.textureIndex = Int(model.textureIndex(forDrawable: i))
            
            // Mask.
            if let masks = model.masks(forDrawable: i) {
                drawable.maskCount = Int(masks.count)
                drawable.masks = masks.intArray()
            }
            
            // Render mode.
            drawable.blendMode = model.blendingMode(forDrawable: i)
            drawable.cullingMode = model.cullingMode(forDrawable: i)
            
            // Opacity.
            drawable.opacity = model.opacity(forDrawable: i)
            drawable.opacityBuffer = device.makeBuffer(
                bytes: [drawable.opacity],
                length: MemoryLayout<Float>.size,
                options: []
            )
            
            drawable.visibility = model.visibility(forDrawable: i)
            
            self.drawables.append(drawable)
        }
        
        // Sort drawables.
        let renderOrders = model.renderOrders().intArray()
        self.drawableSorted = self.drawables.sorted(by: {
            renderOrders[Int($0.drawableIndex)] < renderOrders[Int($1.drawableIndex)]
        })
    }
    
    private func createTextures(for view: MTKView) {
        guard let device = view.device else {
            return
        }
        
        guard let model = self.model else {
            return
        }
        
        let size = view.drawableSize
        
        if let textureURLs = model.textureURLs() as? [URL] {
            let textureLoader = MTKTextureLoader(device: device)
            for url in textureURLs {
                
                let texture = try? textureLoader.newTexture(
                    URL: url,
                    options: [
                        .textureStorageMode: MTLStorageMode.private.rawValue,
                        .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                        .SRGB : false
                    ]
                )
                
                self.textures.append(texture)
            }
        }
        
        for drawable in self.drawables {
            if drawable.maskCount > 0 {
                let maskTextureDesc = MTLTextureDescriptor()
                maskTextureDesc.pixelFormat = .bgra8Unorm
                maskTextureDesc.storageMode = .private
                maskTextureDesc.usage = [.renderTarget, .shaderRead]
                maskTextureDesc.width = Int(size.width)
                maskTextureDesc.height = Int(size.height)
                
                drawable.maskTexture = device.makeTexture(descriptor: maskTextureDesc)
            }
        }
    }
    
    /// Update drawables with dynamics flag.
    private func updateDrawables() {
        guard let model = self.model else {
            return
        }
        
        var needSorting = false
        
        for drawable in self.drawables {
            let index = drawable.drawableIndex
            
            if model.isOpacityDidChanged(forDrawable: index) {
                drawable.opacity = model.opacity(forDrawable: index)
                drawable.opacityBuffer?.contents().copyMemory(
                    from: [drawable.opacity],
                    byteCount: MemoryLayout<Float>.stride
                )
            }
            
            if model.isVisibilityDidChanged(forDrawable: index) {
                drawable.visibility = model.visibility(forDrawable: index)
            }
            
            if model.isRenderOrderDidChanged(forDrawable: index) {
                needSorting = true
            }
            
            if model.isVertexPositionDidChanged(forDrawable: index) {
                if let vertexPositions = model.vertexPositions(forDrawable: index) {
                    drawable.vertexPositionBuffer?.contents().copyMemory(
                        from: vertexPositions.floats,
                        byteCount: 2*drawable.vertexCount*MemoryLayout<Float>.stride
                    )
                }
            }
        }
        
        if needSorting {
            let renderOrders = model.renderOrders().intArray()
            self.drawableSorted = self.drawables.sorted(by: {
                renderOrders[Int($0.drawableIndex)] < renderOrders[Int($1.drawableIndex)]
            })
        }
    }
}

extension L2DRenderer {
    private func renderMasks(
        viewport: MTLViewport,
        commandBuffer: MTLCommandBuffer
    ) {
        let renderPassDesc = MTLRenderPassDescriptor()
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].storeAction = .store
        renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 0.0,
            blue: 0.0,
            alpha: 0.0
        )
        
        for drawable in self.drawables {
            if drawable.maskCount > 0 {
                renderPassDesc.colorAttachments[0].texture = drawable.maskTexture
                
                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
                    return
                }
                
                renderEncoder.setRenderPipelineState(self.pipelineStateBlendingNormal)
                renderEncoder.setViewport(viewport)

                // Draw masks.
                for maskIndex in drawable.masks {
                    let mask = self.drawables[Int(maskIndex)]
                    
                    // Bind vertex buffers.
                    renderEncoder.setVertexBuffer(
                        self.transformBuffer,
                        offset: 0,
                        index: L2DBufferIndex.transform
                    )
                    
                    renderEncoder.setVertexBuffer(
                        mask.vertexPositionBuffer,
                        offset: 0,
                        index: L2DBufferIndex.position
                    )
                    
                    renderEncoder.setVertexBuffer(
                        mask.vertexTextureCoordinateBuffer,
                        offset: 0,
                        index: L2DBufferIndex.uv
                    )
                    
                    renderEncoder.setVertexBuffer(
                        mask.opacityBuffer,
                        offset: 0,
                        index: L2DBufferIndex.opacity
                    )
                    
                    // Bind uniform texture.
                    renderEncoder.setFragmentTexture(
                        self.textures[mask.textureIndex],
                        index: L2DTextureIndex.uniform
                    )
                    
                    if let indexBuffer = mask.vertexIndexBuffer {
                        renderEncoder.drawIndexedPrimitives(
                            type: .triangle,
                            indexCount: mask.indexCount,
                            indexType: .uint16,
                            indexBuffer: indexBuffer,
                            indexBufferOffset: 0
                        )
                    }
                }
                
                renderEncoder.endEncoding()
            }
        }
    }
    
    private func renderDrawables(
        viewport: MTLViewport,
        commandBuffer: MTLCommandBuffer,
        passDescriptor: MTLRenderPassDescriptor
    ) {
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }
        
        renderEncoder.setViewport(viewport)
        renderEncoder.setVertexBuffer(
            self.transformBuffer,
            offset: 0,
            index: L2DBufferIndex.transform
        )
        
        for drawable in self.drawableSorted {
            // Bind vertex buffer.
            renderEncoder.setVertexBuffer(
                drawable.vertexPositionBuffer,
                offset: 0,
                index: L2DBufferIndex.position
            )
            
            renderEncoder.setVertexBuffer(
                drawable.vertexTextureCoordinateBuffer,
                offset: 0,
                index: L2DBufferIndex.uv
            )
            
            renderEncoder.setVertexBuffer(
                drawable.opacityBuffer,
                offset: 0,
                index: L2DBufferIndex.opacity
            )
            
            if drawable.cullingMode {
                renderEncoder.setCullMode(.back)
            } else {
                renderEncoder.setCullMode(.none)
            }
            
            if drawable.maskCount > 0 {
                renderEncoder.setRenderPipelineState(self.pipelineStateMasking)
                
                // Bind mask.
                renderEncoder.setFragmentTexture(
                    drawable.maskTexture,
                    index: L2DTextureIndex.mask
                )
            } else {
                switch drawable.blendMode {
                case AdditiveBlending:
                    renderEncoder.setRenderPipelineState(self.pipelineStateBlendingAdditive)
                case MultiplicativeBlending:
                    renderEncoder.setRenderPipelineState(self.pipelineStateBlendingMultiplicative)
                case NormalBlending:
                    renderEncoder.setRenderPipelineState(self.pipelineStateBlendingNormal)
                default:
                    renderEncoder.setRenderPipelineState(self.pipelineStateBlendingNormal)
                }
            }
            
            if drawable.visibility {
                // Bind uniform texture.
                renderEncoder.setFragmentTexture(
                    self.textures[drawable.textureIndex],
                    index: L2DTextureIndex.uniform
                )
                
                if let indexBuffer = drawable.vertexIndexBuffer {
                    renderEncoder.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: drawable.indexCount,
                        indexType: .uint16,
                        indexBuffer: indexBuffer,
                        indexBufferOffset: 0
                    )
                }
            }
        }
        
        renderEncoder.endEncoding()
    }
}
