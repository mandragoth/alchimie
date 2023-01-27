module magia.render.light;

import std.conv;
import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render;

/// Type of instantiated light
enum LightType {
    DIRECTIONAL,
    POINT,
    SPOT
}

/// Base light representation
struct BaseLight {
    /// Color of the light
    Color color = Color.white;

    /// Intensity applying to ambient scene receiving the light
    float ambientIntensity = 1f;

    /// Intensity applying to diffuse textures receiving the light
    float diffuseIntensity = 0f;
}

/// Directional light representation
class DirectionalLight {
    /// Base light
    BaseLight base;

    /// Direction of the light
    vec3 direction;

    @property {
        /// Wrapping getter
        Color color() {
            return base.color;
        }

        /// Wrapping setter
        void color(Color color) {
            base.color = color;
        }

        /// Wrapping getter
        float ambientIntensity() {
            return base.ambientIntensity;
        }

        /// Wrapping setter
        void ambientIntensity(float intensity) {
            base.ambientIntensity = intensity;
        }

        /// Wrapping getter
        float diffuseIntensity() {
            return base.diffuseIntensity;
        }

        /// Wrapping setter
        void diffuseIntensity(float intensity) {
            base.diffuseIntensity = intensity;
        }
    }

    /// Debug
    void print() {
        writeln("Base", base);
        writeln("Direction", direction);
    }
}

/// Representation of a generic light atternuation
struct LightAttenuation {
    /// Constant factor (always applies)
    float constant = 1f;

    /// Linear factor (scaling with distance)
    float linear = 0f;

    /// Exponential factor (scaling with squared distance)
    float exp = 0f;
}

/// Point light representation
class PointLight : Instance {
    /// Base light
    BaseLight base;

    /// Attenuation factors
    LightAttenuation attenuation;

    @property {
        /// Wrapping getter
        Color color() {
            return base.color;
        }

        /// Wrapping setter
        void color(Color color) {
            base.color = color;
        }

        /// Wrapping getter
        float ambientIntensity() {
            return base.ambientIntensity;
        }

        /// Wrapping setter
        void ambientIntensity(float intensity) {
            base.ambientIntensity = intensity;
        }

        /// Wrapping getter
        float diffuseIntensity() {
            return base.diffuseIntensity;
        }

        /// Wrapping setter
        void diffuseIntensity(float intensity) {
            base.diffuseIntensity = intensity;
        }

        /// Wrapping getter
        float constant() {
            return attenuation.constant;
        }

        /// Wrapping getter
        float linear() {
            return attenuation.linear;
        }

        /// Wrapping getter
        float exp() {
            return attenuation.exp;
        }
    }

    /// Print data
    void printData() {
        writeln(base);
        writeln(attenuation);
        writeln(position);
    }
}

/// Lighting manager (handles all lights)
class LightingManager {
    private {
        static const uint kMaxPointLights = 10;

        DirectionalLight _directionalLight;
        PointLight[] _pointLights;
    }

    @property {
        /// Set directional light in the scene
        void directionalLight(DirectionalLight directionalLight_) {
            _directionalLight = directionalLight_;
        }
    }

    /// Add a point light to the scene
    void addPointLight(PointLight pointLight) {
        if(_pointLights.length < kMaxPointLights) {
            _pointLights = _pointLights ~ pointLight;
        } else {
            throw new Exception("Cannot add any more point light, maximum internally set to " ~ kMaxPointLights);
        }
    }

    /// Setup lighting in shader
    void setupInShader(Shader shader) {
        shader.activate();

        // Setup directional light data
        if (_directionalLight) {
            shader.uploadUniformVec3("u_DirectionalLight.direction", _directionalLight.direction);
            shader.uploadUniformVec3("u_DirectionalLight.base.color", _directionalLight.color.rgb);
            shader.uploadUniformFloat("u_DirectionalLight.base.ambientIntensity", _directionalLight.ambientIntensity);
            shader.uploadUniformFloat("u_DirectionalLight.base.diffuseIntensity", _directionalLight.diffuseIntensity);
        }

        // Setup point light data
        const int nbPointLights = cast(int)_pointLights.length;
        shader.uploadUniformInt("u_NbPointLights", nbPointLights);
        for (int pointLightId = 0; pointLightId < nbPointLights; ++pointLightId) {
            PointLight pointLight = _pointLights[pointLightId];

            string uniformName = "u_PointLights[" ~ to!string(pointLightId) ~ "]";
            shader.uploadUniformVec3(toStringz(uniformName ~ ".position"), pointLight.position);

            string baseUniformName = uniformName ~ ".base";
            shader.uploadUniformVec3(toStringz(baseUniformName ~ ".color"), pointLight.color.rgb);
            shader.uploadUniformFloat(toStringz(baseUniformName ~ ".ambientIntensity"), pointLight.ambientIntensity);
            shader.uploadUniformFloat(toStringz(baseUniformName ~ ".diffuseIntensity"), pointLight.diffuseIntensity);

            string attenuationUniformName = uniformName ~ ".attenuation";
            shader.uploadUniformFloat(toStringz(attenuationUniformName ~ ".constant"), pointLight.constant);
            shader.uploadUniformFloat(toStringz(attenuationUniformName ~ ".linear"), pointLight.linear);
            shader.uploadUniformFloat(toStringz(attenuationUniformName ~ ".exp"), pointLight.exp);
        }
    }
}