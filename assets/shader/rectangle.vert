#version 400

in vec2 vp;
out vec2 st;

uniform vec2 size;
uniform vec2 position;

void main() {
    st = (vp + 1.0) * 0.5;
    gl_Position = vec4((position + (st * size)) * 2.0 - 1.0, 0.0, 1.0);
}