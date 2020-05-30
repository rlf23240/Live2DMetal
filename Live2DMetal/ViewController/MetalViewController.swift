//
//  MetalViewContoller.swift
//  GUIKit
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
import MetalPerformanceShaders
import QuartzCore

open class MetalViewController: NSViewController {
    public private(set) var renderers: [MetalRenderer] = []
    
    private var viewport: MTLViewport!
    private var commandQueue: MTLCommandQueue!
    
    public override func viewDidLoad() {
        guard let view = self.view as? MTKView else {
            return
        }
        
        view.delegate = self
        view.framebufferOnly = true
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        // Initial viewport.
        let size = view.drawableSize
        if size.width > size.height {
            self.viewport = MTLViewport(
                originX: 0.0,
                originY: Double(size.height-size.width)/2.0,
                width: Double(size.width),
                height: Double(size.width),
                znear: 0.0,
                zfar: 1.0
            )
        } else {
            self.viewport = MTLViewport(
                originX: Double(size.width-size.height)/2.0,
                originY: 0.0,
                width: Double(size.height),
                height: Double(size.height),
                znear: 0.0,
                zfar: 1.0
            )
        }
        
        self.startMetal()
    }
}

extension MetalViewController: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {        
        // Viewport.
        if size.width > size.height {
            self.viewport = MTLViewport(
                originX: 0.0,
                originY: Double(size.height-size.width)/2.0,
                width: Double(size.width),
                height: Double(size.width),
                znear: 0.0,
                zfar: 1.0
            )
        } else {
            self.viewport = MTLViewport(
                originX: Double(size.width-size.height)/2.0,
                originY: 0.0,
                width: Double(size.height),
                height: Double(size.height),
                znear: 0.0,
                zfar: 1.0
            )
        }
        
        for renderer in self.renderers {
            renderer.drawableSizeWillChange(for: view, size: size)
        }
    }
    
    public func draw(in view: MTKView) {
        let dt = 1.0/TimeInterval(view.preferredFramesPerSecond)
        
        for render in self.renderers {
            render.update(dt: dt)
        }
        
        // Get drawable, create command buffer and pass to renderer.
        if let drawable = view.currentDrawable {
            guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
                return
            }
                        
            self.clear(drawable: drawable, commandBuffer: commandBuffer)
            
            let renderPassDesc = MTLRenderPassDescriptor()
            renderPassDesc.colorAttachments[0].texture = drawable.texture
            renderPassDesc.colorAttachments[0].loadAction = .load
            renderPassDesc.colorAttachments[0].storeAction = .store
            renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 0.0
            )
            
            // Renderers.
            for renderer in self.renderers {
                renderer.render(
                    dt: dt,
                    viewport: self.viewport,
                    commandBuffer: commandBuffer,
                    passDescriptor: renderPassDesc
                )
            }
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

extension MetalViewController {
    private func startMetal() {
        guard let view = self.view as? MTKView else {
            return
        }
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        
        // Command queue.
        self.commandQueue = device.makeCommandQueue()
        
        view.device = device
        view.isPaused = false
        view.isHidden = false
        
        for renderer in self.renderers {
            renderer.start(for: view)
        }
    }
    
    private func stopMetal() {
        // Unlink with device.
        if let view = self.view as? MTKView {
            view.isPaused = true
            view.isHidden = true
            view.device = nil
        }
    }
    
    private func clear(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) {
        let renderPassDesc = MTLRenderPassDescriptor()
        renderPassDesc.colorAttachments[0].texture = drawable.texture
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 0.0,
            blue: 0.0,
            alpha: 0.0
        )
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
            return
        }
        
        renderEncoder.endEncoding()
    }
}

extension MetalViewController {
    public func addRenderer(renderer: MetalRenderer) {
        guard let view = self.view as? MTKView else {
            return
        }
        
        self.renderers.append(renderer)
        
        if view.isPaused == false {
            renderer.start(for: view)
        } else {
            if self.renderers.count == 1 {
                startMetal()
            }
        }
    }
    
    public func removeRenderer(renderer: MetalRenderer) {
        self.renderers.removeAll(where: {$0 === renderer})
        
        if self.renderers.count == 0 {
            self.stopMetal()
        }
    }
}
