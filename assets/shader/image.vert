#version 400

layout(location = 0) in vec2 a_Position;

out vec2 v_Position;

uniform mat4 camMatrix;
uniform mat4 transform;

void main() {
    v_Position = a_Position;
    gl_Position = camMatrix * transform * vec4(a_Position, 0.0, 1.0);
}