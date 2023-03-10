//
//  Shaders.metal
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/08.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

// 座標を変換する関数
vertex Fragment vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    output.color = input.color;
    
    return output;
}

// 座標から色を計算する関数．ここでマンデルブロ集合の描画を実装する．
fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    return input.color;
}
