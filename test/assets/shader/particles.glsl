#type vert
#version 460 core

layout (location = 0) in vec4 a_Position;
layout (location = 1) in vec4 a_Color;

out vec4 v_Color;
out vec2 v_Center;
out float v_Radius;

uniform mat4 u_CamMatrix;

void main() {
    gl_Position = u_CamMatrix * vec4(a_Position.xy, 0.0, 1.0);
    gl_PointSize = 10.0;
    v_Color = a_Color;
    v_Center = (gl_Position.xy / gl_Position.w * 0.5 + 0.5);
    v_Radius = gl_PointSize;
}

#type frag
#version 460 core

layout(location = 0) out vec4 fragColor;

in vec4 v_Color;
in vec2 v_Center;
in float v_Radius;

void main() {
    vec2 viewport = vec2(800.0, 600.0);
    vec2 uv = (gl_FragCoord.xy / viewport - v_Center) / (v_Radius / viewport) + 0.5;

    vec2 circCoord = 2.0 * uv - 1.0;
    if (dot(circCoord, circCoord) > 1.0) {
        discard;
    }

    //fragColor = vec4(uv, 0.0, 1.0);
    fragColor = v_Color;
}

#type comp
#version 460 core

layout(local_size_x = 1) in;

struct ParticleData {
    vec4 position;
    vec4 color;
    vec2 speed;
    float density;
    float padding;
};

layout(std430, binding = 0) buffer pos {
    ParticleData particleData[];
};

const float PI = 3.1415926535897932384626433832795;
const float deltaTime = 0.016;
const float mass = 1.0;
const float targetDensity = 2.75f;
const float pressureMultiplier = 100.0;
const float smoothingRadius = 1.2;

float smoothingKernel(float radius, float distance) {
    if (distance >= radius) {
        return 0f;
    }

    float radius4 = radius * radius * radius;
    float volume = (PI * radius4 / 6.0);
    return (radius - distance) * (radius - distance) / volume;
}

float smoothingKernelDerivative(float radius, float distance) {
    if (distance >= radius) {
        return 0f;
    }

    float radius4 = radius * radius * radius;
    float rate = 12f / (PI * radius4);
    return (distance - radius) * rate;
}

float densityToPressure(float density) {
    float densityError = density - targetDensity;
    float pressure = densityError * pressureMultiplier;
    return pressure;
}

float computeSharedPressure(float density1, float density2) {
    float pressure1 = densityToPressure(density1);
    float pressure2 = densityToPressure(density2);
    return (pressure1 + pressure2) / 2.0;
}

float computePressureForce(uint i) {
    vec2 samplePoint = particleData[i].position.xy;

    float pressureForce = 0.0;
    for (uint j = 0; j < particleData.length(); ++j) {
        if (i == j) {
            continue;
        }

        vec2 otherPoint = particleData[j].position.xy;
        vec2 towards = otherPoint - samplePoint;
        float distance = length(towards);

        vec2 direction = vec2(0.0, 0.0);
        if (distance != 0) {
            direction = towards / distance;
        }

        float slope = smoothingKernelDerivative(smoothingRadius, distance / 100.0);
        float density = particleData[i].density;
        float sharedPressure = computeSharedPressure(density, particleData[j].density);

        if (density != 0) {
            pressureForce += sharedPressure * direction * slope * mass / density;
        }
    }

    return pressureForce;
}

float computeDensity(uint i) {
    vec2 samplePoint = particleData[i].position.xy;

    float mass = 1.0;

    // @TODO optimize this pass to only look at neighborhood
    float density = 0.0;
    for (uint j = 0; j < particleData.length(); ++j) {
        vec2 otherPoint = particleData[j].position.xy;
        vec2 towards = otherPoint - samplePoint;
        float distance = length(towards);

        float influence = smoothingKernel(smoothingRadius, distance / 100.0);
        density += mass * influence;
    }

    return density;
}

void applyPressure(uint i) {
    particleData[i].density = computeDensity(i);

    float pressureForce = computePressureForce(i);
    float pressureAcceleration = pressureForce / particleData[i].density;

    particleData[i].speed.xy += pressureAcceleration * deltaTime;
}

void applyGravity(uint i) {
    particleData[i].speed.xy += vec2(0.0, -1.0) * 9.8 * deltaTime;
}

void applyPhysics(uint i) {
    vec2 speed2D    = particleData[i].speed.xy;
    vec2 position2D = particleData[i].position.xy + speed2D;

    float circleSize = 10.0;
    float left = -400.0;
    float right = 400.0;
    float up = 300.0;
    float down = -300.0;

    float collisionDown  = down + circleSize / 2.0;

    float drag = 0.8;

    if (position2D.y < collisionDown) {
        position2D.y = collisionDown;
        speed2D.y *= -1 * drag;
    }

    particleData[i].position.xy = position2D;
    particleData[i].speed.xy = speed2D;
}

void applyForce(uint i) {
    applyGravity(i);
    applyPressure(i);
    applyPhysics(i);
}

void main() {
    uint i = gl_GlobalInvocationID.x;
    applyForce(i);

    //vec3 p = particleData[idx].position.xyz;
    //p += vec3(0.001);
    //particleData[idx].position.xyz = p;

    //particleData[idx].color.rgb = vec3(1.0, 0.0, 0.0);
}