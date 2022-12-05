#version 400

in vec2 oPos;
out vec4 fragColor;

uniform sampler2D tex;
uniform vec4 color;

void main() {
    // Sample texture and apply color
    fragColor = texture(tex, oPos) * color;
}