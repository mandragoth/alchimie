#type vert
#version 400 core

layout(location = 0) in vec2 a_Position;
layout(location = 1) in vec2 a_TexCoords;

out vec2 v_TexCoords;

uniform mat4 u_CamMatrix;
uniform mat4 u_Transform;
uniform vec4 u_Clip;
uniform vec2 u_Flip;

void main() {
    // Set texture coordinates
    v_TexCoords = a_TexCoords;

    // Apply flip
    v_TexCoords.x = (1.0 - u_Flip.x) * v_TexCoords.x + (1.0 - v_TexCoords.x) * u_Flip.x;
    v_TexCoords.y = (1.0 - u_Flip.y) * v_TexCoords.y + (1.0 - v_TexCoords.y) * u_Flip.y;

    // Apply clip
    v_TexCoords.x = v_TexCoords.x * u_Clip.z + (1.0 - v_TexCoords.x) * u_Clip.x;
    v_TexCoords.y = (1.0 - v_TexCoords.y) * u_Clip.w + v_TexCoords.y * u_Clip.y;

    // Apply camera, transform model (p,r,s) to vertices
    gl_Position = u_CamMatrix * u_Transform * vec4(a_Position, 0.0, 1.0);
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoords;

uniform sampler2D u_Sprite0;
uniform vec4 u_Color;

void main() {
    fragColor = texture(u_Sprite0, v_TexCoords) * u_Color;
}
