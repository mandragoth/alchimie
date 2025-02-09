#type vert
#version 460 core

layout (location = 0) in vec3 a_Position;

//uniform mat4 u_CamMatrix;

void main() {
    gl_Position = vec4(a_Position, 1.0);
}

#type frag
#version 460 core

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}

#type comp
#version 460 core

layout(local_size_x = 1) in;

layout(std430, binding = 0) buffer Pos {
    vec4 Position[];
};

void main() {
    uint idx = gl_GlobalInvocationID.x;

    vec3 p = Position[idx].xyz;
    p += vec3(0.001);

    Position[idx].xyz = p;
}