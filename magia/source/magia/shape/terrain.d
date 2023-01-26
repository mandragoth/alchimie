module magia.shape.terrain;

import bindbc.opengl;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

import std.math;
import std.stdio;
import std.random;

/// Instance of terrain
final class Terrain : Entity {
    private {
        Mesh _mesh;
        vec2 _gridPos;

        int   _nbOctaves;
        float _amplitude;
        float _roughness;
    }

    /// Constructor
    this(vec2 gridPos, vec2 size, int nbVertices, int tiling) {
        // @TODO parametrize
        _nbOctaves = 3;
        _amplitude = 70f;
        _roughness = 0.3f;

        transform = Transform.identity;
        transform.position.x = gridPos.x * size.x;
        transform.position.z = gridPos.y * size.y;

        Texture[] textures;
        textures ~= new Texture("grass.png", TextureType.diffuse, 0);
        textures ~= new Texture("sand.png", TextureType.diffuse, 1);
        textures ~= new Texture("flowers.png", TextureType.diffuse, 2);
        textures ~= new Texture("bricks.png", TextureType.diffuse, 3);
        textures ~= new Texture("blendmap.png", TextureType.diffuse, 4);

        const int count = nbVertices * nbVertices;
        Vertex[] vertices = new Vertex[count];

        const int nbRemaining  = nbVertices - 1;
        float fNbRemaining = cast(float)(nbRemaining); 

        int vertexIdx = 0;
        for (int x = 0; x < nbVertices; ++x) {
            for (int z = 0; z < nbVertices; ++z) {
                float fx = cast(float)(x); 
                float fz = cast(float)(z);

                // Vertices are mapped around xz plane
                vec3 vertex = vec3(fx / fNbRemaining * size.x, getHeight(x, z), fz / fNbRemaining * size.y);

                // Normal goes up along y axis
                vec3 normal = computeNormals(x, z);

                // Texture coordinates
                vec2 uvs = vec2(fx / fNbRemaining, fz / fNbRemaining) * tiling;

                // Pack it up (no color for now)
                vertices[vertexIdx] = Vertex(vertex, normal, vec3(0.0f, 0.0f, 0.0f), uvs);
                ++vertexIdx;
            }
        }

        const int count2 = nbRemaining * nbRemaining;
        GLuint[] indices = new uint[count2 * 6];

        // Counter-clockwise indice mapping 
        int indiceIdx = 0;
        for(int x = 0; x < nbRemaining; ++x) {
            for (int y = 0; y < nbRemaining; ++y) {
                const int topLeft     = x * nbVertices + y;
                const int topRight    = topLeft + 1;
                const int bottomLeft  = (x + 1) * nbVertices + y;
                const int bottomRight = bottomLeft + 1;

                // Left square triangle
                indices[indiceIdx++] = topLeft;
                indices[indiceIdx++] = bottomLeft;
                indices[indiceIdx++] = topRight;

                // Right square triangle
                indices[indiceIdx++] = topRight;
                indices[indiceIdx++] = bottomLeft;
                indices[indiceIdx++] = bottomRight;
            }
        }

        _mesh = new Mesh(vertices, indices, textures);
    }

    private vec3 computeNormals(int x, int z) {
        const float heightL = getHeight(x - 1, z);
        const float heightR = getHeight(x + 1, z);
        const float heightD = getHeight(x, z - 1);
        const float heightU = getHeight(x, z + 1);

        vec3 normal = vec3(heightL - heightR, 2f, heightD - heightU);
        return normal.normalized;
    }

    private float getHeight(int x, int z) {
        float height = 0f;
        const float d = pow(2, _nbOctaves - 1);

        for (int octaveIdx = 0; octaveIdx < _nbOctaves; ++octaveIdx) {
            const float frequency = pow(2, octaveIdx) / d;
            const float amplitude = pow(_roughness, octaveIdx) * _amplitude;
            height += getInterpolatedNoise(x * frequency, z * frequency) * amplitude;
        }

        return height;
    }

    private float getInterpolatedNoise(float x, float z) {
        int intX = cast(int)(x);
        int intZ = cast(int)(z);
        const float fracX = x - intX;
        const float fracZ = z - intZ;

        const float v1 = getSmoothNoise(intX, intZ);
        const float v2 = getSmoothNoise(intX + 1, intZ);
        const float v3 = getSmoothNoise(intX, intZ + 1);
        const float v4 = getSmoothNoise(intX + 1, intZ + 1);

        const float i1 = interpolate(v1, v2, fracX);
        const float i2 = interpolate(v3, v4, fracX);

        return interpolate(i1, i2, fracZ);
    }

    private float interpolate(float a, float b, float blend) {
        const double theta = blend * PI;
        float f = (1f - cos(theta)) * 0.5f;
        return a * (1f - f) + b * f;
    }

    private float getSmoothNoise(int x, int z) {
        const float corners = (noise(x - 1, z - 1) + noise(x + 1, z - 1) +
                               noise(x - 1, z + 1) + noise(x + 1, z + 1)) / 16f;

        const float sides = (noise(x - 1, z) + noise(x + 1, z) +
                             noise(x, z - 1) + noise(x, z + 1)) / 8f;

        const float middle = noise(x, z) / 4f;
        return corners + sides + middle;
    }

    /// Render the terrain
    void draw(Shader shader) {
        _mesh.draw(shader, transform);
    }
}