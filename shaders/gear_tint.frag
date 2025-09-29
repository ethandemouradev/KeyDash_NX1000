// shaders/gear_tint.frag
#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 1) uniform sampler2D source; // ShaderEffect's 'source'
layout(std140, binding = 0) uniform qt_ubuf {
    mat4 qt_Matrix;
    vec4 qt_Color;
    float qt_Opacity;
} ubuf;

// Custom uniforms set from QML
layout(std140, binding = 2) uniform ublock {
    vec4 tint;   // rgb used, a ignored
    float alpha; // watermark strength 0..1
} ub;

void main() {
    vec4 src = texture(source, qt_TexCoord0);
    // multiply RGB with tint, keep image alpha scaled by alpha & qt_Opacity
    fragColor = vec4(src.rgb * ub.tint.rgb, src.a * ub.alpha * ubuf.qt_Opacity);
}
