//
//  Shaders.metal
//  MetalKit-Sample
//
//  Created by tomoq on 2023/03/08.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct VertexIn {
    float2 pos;
};

struct Uniforms {
    float time;
    float aspectRatio;
    float2 touch;
};
struct VertexOut {
    float4 pos [[ position ]];
    float3 color;
    float time;
};


// マンデルブロ集合の描画に必要な，基礎的な関数
int MandelbrotCalc(float cr, float ci, int max_itr = 50){
    float zt;
    float zr = 0;
    float zi = 0;
    for(int k=0; k<max_itr; ++k){
        if(zr*zr + zi*zi > 4) return k;
        zt = cr + zr * zr - zi * zi;
        zi = ci + 2 * zr * zi;
        zr = zt;
    }
    return -1;
}



// 座標を変換する関数
vertex VertexOut vertexShader(constant VertexIn *vertexIn [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(1)]],
                              unsigned int vid [[vertex_id]]) {
    float2 pos = vertexIn[vid].pos;
    
    VertexOut output;
    output.pos = float4(pos.x, pos.y, 0, 1);
    output.color = float3(0.0);
    output.time = uniforms.time;
    
    return output;
}

// 座標などから色を計算する関数．
fragment half4 fragmentShader(VertexOut vertexIn [[stage_in]]) {
    float4 pos = vertexIn.pos;
    int itr = MandelbrotCalc(pos.x * 5.0, pos.y * 5.0);
    float c = itr < 0 ? 1.0 : itr / 50.0;
    //float t = vertexIn.time;
    //return half4(c.x, c.y, (1.0+cos(t))/2.0, 1.0);
    return half4(c, c, c, 1.0);
}
