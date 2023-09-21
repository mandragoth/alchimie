#type vert
#version 400 core

layout (location = 0) in vec3 a_Position;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec3 a_Color;
layout (location = 3) in vec2 a_TexCoords;
layout (location = 4) in ivec4 a_BoneIDs;
layout (location = 5) in vec4 a_Weights;

// @TODO add a_InstanceTransform back (to layout)
// layout (location = x) in mat4 a_InstanceTransform;
// vertex code line 1: v_Position = vec3(a_InstanceTransform * u_Transform * vec4(a_Position, 1.0));

out vec3 v_Position;
out vec3 v_Normal;
out vec3 v_Color;
out vec2 v_TexCoords;

uniform mat4 u_CamMatrix;
uniform mat4 u_Transform;

void main() {
    /// Apply transformation matrix
    v_Position = vec3(u_Transform * vec4(a_Position, 1.0));
    v_Normal = a_Normal;
    v_Color = a_Color;
    v_TexCoords = a_TexCoords;

    /// Apply camera matrix
    gl_Position = u_CamMatrix * vec4(v_Position, 1.0);
}

#type frag
#version 400 core

layout(location = 0) out vec4 fragColor;

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
const int kMaxSpotLights = 10;

struct PointLight {
    BaseLight base;
    Attenuation attenuation;
    vec3 position;
};

struct SpotLight {
    PointLight base;
    vec3 direction;
    float cutoff;
};

uniform sampler2D u_Diffuse0;
uniform sampler2D u_Specular0;
uniform vec3 u_CamPos;

uniform DirectionalLight u_DirectionalLight;

uniform PointLight u_PointLights[kMaxPointLights];
uniform int u_NbPointLights;

uniform SpotLight u_SpotLights[kMaxSpotLights];
uniform int u_NbSpotLights;

uniform int u_DisplayBoneId;
uniform bool u_DebugBones;

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
            float specularExponent = texture(u_Specular0, v_TexCoords).r;
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

vec4 calcPointLight(PointLight pointLight, vec3 normal) {
    vec3 lightDirection = v_Position - pointLight.position;

    float distance = length(lightDirection);
    lightDirection = normalize(lightDirection);

    vec4 color = calcLightInternal(pointLight.base, lightDirection, normal);
    float attenuation = pointLight.attenuation.constant +
                        pointLight.attenuation.linear * distance + 
                        pointLight.attenuation.exp * distance * distance;

    return color / attenuation;
}

vec4 calcSpotLight(SpotLight spotLight, vec3 normal) {
    vec3 lightToPixel = normalize(v_Position - spotLight.base.position);

    float spotFactor = dot(lightToPixel, normalize(spotLight.direction));

    if (spotFactor > spotLight.cutoff) {
        vec4 color = calcPointLight(spotLight.base, normal);
        float intensity = 1.0 - (1.0 - spotFactor) / (1.0 - spotLight.cutoff);
        return color * intensity;
    }

    return vec4(0.0);
}

void main() {
    vec3 normal = normalize(v_Normal);
    vec4 totalLight = calcDirectionalLight(normal);

    for (int pointLightId = 0; pointLightId < u_NbPointLights; ++pointLightId) {
        totalLight += calcPointLight(u_PointLights[pointLightId], normal);
    }

    for (int spotLightId = 0; spotLightId < u_NbSpotLights; ++spotLightId) {
        totalLight += calcSpotLight(u_SpotLights[spotLightId], normal);
    }

    fragColor = texture(u_Diffuse0, v_TexCoords) * totalLight;
}