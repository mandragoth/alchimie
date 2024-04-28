module magia.shape.planet;

import bindbc.opengl;

import magia.core;

import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.shape.sphere;

import std.stdio;

/// Instance of sphere
final class Planet : Sphere {
    // Noise parameters
    private {
        vec3f _noiseOffset;
        int _nbLayers;
        float _strength;
        float _roughness;
        float _persistence;
        float _minHeight;
    }

    /// Constructor
    this(int resolution, float radius, vec3f noiseOffset, int nbLayers,
        float strength, float roughness, float persistence, float minHeight) {
        _noiseOffset = noiseOffset;
        _nbLayers = nbLayers;
        _strength = strength;
        _roughness = roughness;
        _persistence = persistence;
        _minHeight = minHeight;

        super(resolution, radius);
    }

    // Generate a point on the planet's surface
    protected override vec3f generateSurfacePoint(vec3f directionX, vec3f directionY, vec3f directionZ,
                                                 int x, int y, int resolution) {
        vec3f surfacePoint = super.generateSurfacePoint(directionX, directionY, directionZ, x, y, resolution);
        return surfacePoint * sampleRandomHeight(surfacePoint);
    }

    // Sample random height given a sphere surface point, several layers of noise
    private float sampleRandomHeight(vec3f point) {
        float noiseValue = 0;
        float frequency = 1;
        float amplitude = 1;

        for (int layerId = 0; layerId < _nbLayers; ++layerId) {
            noiseValue = getNoiseHeight(point * frequency + _noiseOffset);
            frequency *= _roughness;
            amplitude *= _persistence;
        }

        noiseValue = max(0, noiseValue - _minHeight);
        return noiseValue * _strength;
    }

    // Sample random height given a sphere surface point for a single noise layer
    private float getNoiseHeight(vec3f point) {
        const float elevation = noise(point.x, point.y, point.z) * _strength;
        return _radius * (1 + elevation);
    }
}