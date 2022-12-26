#version 400 core

in vec2 iPos;
out vec2 fragCoord;

uniform vec2 resolution;

void main() {
    fragCoord = (iPos + 1.0) * 0.5; // Coordinates between 0 and 1
    fragCoord.x *= resolution.x;
    fragCoord.y *= resolution.y;
    gl_Position = vec4(iPos, 0.0, 1.0);
}