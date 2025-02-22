#type vert
#version 460 core

layout (location = 0) in vec4 a_Position;
layout (location = 1) in vec4 a_Color;

out vec4 v_Color;

uniform mat4 u_CamMatrix;

void main() {
    gl_Position = u_CamMatrix * a_Position;
    v_Color = a_Color;
}

#type frag
#version 460 core

layout(location = 0) out vec4 fragColor;

in vec4 v_Color;

void main() {
    fragColor = v_Color;
}

#type comp
#version 460 core

layout(local_size_x = 1) in;

struct ParticleData {
    vec4 position;
    vec4 color;
};

layout(std430, binding = 0) buffer pos {
    ParticleData particleData[];
};

void main() {
    uint idx = gl_GlobalInvocationID.x;

    //vec3 p = particleData[idx].position.xyz;
    //p += vec3(0.001);
    //particleData[idx].position.xyz = p;

    particleData[idx].color.rgb = vec3(1.0, 0.0, 0.0);
}