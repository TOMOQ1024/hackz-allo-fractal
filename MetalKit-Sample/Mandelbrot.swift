//
//  Manderbrot.swift
//  MetalKit-Sample
//
//  Created by 東光邦 on 2023/03/14.
//
import SwiftUI
import MetalKit
import Foundation

struct Mandelbrot: UIViewRepresentable {
    var pinchRate: Float = 1.0
    let moveSpeed: SIMD2<Float>
    let zoomSpeed: Float
    let rotateSpeed: Float
    let renderMode: Int
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    func makeUIView(context: UIViewRepresentableContext<Mandelbrot>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<Mandelbrot>) {
        context.coordinator.updateGraph(
            true,
            moveSpeed,
            zoomSpeed,
            rotateSpeed,
            renderMode
        )
    }
    

}
