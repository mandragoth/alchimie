#type vert
#version 400 core

layout(location = 0) in vec3 a_Position;

uniform mat4 u_CamMatrix;

void main() {
    // Apply camera transformation
    gl_Position = u_CamMatrix * vec4(a_Position, 1.0);
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

uniform vec4 u_Color;

void main() {
    // Set line color
    fragColor = u_Color;
}

// @TODO check if line rendering is doable with quad.glsl