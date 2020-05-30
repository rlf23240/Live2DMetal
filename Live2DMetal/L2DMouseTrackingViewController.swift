//
//  L2DMouseTrackingViewController.swift
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

import Cocoa

public class L2DMouseTrackingViewController: MetalViewController {
    private var model: L2DModel?
    private weak var renderer: L2DRenderer?
    
    public func load(model path: String) {
        self.model = L2DModel(jsonPath: path)
        
        if let renderer = self.renderer {
            self.removeRenderer(renderer: renderer)
        }
        
        let renderer = L2DRenderer()
        renderer.delegate = self
        renderer.model = model
        
        self.renderer = renderer
        
        self.addRenderer(renderer: renderer)
    }
}

extension L2DMouseTrackingViewController: L2DRendererDelegate {
    public func rendererUpdate(_ renderer: L2DRenderer, dt: TimeInterval) {
        self.trackMouse(for: renderer)
    }
    
    private func trackMouse(for renderer: L2DRenderer) {
        // Current mouse location.
        let location = NSEvent.mouseLocation
        
        // Origin of window in screen.
        let origin = self.view.window?.frame.origin ?? .zero
        
        // Size of view.
        let size = self.view.frame.size
        
        // Origin in NDC coordinate.
        let ndcOrigin = renderer.origin
        
        // NDC to screen ratio.
        let scale = max(size.width, size.height)
        
        // Vector difference from model center.
        let v = CGPoint(
            x: location.x - origin.x - scale*(0.5+ndcOrigin.x),
            y: location.y - origin.y - scale*(0.5+ndcOrigin.y)
        )
        
        self.model?.setModelParameterNamed(
            "ParamAngleX",
            withValue: Float(2.0*v.x/size.width)*30.0
        )
         
        self.model?.setModelParameterNamed(
            "ParamAngleY",
            withValue: Float(2.0*v.y/size.height)*30.0
        )
    }
}
