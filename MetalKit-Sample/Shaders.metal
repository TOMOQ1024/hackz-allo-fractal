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
    int renderMode;
};

struct VertexOut {
    float4 pos [[ position ]];
    float3 color;
    float2 res;
    float time;
    Graph graph;
};

struct MCOut {
    int itr;
    float2 c;
    float2 z;
};


// マンデルブロ集合の描画に必要な，基礎的な関数
MCOut MandelbrotCalc(float2 c, float absLimit = 2, int max_itr = 50){
    float2 z = float2(0, 0);
    for(int k=0; k<max_itr; ++k){
        if(length(z) > absLimit) return { k, c, z };
        z = float2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c;
    }
    return { -1, c, z };
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

float3 hsv2rgb(float3 hsv)
{
    float3 rgb;

    if (hsv.y == 0){
        // S（彩度）が0と等しいならば無色もしくは灰色
        rgb.r = rgb.g = rgb.b = hsv.z;
    } else {
        // 色環のH（色相）の位置とS（彩度）、V（明度）からRGB値を算出する
        hsv.x *= 6.0;
        float i = floor (hsv.x);
        float f = hsv.x - i;
        float aa = hsv.z * (1 - hsv.y);
        float bb = hsv.z * (1 - (hsv.y * f));
        float cc = hsv.z * (1 - (hsv.y * (1 - f)));
        if( i < 1 ) {
            rgb.r = hsv.z;
            rgb.g = cc;
            rgb.b = aa;
        } else if( i < 2 ) {
            rgb.r = bb;
            rgb.g = hsv.z;
            rgb.b = aa;
        } else if( i < 3 ) {
            rgb.r = aa;
            rgb.g = hsv.z;
            rgb.b = cc;
        } else if( i < 4 ) {
            rgb.r = aa;
            rgb.g = bb;
            rgb.b = hsv.z;
        } else if( i < 5 ) {
            rgb.r = cc;
            rgb.g = aa;
            rgb.b = hsv.z;
        } else {
            rgb.r = hsv.z;
            rgb.g = aa;
            rgb.b = bb;
        }
    }
    return rgb;
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
    
    
    //int
    switch(gra.renderMode){
        case 0:
        {
            MCOut calcRes = MandelbrotCalc(RotateAt(cpl, ori, ang), 2, 50);
            half c = pow(1.0 * calcRes.itr / 50, 0.5);
            return calcRes.itr < 0 ? half4(1.0) : half4(c, 0, c, 1.0);
        }
        case 1:
        {
            MCOut calcRes = MandelbrotCalc(RotateAt(cpl, ori, ang), 2, 100);
            half arg = atan2(calcRes.z.y, calcRes.z.x);
            half ab = exp(-1/length(calcRes.z));
            float3 c = hsv2rgb(float3(fmod(fmod(arg/2/M_PI_F, 1.0)+1.0, 1.0), 0.2, ab));
            return half4(half3(c), 1.0);
        }
        case 2:
        {
            MCOut calcRes = MandelbrotCalc(RotateAt(cpl, ori, ang), 300, 100);
            MCOut calcResX = MandelbrotCalc(RotateAt(cpl+float2(rad/10000,0), ori, ang), 300, 100);
            MCOut calcResY = MandelbrotCalc(RotateAt(cpl+float2(0,rad/10000), ori, ang), 300, 100);
            half narg = fmod(fmod(atan2(length(calcResX.z) - length(calcRes.z), length(calcResY.z) - length(calcRes.z))/2/M_PI_F, 1.0)+1.0, 1.0);
            //half ab = exp(-1/length(calcRes.z));
            float3 c = hsv2rgb(float3(narg, 0.2, 1.0));
            return half4(half3(c), 1.0);
        }
        case 3:
        {
            // 
            MCOut calcRes = MandelbrotCalc(RotateAt(cpl, ori, ang), 300, 100);
            MCOut calcResX = MandelbrotCalc(RotateAt(cpl+float2(rad/100000,0), ori, ang), 300, 100);
            MCOut calcResY = MandelbrotCalc(RotateAt(cpl+float2(0,rad/100000), ori, ang), 300, 100);
            half narg = atan2(length(calcResX.z) - length(calcRes.z), length(calcResY.z) - length(calcRes.z));
            half c = (cos(narg+0.8)+1)/2;
            return half4(c, c, c, 1.0);
        }
        case 4:
        {
            MCOut calcRes = MandelbrotCalc(RotateAt(cpl, ori, ang), 2, 200);
            half c = calcRes.itr / 40.0;
            return calcRes.itr < 0 ? half4(1.0) : half4(cos(c)*cos(c), sin(c)*sin(c), 1.0, 1.0);
        }
    }
    
    // half3 c = itr < 0 ? 1.0 : half3(c_, 0, c_);
    //half3 c = half3(vertexIn.color);
    //float t = vertexIn.time;
    //return half4(c.x, c.y, (1.0+cos(t))/2.0, 1.0);
    
}
