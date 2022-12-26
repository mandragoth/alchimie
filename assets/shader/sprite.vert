#version 400

in vec2 iPos;
out vec2 oPos;

uniform vec4 clip;
uniform vec2 flip;
uniform mat4 model;

void main() {
    // Update coordinates from [-1;1] to [0;1]
    oPos = (iPos + 1.0) * 0.5;

    // Apply flip
    oPos.x = (1.0 - flip.x) * oPos.x + (1.0 - oPos.x) * flip.x;
    oPos.y = (1.0 - flip.y) * oPos.y + (1.0 - oPos.y) * flip.y;

    // Apply clip
    oPos.x = oPos.x * clip.z + (1.0 - oPos.x) * clip.x;
    oPos.y = (1.0 - oPos.y) * clip.w + oPos.y * clip.y;

    // Apply model (p,r,s) to vertices
    gl_Position = model * vec4(iPos, 0.0, 1.0);
}