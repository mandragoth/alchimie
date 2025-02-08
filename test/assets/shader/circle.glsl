#type vert
#version 460 core

// Per vertex data
layout(location = 0) in vec2 a_Position;
layout(location = 1) in vec2 a_TexCoords;

// Per instance data
layout(location = 2) in mat4 a_Transform;
layout(location = 6) in vec4 a_Clip;
layout(location = 7) in vec4 a_Color;

out vec4 v_Color;
out vec2 v_TexCoords;
out float v_Size;

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

    // Forward position to fragment shader
    v_Size = a_Clip.w;
}

#type frag
#version 460 core

layout(location = 0) out vec4 fragColor;

// Per vertex data
in vec4 v_Color;
in vec2 v_TexCoords;
in float v_Size;

uniform sampler2D u_Sprite0;

vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
    float d = length(pos - uv) - rad + 1;
    float t = clamp(d, 0.0, 1.0);
    return vec4(color, 1.0 - t);
}

vec3 rgb(float r, float g, float b) {
    return vec3(r / 255.0, g / 255.0, b / 255.0);
}

void main() {
    vec2 center = v_Size * vec2(0.5, 0.5);
    float radius = v_Size * 0.5;
    vec3 color = vec3(v_Color.r, v_Color.g, v_Color.b);
    fragColor = circle(v_TexCoords, center, radius, color);
}