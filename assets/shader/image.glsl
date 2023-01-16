#type vert
#version 400 core

layout(location = 0) in vec2 a_Position;
layout(location = 1) in vec2 a_TexCoord;

out vec2 v_Position;
out vec2 v_TexCoord;

uniform mat4 u_CamMatrix;
uniform mat4 u_Transform;

void main() {
    v_TexCoord = a_TexCoord;
    gl_Position = u_CamMatrix * u_Transform * vec4(a_Position, 0.0, 1.0);
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoord;

uniform sampler2D u_Texture;
uniform vec4 u_Color;

void main() {
    fragColor = texture(u_Texture, v_TexCoord);
}
