#type vert
#version 400 core

layout (location = 0) in vec2 a_Position;
layout (location = 1) in vec2 a_TexCoords;

out vec2 v_TexCoords;

void main() {
    gl_Position = vec4(a_Position, 0.0, 1.0);
    v_TexCoords = a_TexCoords;
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoords;

uniform sampler2D u_ScreenTexture;
uniform float u_Gamma;

void main() {
    vec4 fragment = texture(u_ScreenTexture, v_TexCoords);
    fragColor.rgb = pow(fragment.rgb, vec3(1.0f / u_Gamma));
}