#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoord;

uniform sampler2D u_Texture;
uniform vec4 u_Color;

void main() {
    fragColor = texture(u_Texture, v_TexCoord);
}