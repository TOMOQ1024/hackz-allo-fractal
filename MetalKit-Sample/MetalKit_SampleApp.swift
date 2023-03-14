//
//  MetalKit_SampleApp.swift
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/05.
//

import SwiftUI
import UIKit

// エントリーポイントとなる構造体
@main
struct MetalKit_SampleApp: App {
    // この中に画面内で表示する要素を書いていく．
    // 宣言だけで追加，メソッドで位置とかの調整．
    var body: some Scene {
        WindowGroup {
            MainView()
                .statusBar(hidden: true)
                //.scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
