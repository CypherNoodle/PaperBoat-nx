@prism(type='fragment', name='PaperBoat CAS', version='1.0.0', description='Contrast-adaptive fullscreen sharpening', author='PaperBoat')

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
    void main() {
        vec2 texel = uCustom[1].zw;
        vec4 center = PB_SAMPLE(vTexCoord0);
        vec3 north = PB_SAMPLE(vTexCoord0 + vec2(0.0, -texel.y)).rgb;
        vec3 south = PB_SAMPLE(vTexCoord0 + vec2(0.0,  texel.y)).rgb;
        vec3 west  = PB_SAMPLE(vTexCoord0 + vec2(-texel.x, 0.0)).rgb;
        vec3 east  = PB_SAMPLE(vTexCoord0 + vec2( texel.x, 0.0)).rgb;

        vec3 minimum = min(center.rgb, min(min(north, south), min(west, east)));
        vec3 maximum = max(center.rgb, max(max(north, south), max(west, east)));
        vec3 amplitude = clamp(min(minimum, 1.0 - maximum) / max(maximum, vec3(0.0001)), 0.0, 1.0);
        amplitude = sqrt(amplitude);

        // CAS peak at medium sharpness. Negative neighbour weights sharpen while
        // the contrast term suppresses ringing around already-strong edges.
        vec3 weight = amplitude * (-1.0 / 6.5);
        vec3 sharpened = (north * weight + south * weight + west * weight + east * weight + center.rgb) /
                         (1.0 + 4.0 * weight);
        PB_OUTPUT = vec4(clamp(sharpened, 0.0, 1.0), center.a);
    }
@end
