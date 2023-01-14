#version 400

layout(location = 0) in vec2 a_Position;
layout(location = 1) in vec2 a_TexCoord;

out vec2 v_Position;
out vec2 v_TexCoord;

uniform mat4 camMatrix;
uniform mat4 transform;

void main() {
    v_TexCoord = a_TexCoord;
    gl_Position = camMatrix * transform * vec4(a_Position, 0.0, 1.0);
}