#version 400 core

in vec2 fragCoord;
out vec4 fragColor;

uniform float size;
uniform vec2 position;
uniform vec4 color;

vec4 circle(vec2 uv, vec2 pos, float rad, vec4 color) {
	float d = length(pos - uv) - rad;
	float t = clamp(d, 0.0, 1.0);
	return vec4(color.r, color.g, color.b, 1.0 - t);
}

void main() {
	fragColor = circle(fragCoord, position, size, color);
}