//
//  GraphStates.swift
//  MetalKit-Sample
//
//  Created by 東光邦 on 2023/03/14.
//

import SwiftUI
import Foundation

class GraphStates: ObservableObject {
    @Published var moveSpeed: SIMD2<Float>
    @Published var zoomSpeed: Float
    @Published var rotateSpeed: Float
    init() {
        self.moveSpeed = [0, 0]
        self.zoomSpeed = 0.0
        self.rotateSpeed = 0.0
    }
    init(ms: SIMD2<Float>, zs: Float, rs: Float) {
        self.moveSpeed = ms
        self.zoomSpeed = zs
        self.rotateSpeed = rs
    }
}


struct ContentView : View {
    
    @EnvironmentObject var graphStates: GraphStates
//    var _ = print("\(graphStates.zoomSpeed)")
    var body:some View{
        VStack {
            Text("\(graphStates.zoomSpeed)")
        }
    }
}
