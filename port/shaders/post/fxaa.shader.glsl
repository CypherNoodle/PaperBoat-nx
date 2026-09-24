@prism(type='fragment', name='PaperBoat FXAA', version='1.0.0', description='Low-cost fullscreen edge smoothing', author='PaperBoat')

@if(BACKEND_VULKAN)
#version 450
@include("shaders/vulkan/include/common.glsli")

@if(VERTEX_SHADER)
    @include("shaders/vulkan/include/fast3d_vs.glsli")
@else
    layout(location = 0) out vec4 vOutColor;
    layout(location = 0) in vec2 vTexCoord0;
    layout(set = 1, binding = 0) uniform sampler2D uTex0;

    #define PB_SAMPLE(uv) texture(uTex0, uv)
    #define PB_OUTPUT vOutColor
@end
@else
@{GLSL_VERSION}

@if(VERTEX_SHADER)
    @include("shaders/opengl/include/fast3d_vs.glsli")
@else
    @if(core_opengl || opengles)
    out vec4 vOutColor;
    @end
    @{attr} vec2 vTexCoord0;
    uniform sampler2D uTex0;
    @if(opengles)
    uniform highp vec4 uCustom[32];
    @else
    uniform vec4 uCustom[32];
    @end

    #define PB_SAMPLE(uv) @{texture}(uTex0, uv)
    #define PB_OUTPUT @{vOutColor}
@end
@end

@if(!VERTEX_SHADER)
    float pbLuma(vec3 rgb) {
        return dot(rgb, vec3(0.299, 0.587, 0.114));
    }

    void main() {
        vec2 texel = uCustom[1].zw;
        vec3 rgbNW = PB_SAMPLE(vTexCoord0 + texel * vec2(-1.0, -1.0)).rgb;
        vec3 rgbNE = PB_SAMPLE(vTexCoord0 + texel * vec2( 1.0, -1.0)).rgb;
        vec3 rgbSW = PB_SAMPLE(vTexCoord0 + texel * vec2(-1.0,  1.0)).rgb;
        vec3 rgbSE = PB_SAMPLE(vTexCoord0 + texel * vec2( 1.0,  1.0)).rgb;
        vec4 center = PB_SAMPLE(vTexCoord0);

        float lumaNW = pbLuma(rgbNW);
        float lumaNE = pbLuma(rgbNE);
        float lumaSW = pbLuma(rgbSW);
        float lumaSE = pbLuma(rgbSE);
        float lumaM = pbLuma(center.rgb);
        float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
        float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

        vec2 dir;
        dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
        dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
        float reduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * 0.03125, 0.0078125);
        float inverseMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + reduce);
        dir = clamp(dir * inverseMin, vec2(-8.0), vec2(8.0)) * texel;

        vec3 rgbA = 0.5 * (PB_SAMPLE(vTexCoord0 + dir * (1.0 / 3.0 - 0.5)).rgb +
                           PB_SAMPLE(vTexCoord0 + dir * (2.0 / 3.0 - 0.5)).rgb);
        vec3 rgbB = rgbA * 0.5 + 0.25 * (PB_SAMPLE(vTexCoord0 + dir * -0.5).rgb +
                                         PB_SAMPLE(vTexCoord0 + dir *  0.5).rgb);
        float lumaB = pbLuma(rgbB);
        PB_OUTPUT = vec4((lumaB < lumaMin || lumaB > lumaMax) ? rgbA : rgbB, center.a);
    }
@end
