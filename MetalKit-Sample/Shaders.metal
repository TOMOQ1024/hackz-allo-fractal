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
    float2 res;
    float2 touch;
};
struct Graph {
    float2 origin;
    float radius;
    float angle;
};

struct VertexOut {
    float4 pos [[ position ]];
    float3 color;
    float2 res;
    float time;
    Graph graph;
};


// マンデルブロ集合の描画に必要な，基礎的な関数
int MandelbrotCalc(float2 c, int max_itr = 50){
    float2 z = float2(0, 0);
    for(int k=0; k<max_itr; ++k){
        if(z.x*z.x + z.y*z.y > 4) return k;
        z = float2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c;
    }
    return -1;
}

// rotate float2
float2 Rotate(float2 pos, float angle){
    return {
        pos.x * cos(angle) - pos.y * sin(angle),
        pos.y * cos(angle) + pos.x * sin(angle)
    };
}

float2 RotateAt(float2 pos, float2 ori, float angle){
    return ori + Rotate(pos - ori, angle);
}



// 座標を変換する関数
vertex VertexOut vertexShader(constant VertexIn *vertexIn [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(1)]],
                              constant Graph &graph [[buffer(2)]],
                              unsigned int vid [[vertex_id]]) {
    float2 pos = vertexIn[vid].pos;
    
    VertexOut output;
    output.pos = float4(pos.x, pos.y, 0, 1);
    output.color = float3(pos.x < -0.5 ? 0.0 : 1.0);
    output.time = uniforms.time;
    output.res = uniforms.res;
    output.graph = graph;
    
    return output;
}


// 座標などから色を計算する関数．
fragment half4 fragmentShader(VertexOut vIn [[stage_in]]) {
    float4 pos = vIn.pos;
    float2 res = vIn.res;
    Graph gra = vIn.graph;
    float2 ori = gra.origin;
    float rad = gra.radius;
    float ang = gra.angle;
    
    float2 cpl = float2((pos.x / res.x * 2 - 1) * rad + ori.x,
                        (pos.y / res.y * 2 - 1) * res.y / res.x * rad - ori.y);
    
    int itr = MandelbrotCalc(RotateAt(cpl, ori, ang));
    half c_ = sqrt(itr / 50.0);
    half3 c = itr < 0 ? 1.0 : half3(c_, 0, c_);
    //half3 c = half3(vertexIn.color);
    //float t = vertexIn.time;
    //return half4(c.x, c.y, (1.0+cos(t))/2.0, 1.0);
    return half4(c, 1.0);
}
