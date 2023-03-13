//
//  ContentView.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/05.
//

import SwiftUI
import MetalKit

struct MainView: View {
    @State var position: CGSize = CGSize(width: 0, height: 0)
    @State var currentPosition: CGSize = CGSize(width: 0, height: 0)
    var drag: some Gesture{
        DragGesture()
        .onChanged{value in
            self.position = CGSize(
                width:  self.currentPosition.width + value.translation.width,
                height: self.currentPosition.height + value.translation.height
            )
        }
        .onEnded{value in
            self.position = CGSize(
                width: self.currentPosition.width + value.translation.width,
                height: self.currentPosition.height + value.translation.height
            )
            self.currentPosition = self.position
        }
    }
    @State var pinchRate: CGFloat = 1.0
    @State var currentPinchRate: CGFloat = 0.0
    var pinch: some Gesture {
        MagnificationGesture()
            .onChanged{value in
                pinchRate = currentPinchRate + value
            }
            .onEnded{value in
                pinchRate = currentPinchRate + value
                currentPinchRate = pinchRate
            }
    }
    
    var body:some View{
        ZStack(alignment: .leading){
            ContentView().gesture(SimultaneousGesture(drag, pinch))
            VStack{
                Text("x: \(position.width)y: \(position.height)").position(x:200, y:300)
                Text("rate:\(pinchRate)puls:\(currentPinchRate)").position(x:200, y:0)
                Button(action: {
                    position = CGSize(width: 0, height: 0)
                    pinchRate = 1.0
                }){
                    Text("Reset")
                }
            }
            
        }
    }
}

struct ContentView: UIViewRepresentable {


    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {

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
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
