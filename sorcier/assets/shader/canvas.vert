#version 400

layout (location = 0) in vec2 iPos;

out vec2 oPos;

uniform vec2 size;
uniform vec2 position;
uniform vec4 clip;
uniform vec2 rotation;
uniform vec2 flip;

void main() {
    // Apply rotation
    vec2 rotated = vec2(iPos.x * rot.x - iPos.y * rot.y, iPos.x * rot.y + iPos.y * rot.x);

    // Update coordinates from [-1;1] to [0;1]
    rotated = (rotated + 1.0) * 0.5;

    // Setup position, rotation, scale as [-1;1] coordinates
    gl_Position = vec4((position + (rotated * size)) * 2.0 - 1.0, 0.0, 1.0);

    // Update coordinates from [-1;1] to [0;1]
    oPos = (iPos + 1.0) * 0.5;

    // Apply flip
    oPos.x = (1.0 - flip.x) * oPos.x + (1.0 - oPos.x) * flip.x;
    oPos.y = (1.0 - flip.y) * oPos.y + (1.0 - oPos.y) * flip.y;

    // Apply clip
    oPos.x = oPos.x * clip.z + (1.0 - oPos.x) * clip.x;
    oPos.y = oPos.y * clip.w + (1.0 - oPos.y) * clip.y;
}