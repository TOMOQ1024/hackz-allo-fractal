//
//  ContentView.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/05.
//

import SwiftUI
import MetalKit
import Foundation

//class GraphStates: ObservableObject {
//    @Published var moveSpeed: SIMD2<Float>
//    @Published var zoomSpeed: Float
//    @Published var rotateSpeed: Float
//    init() {
//        self.moveSpeed = [0, 0]
//        self.zoomSpeed = 0.0
//        self.rotateSpeed = 0.0
//    }
//    init(ms: SIMD2<Float>, zs: Float, rs: Float) {
//        self.moveSpeed = ms
//        self.zoomSpeed = zs
//        self.rotateSpeed = rs
//    }
//}
let arraySize = 2

struct MainView: View {
    let musicPlayer = SoundPlayer()
    @State var position: CGSize = CGSize(width: 1, height: 0)
    @State var currentPosition: CGSize = CGSize(width: 0, height: 0)
    @State var positionPast = Array(repeating:CGSize(width: 0, height: 0), count: arraySize)
    @State var positionSpeed: CGSize = CGSize(width: 0, height: 0)
    @State var posPastIndex: Int = 0
    
    @State var pinchRate: Float = 1.0
    @State var currentPinchRate: CGFloat = 1.0
    @State var pinchPast:CGFloat = 1.0
    @State var pinchSpeed: CGFloat = 1.0
    
    @State var rotation: Angle = Angle()
    @State var currentRotation: Angle = Angle()
    @State var rotationPast:[Angle] = Array(repeating:Angle(), count: arraySize)
    @State var rotationSpeed: Angle = Angle()
    @State var rttPastIndex: Int = 0
    
    @State var renderMode: Int = 0
    
    var drag: some Gesture{
        DragGesture()
        .onChanged{value in
            self.position = CGSize(
                width:  self.currentPosition.width + value.translation.width,
                height: self.currentPosition.height + value.translation.height
            )
            self.pinchSpeed = 1
            self.rotationSpeed = Angle()
//            positionSpeed = CGSize(width: 0, height: 0)
            positionPast[posPastIndex] = CGSize(
                width: value.translation.width,
                height:value.translation.height
            )
            if(posPastIndex==arraySize-1){
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
            for i in 0..<arraySize{
                self.positionPast[i] = CGSize(width: 0, height: 0)
            }
            
        }
    }
    @State var isFirst: Bool = true
    var pinch: some Gesture {
        MagnificationGesture()
            .onChanged{value in
                if(isFirst){
                    currentPinchRate = value
                    isFirst = false
                }
                let delta = value/currentPinchRate
                currentPinchRate = value
                pinchPast = value
                
                pinchSpeed = delta
                //Music Update
            }
            .onEnded{value in
                pinchSpeed = value / pinchPast
                isFirst = true
            }
    }
    
    var rotate: some Gesture {
        RotationGesture()
            .onChanged{value in
                print("\(value)")
                rotation = currentRotation + value
                rotationPast[rttPastIndex] = value
                rttPastIndex += 1
                if(rttPastIndex == arraySize){
                    rttPastIndex = 0
                }
                rotationSpeed = value - rotationPast[rttPastIndex]
                print(rotationSpeed)
            }
            .onEnded{value in
                rotation = currentRotation + value
                currentRotation = rotation
                rotationSpeed = value - rotationPast[rttPastIndex]
                for i in 0..<arraySize{
                    rotationPast[i] = Angle()
                }
                print("------End------")
            }
    }
    var tap:some Gesture{
        TapGesture(count:1)
            .onEnded({
            self.positionSpeed = CGSize(width: 0, height: 0)
            self.pinchSpeed = 1
            self.rotationSpeed = Angle()
        })
    }

    var body:some View{
        ZStack(alignment: .leading){
            Mandelbrot(
                moveSpeed:[Float(positionSpeed.width), Float(positionSpeed.height)],
                zoomSpeed:Float(pinchSpeed),
                rotateSpeed:Float(rotationSpeed.radians),
                renderMode:renderMode
            )
                .gesture(SimultaneousGesture(drag, SimultaneousGesture(pinch, SimultaneousGesture(rotate, tap))))
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
                }.position(x:200, y:-100)
            }
            VStack {
                Button(action: {
                    print("hello")
                    renderMode += 1
                }){
                    Image(systemName: "arrow.left.arrow.right")
                }
                    .frame(width: 100, height: 100, alignment: .leading)
                    .padding()
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .shadow(color: Color.black, radius: 3)
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
