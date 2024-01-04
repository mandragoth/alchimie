#type vert
#version 400 core

// Per vertex data
layout(location = 0) in vec2 a_Position;
layout(location = 1) in vec2 a_TexCoords;

// Per instance data
layout(location = 2) in mat4 a_Transform;
layout(location = 6) in vec4 a_Clip;
layout(location = 7) in vec4 a_Color;

out vec4 v_Color;
out vec2 v_TexCoords;

uniform mat4 u_CamMatrix;

void main() {
    // Set color
    v_Color = a_Color;

    // Set texture coordinates
    v_TexCoords = a_TexCoords;

    // Apply clip
    v_TexCoords.x = v_TexCoords.x * a_Clip.z + (1.0 - v_TexCoords.x) * a_Clip.x;
    v_TexCoords.y = (1.0 - v_TexCoords.y) * a_Clip.w + v_TexCoords.y * a_Clip.y;

    // Apply camera, transform model (p,r,s) to vertices
    gl_Position = u_CamMatrix * a_Transform * vec4(a_Position, 0.0, 1.0);
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

in vec4 v_Color;
in vec2 v_TexCoords;

uniform sampler2D u_Sprite0;

void main() {
    fragColor = texture(u_Sprite0, v_TexCoords) * v_Color;
}