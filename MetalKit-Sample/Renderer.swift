//
//  MetalView.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/06.
//

import MetalKit


struct Uniforms {
    var time: Float
    var res: SIMD2<Float>
    var touch: SIMD2<Float>
}

struct Graph {
    var ori: SIMD2<Float>
    var radius: Float
    var angle: Float
    
    init() {
        ori = [0.0, 0.0]
        radius = 2.0
        angle = Float(CGFloat.pi) / 2.0
        ori = [0.0, 0.4]
        radius = 0.1
        angle = 0.5
    }
    
    func rot(_ p:SIMD2<Float>, _ a:Float) -> SIMD2<Float> {
        return [
            p.x * cos(a) - p.y * sin(a),
            p.y * cos(a) + p.x * sin(a)
        ];
    }
    
    func rotAt(_ p:SIMD2<Float>, _ o:SIMD2<Float>, _ a:Float) -> SIMD2<Float> {
        return rot(p-o, a) + o;
    }
}

// ContentViewのmakeCoordinatorメソッド内で呼び出される
class Renderer: NSObject, MTKViewDelegate {
    var graph: Graph = Graph();
    
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    var uniforms: Uniforms
    private var indices: [UInt16]!
    private var indexBuffer: MTLBuffer!
    var mtkView: MTKView!
    var preferredFramesTime: Float!
    var targetMetalTextureSize: CGSize = CGSize.zero
    var metalViewDrawableSize: CGSize? = nil
    var bufferWidth: Int = -1
    
    init(_ parent: Mandelbrot, _ moveSpeed: SIMD2<Float>) {
        
//        uniforms.aspectRatio = Float(mtkView.frame.size.width / mtkView.frame.size.height)
//        preferredFramesTime = 1.0 / Float(mtkView.preferredFramesPerSecond)
        
        uniforms = Uniforms(
            time: Float(0.0),
            res: SIMD2<Float>(
                Float(UIScreen.main.nativeBounds.width),
                Float(UIScreen.main.nativeBounds.height)
            ),
            touch: SIMD2<Float>())
        //uniforms.aspectRatio = Float(9 / 16)
        uniforms.time = 0.0
        //uniforms.res = [1179, 2556]
        preferredFramesTime = 1.0 / Float(60.0)
        
        
        // MTLDeviceの生成
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        let vertices = [
            Vertex(pos: [-1, -1]),
            Vertex(pos: [ 1, -1]),
            Vertex(pos: [-1,  1]),
            Vertex(pos: [ 1, -1]),
            Vertex(pos: [-1,  1]),
            Vertex(pos: [ 1,  1]),
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        uniforms.time += preferredFramesTime
        
        //
        guard let drawable = view.currentDrawable else {
            return
        }
        
        // コマンドバッファはCPUからGPUへ送られる命令
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        //
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        //
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder?.setVertexBytes(&graph, length: MemoryLayout<Graph>.stride, index: 2)
        //renderEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder?.endEncoding()
        
        //
        commandBuffer?.present(drawable)
        
        // GPUにコマンドバッファを送る
        commandBuffer?.commit()
    }
    
    public func setVertices(_ vertices: [Vertex]) {
        //self.vertices += vertices
        let _ = print("hi")
    }
}
