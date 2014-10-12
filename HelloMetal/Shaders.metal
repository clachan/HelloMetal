//
//  Shaders.metal
//  HelloMetal
//
//  Created by Clay Chang on 10/11/14.
//  Copyright (c) 2014 NTU. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
vertex float4 basic_vertex(
  const device packed_float3* vertex_array [[ buffer(0) ]],
  unsigned int vid                         [[ vertex_id ]])
{
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment()
{
    return half4(1.0);
}
 */

struct ColoredVertex {
    float4 position [[position]];
    float4 color;
};

vertex ColoredVertex vertex_main(constant float4* position [[buffer(0)]],
                                 constant float4* color    [[buffer(1)]],
                                 uint             vid      [[vertex_id]]) {
    ColoredVertex vert;
    vert.position = position[vid];
    vert.color = color[vid];
    return vert;
}

fragment float4 fragment_main(ColoredVertex vert [[stage_in]]) {
    return vert.color;
}
