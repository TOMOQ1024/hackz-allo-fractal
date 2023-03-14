//
//  GraphStates.swift
//  MetalKit-Sample
//
//  Created by 東光邦 on 2023/03/14.
//

import SwiftUI
import Foundation

class PinchRate: ObservableObject {
    @Published var value: Float
    init() {
        self.value = 1.0
    }
    init(_ pr: Float) {
        self.value = pr
    }
}

struct PinchRatePreference: PreferenceKey {
    static var defaultValue: Float = 1.0
    static func reduce(value: inout Float, nextValue: () -> Float) {
        value = nextValue()
    }
}
