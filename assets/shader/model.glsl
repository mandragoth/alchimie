#type vert
#version 400 core

layout (location = 0) in vec3 a_Position;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec3 a_Color;
layout (location = 3) in vec2 a_TexCoords;
layout (location = 4) in mat4 a_InstanceTransform;

out vec3 v_Position;
out vec3 v_Normal;
out vec3 v_Color;
out vec2 v_TexCoords;

uniform mat4 u_CamMatrix;
uniform mat4 u_Transform;

void main() {
    v_Position = vec3(a_InstanceTransform * u_Transform * vec4(a_Position, 1.0));
    v_Normal = a_Normal;
    v_Color = a_Color;
    v_TexCoords = a_TexCoords;

    gl_Position = u_CamMatrix * vec4(v_Position, 1.0);
}

#type frag
#version 400 core

out vec4 fragColor;

in vec3 v_Position;
in vec3 v_Normal;
in vec3 v_Color;
in vec2 v_TexCoords;
in vec4 v_LightPosition;

struct BaseLight {
    vec3 color;
    float ambientIntensity;
    float diffuseIntensity;
};

struct DirectionalLight {
    BaseLight base;
    vec3 direction;
};

struct Attenuation {
    float constant;
    float linear;
    float exp;
};

const int kMaxPointLights = 10;

struct PointLight {
    BaseLight base;
    Attenuation attenuation;
    vec3 position;
};

uniform sampler2D diffuse0;
uniform sampler2D specular0;
uniform sampler2D shadowMap;

uniform int lightType;
uniform vec4 lightColor;
uniform vec3 lightPos;
uniform vec3 u_CamPos;

uniform DirectionalLight u_DirectionalLight;
uniform PointLight u_PointLights[kMaxPointLights];
uniform int u_NbPointLights;

vec4 calcLightInternal(BaseLight light, vec3 lightDirection, vec3 normal) {
    // @TODO apply material ambient color
    vec4 ambientColor = vec4(light.color, 1.0) * light.ambientIntensity;

    float diffuseFactor = dot(normal, -lightDirection);

    vec4 diffuseColor = vec4(0.0);
    vec4 specularColor = vec4(0.0);
    
    if (diffuseFactor > 0.0) {
        // @TODO apply material diffuse color
        diffuseColor = vec4(light.color, 1.0) * light.diffuseIntensity * diffuseFactor;

        vec3 pixelToCamera = normalize(u_CamPos - v_Position);
        vec3 lightReflect = normalize(reflect(lightDirection, normal));

        float specularFactor = dot(pixelToCamera, lightReflect);
        if (specularFactor > 0.0) {
            float specularExponent = texture(specular0, v_TexCoords).r;
            specularFactor = pow(specularFactor, specularExponent);

            // @TODO apply material specular color
            specularColor = vec4(light.color, 1.0f) *
                            light.diffuseIntensity *
                            specularFactor;
        }
    }

    return ambientColor + diffuseColor + specularColor;
}

vec4 calcDirectionalLight(vec3 normal) {
    return calcLightInternal(u_DirectionalLight.base, u_DirectionalLight.direction, normal);
}

vec4 calcPointLight(int pointLightId, vec3 normal) {
    vec3 lightDirection = v_Position - u_PointLights[pointLightId].position;

    float distance = length(lightDirection);
    lightDirection = normalize(lightDirection);

    vec4 color = calcLightInternal(u_PointLights[pointLightId].base, lightDirection, normal);
    float attenuation = u_PointLights[pointLightId].attenuation.constant +
                        u_PointLights[pointLightId].attenuation.linear * distance + 
                        u_PointLights[pointLightId].attenuation.exp * distance * distance;

    return color / attenuation;
}

void main() {
    vec3 normal = normalize(v_Normal);
    vec4 totalLight = calcDirectionalLight(normal);

    for (int pointLightId = 0; pointLightId < u_NbPointLights; ++pointLightId) {
        totalLight += calcPointLight(pointLightId, normal);
    }

    fragColor = texture(diffuse0, v_TexCoords) * totalLight;
}