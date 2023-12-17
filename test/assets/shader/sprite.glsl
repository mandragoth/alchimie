#type vert
#version 400 core

layout(location = 0) in vec2 a_Position;
layout(location = 1) in uint a_SpriteId;

#define MAX_SPRITES 5000

uniform SpriteInfo {
    vec2 position[MAX_SPRITES];
    vec2 size[MAX_SPRITES];
    vec2 texCoords[MAX_SPRITES];
    vec2 texSize[MAX_SPRITES];
};

out vec2 v_TexCoords;

void main() {
    // Calculate position
    vec3 position = vec3(position[a_SpriteId], 0.5);

    // Calculate size
    vec2 size = a_Position * size[a_SpriteId];

    // Adjust position
    vec3 newPosition = position + vec3(size, 0.0);

    // Finalize position
    gl_Position = vec4(newPosition, 1.0);

    // Calculate texture coordinates
    vec2 texCoords = texCoords[a_SpriteId];

    // Calculate texture size
    vec2 texSize = a_Position * texSize[a_SpriteId];

    // Finalize texture coordinates
    v_TexCoords = texCoords + texSize;
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

in vec2 v_TexCoords;

uniform sampler2D u_Sprite0;
uniform vec4 u_Color;

void main() {
    fragColor = texture2D(u_Sprite0, v_TexCoords) * u_Color;
}