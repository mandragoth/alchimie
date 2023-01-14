#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoord;

uniform vec4 color;

void main() {
    fragColor = vec4(v_TexCoord, 0.0, 1.0);
}