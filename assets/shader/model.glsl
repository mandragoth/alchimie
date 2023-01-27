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
out vec4 v_LightPosition; // Used for shadows

uniform mat4 u_CamMatrix;
uniform mat4 u_Transform;
uniform mat4 a_LightProjection; // Used for shadows

void main() {
    v_Position = vec3(a_InstanceTransform * u_Transform * vec4(a_Position, 1.0));
    v_Normal = a_Normal;
    v_Color = a_Color;
    v_TexCoords = a_TexCoords;
    v_LightPosition = a_LightProjection * vec4(v_Position, 1.0);

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

uniform sampler2D diffuse0;
uniform sampler2D specular0;
uniform sampler2D shadowMap;

uniform int lightType;
uniform vec4 lightColor;
uniform vec3 lightPos;
uniform vec3 u_CamPos;

vec4 pointLight() {
    // Intensity
    vec3 lightVector = lightPos - v_Position;
    float lightDistance = length(lightVector);
    float a = 3.0f;
    float b = 0.7f;
    float intensity = 1.0f / (a * lightDistance * lightDistance + b * lightDistance + 1.0f);

    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(v_Normal);
    vec3 lightDirection = normalize(lightVector);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
	if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(u_CamPos - v_Position);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        float specular = specAmount * 0.50f;
    }

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, v_TexCoords) * (diffuse * intensity + ambient) + texture(specular0, v_TexCoords).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 directionalLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(v_Normal);
    vec3 lightDirection = normalize(lightPos);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
    if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(u_CamPos - v_Position);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        specular = specAmount * 0.50f;
    }

    // Discard alpha
    if (texture(diffuse0, v_TexCoords).a < 0.1f) {
        discard;
    }

    float shadow = 0.0f;
    vec3 lightCoords = v_LightPosition.xyz / v_LightPosition.w;

    if (lightCoords.z <= 1.0f) {
        lightCoords = (lightCoords + 1.0f) / 2.0f;

        float closestDepth = texture(shadowMap, lightCoords.xy).r;
        float currentDepth = lightCoords.z;

        float bias = max(0.025f * (1.0f - dot(normal, lightDirection)), 0.0005f);

        int sampleRadius = 2;
        vec2 pixelSize = 1.0 / textureSize(shadowMap, 0);
        for(int y = -sampleRadius; y <= sampleRadius; y++) {
            for(int x = -sampleRadius; x <= sampleRadius; x++) {
                float closestDepth = texture(shadowMap, lightCoords.xy + vec2(x, y) * pixelSize).r;
                if (currentDepth > closestDepth + bias) {
                    shadow += 1.0f;
                }
            }
        }

        shadow /= pow((sampleRadius * 2 + 1), 2);
    }

    float noShadow = 1.0f - shadow;

    // Combining lightings, keeping alpha
    vec4 baseColor = vec4(v_Color, 1.0f);
    vec4 lightColor = baseColor * (texture(diffuse0, v_TexCoords) * (diffuse * noShadow + ambient) + texture(specular0, v_TexCoords).r * specular * noShadow) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 spotLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(v_Normal);
    vec3 lightDirection = normalize(lightPos - v_Position);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
	if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(u_CamPos - v_Position);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        float specular = specAmount * 0.50f;
    }

    // Cone angle
    float outerCone = 0.90f; // ~25 degrees
    float innerCone = 0.95f; // ~18 degrees
    float angle = dot(vec3(0.0f, -1.0f, 0.0f), -lightDirection);
    float intensity = clamp((angle - outerCone) / (innerCone - outerCone), 0.0f, 1.0f);

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, v_TexCoords) * (diffuse * intensity + ambient) + texture(specular0, v_TexCoords).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

float near = 0.1f;
float far = 100.0f;

float linearizeDepth(float depth) {
	return (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
}

float logisticDepth(float depth, float steepness, float offset) {
	float zValue = linearizeDepth(depth);
	return (1.0 / (1.0 + exp(-steepness * (zValue - offset))));
}

// Fog
// float depth = logisticDepth(gl_FragCoord.z, 0.5, 5.0);
// fragColor = directionalLight() * (1.0 - depth) + vec4(depth * vec3(0.85, 0.85, 0.90), 1.0);

void main() {
    if (lightType == 0) {
        fragColor = directionalLight();
    } else if (lightType == 1) {
        fragColor = pointLight();
    } else if (lightType == 2) {
        fragColor = spotLight();
    }
}