//
//  MetalView.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/06.
//

import MetalKit

func Clamp(_ m: Float, _ v: Float, _ M: Float) -> Float {
    return max(min(M,v),m)
}

func Clamp2(_ m: SIMD2<Float>, _ v: SIMD2<Float>, _ M: SIMD2<Float>) -> SIMD2<Float> {
    return max(min(M,v),m)
}

struct Uniforms {
    var time: Float
    var res: SIMD2<Float>
    var touch: SIMD2<Float>
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

struct Graph {
    var origin: SIMD2<Float>
    var radius: Float
    var angle: Float
    var renderMode: Int
    var renderModesCount: Int = 5
    // 0: 黒→紫の単純なグラデーション
    // 1: 偏角を用いた虹色のグラデーション(BubbleCloud)
    // 2: 法線，虹色
    // 3: 法線，白黒
    // 4: マゼンタ⇄シアン循環する0形式の波
    
    init() {
        origin = [0.0, 0.0]
        radius = 2.0
        angle = Float(CGFloat.pi) / 2.0
        renderMode = 1
        origin = [-1.0, 0.0]
        radius = 0.5
        angle = 0.5
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
    
    let musicPlayer = SoundPlayer()
    
    init(_ parent: Mandelbrot) {
        
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
        updateGraph(false)
        
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
    
    var moveSpeed: SIMD2<Float> = [0, 0]
    var zoomSpeed: Float = 1
    var rotateSpeed: Float = 0
    var zoomRate: Float = 1
    func updateGraph(_ isDataProvided: Bool, _ _ms: SIMD2<Float> = [0, 0], _ _zs: Float = 0, _ _rs: Float = 0, _ _rm: Int = -1) {
        var ms = _ms
        var zs = _zs
        var rs = Clamp(-1,_rs,1)
        
        if(abs(rs) < 10e-4){
            rs = 0
        }
        rs /= 3

        
        if(isDataProvided){
            moveSpeed = ms
            zoomSpeed = zs
            rotateSpeed = rs
            graph.renderMode = _rm % graph.renderModesCount
        }
        else{
            // 減衰
//            moveSpeed /+ 1.01
//            zoomSpeed = pow(zoomSpeed, 0.99)
//            rotateSpeed /= 1.01
            ms = moveSpeed
            zs = zoomSpeed
            rs = rotateSpeed
        }
        let radSpeed = graph.radius / zs
        graph.radius = Clamp(1.0e-4, radSpeed, 1.0e+3)
        if(radSpeed > 1.0e-4 && radSpeed < 1.0e+3){
            zoomRate *= zs
        }
        graph.angle -= rs
        //let origin_delta_p = rot([ms.x, ms.y] / Float(UIScreen.main.bounds.width) * graph.radius, graph.angle)
        print(ms)
        let origin_delta = rot([ms.x, ms.y] / Float(UIScreen.main.bounds.width) * graph.radius, graph.angle)
        graph.origin -= [origin_delta.x, -origin_delta.y]
        graph.origin = Clamp2([-2, -2], graph.origin, [2, 2])
        
        musicPlayer.switchMode(mode: _rm%graph.renderModesCount, rate: zoomRate)
        if(zoomRate > 1){
            if(musicPlayer.isPlay){
                musicPlayer.update(rate: zoomRate)
            }else{
                musicPlayer.musicPlay(rate: zoomRate)
            }
        }else{
            musicPlayer.stopAllMusic()
        }
        print("zoom:\(zoomRate)")
    }
}
