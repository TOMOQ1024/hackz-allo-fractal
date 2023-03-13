//
//  ContentView.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/05.
//

import SwiftUI
import MetalKit
import Foundation

struct MainView: View {
    @State var position: CGSize = CGSize(width: 0, height: 0)
    @State var currentPosition: CGSize = CGSize(width: 0, height: 0)
    @State var positionPast = Array(repeating:CGSize(width: 0, height: 0), count: 3)
    @State var positionSpeed: CGSize = CGSize(width: 0, height: 0)
    @State var posPastIndex: Int = 0
    
    @State var pinchRate: CGFloat = 1.0
    @State var currentPinchRate: CGFloat = 0.0
    @State var pinchPast:[CGFloat] = Array(repeating:0.0, count: 3)
    @State var pinchSpeed: CGFloat = 0.0
    @State var pinPastIndex: Int = 0
    
    @State var rotation: Angle = Angle()
    @State var currentRotation: Angle = Angle()
    @State var rotationPast:[Angle] = Array(repeating:Angle(), count: 3)
    @State var rotationSpeed: Angle = Angle()
    @State var rttPastIndex: Int = 0
    
    var drag: some Gesture{
        DragGesture()
        .onChanged{value in
            self.position = CGSize(
                width:  self.currentPosition.width + value.translation.width,
                height: self.currentPosition.height + value.translation.height
            )
//            positionSpeed = CGSize(width: 0, height: 0)
            positionPast[posPastIndex] = CGSize(
                width: value.translation.width,
                height:value.translation.height
            )
            if(posPastIndex==2){
                posPastIndex = 0
            }else{
                posPastIndex += 1
            }
            self.positionSpeed = CGSize(
                width: value.translation.width - self.positionPast[posPastIndex].width,
                height:value.translation.height - self.positionPast[posPastIndex].height
            )
        }
        .onEnded{value in
            self.position = CGSize(
                width: self.currentPosition.width + value.translation.width,
                height: self.currentPosition.height + value.translation.height
            )
            self.currentPosition = self.position
            self.positionSpeed = CGSize(
                width: value.translation.width - self.positionPast[posPastIndex].width,
                height:value.translation.height - self.positionPast[posPastIndex].height
            )
        }
    }
    
    var pinch: some Gesture {
        MagnificationGesture()
            .onChanged{value in
                pinchRate = currentPinchRate + value
                pinchPast[pinPastIndex] = value
                if(posPastIndex==2){
                    posPastIndex = 0
                }else{
                    posPastIndex += 1
                }
                pinchSpeed = value - pinchPast[pinPastIndex]
            }
            .onEnded{value in
                pinchRate = currentPinchRate + value
                currentPinchRate = pinchRate
                pinchSpeed = value - pinchPast[pinPastIndex]
            }
    }
    
    var rotate: some Gesture {
        RotationGesture()
            .onChanged{value in
                rotation = currentRotation + value
                rotationPast[rttPastIndex] = value
                if(rttPastIndex==2){
                    rttPastIndex = 0
                }else{
                    rttPastIndex += 1
                }
                rotationSpeed = value - rotationPast[rttPastIndex]
            }
            .onEnded{value in
                rotation = currentRotation + value
                currentRotation = rotation
                rotationSpeed = value - rotationPast[rttPastIndex]
            }
    }

    var body:some View{
        ZStack(alignment: .leading){
            ContentView().gesture(SimultaneousGesture(drag, pinch))
            VStack{
                Text("x: \(position.width)y: \(position.height)").position(x:200, y:300)
                Text("dx: \(positionSpeed.width)dy: \(positionSpeed.height)").position(x:200, y:0)
                Text("px: \(positionPast[posPastIndex].width)py: \(positionPast[posPastIndex].height)").position(x:200, y:-50)
                Text("rate:\(pinchRate)spd:\(pinchSpeed)").position(x:200, y:0)
                Text("rotate:\(rotation.radians)spd:\(rotationSpeed.radians)").position(x:200, y:0)
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
