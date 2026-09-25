#version 150

#moj_import <frag_utils.glsl>
#moj_import <config.glsl>

uniform sampler2D Sampler0;

in vec2 UV0;

in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord2;
in vec3 offset;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) discard;

    bool finalDestroyStage = texelFetch(Sampler0, ivec2(9, 1), 0).a == 1.0;
    if (finalDestroyStage) color.rgb = sqrt(color.rgb);

    // Only extrude the original dark crack pixels. Bright grays used to carry
    // alpha-254 control markers and should retain their authored color.
    if (Destroy_Depth > 0 && !finalDestroyStage && color.a == 1 && color.r < 0.5) {
        float i;
        for (i = 1.0; i <= 16.0; i++) {
            vec4 depthSample = texture(Sampler0, texCoord0 + offset.xy * i);
            if (depthSample.a != 1 || depthSample.r >= 0.5) break;
        }

        if (i <= 16.0) color = (i <= 2.0) ? vec4(0.6, 0.6, 0.58, 1.0) : vec4(vec3(0.3 - i * 0.01), 1.0); 
        else color = vec4(vec3(0.5 - i * 0.01), 1.0); 
    }

    fragColor = color * vertexColor;
}
