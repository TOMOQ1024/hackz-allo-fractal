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
    
    let moveSpeed: SIMD2<Float>
    let zoomSpeed: Float
    let rotateSpeed: Float

    func makeCoordinator() -> Renderer {
        Renderer(self, moveSpeed)
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
        return mtkView
    }
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<Mandelbrot>) {
        print("update")
    }

}
