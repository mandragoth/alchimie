module magia.shape.sphere;

import bindbc.opengl;

import magia.core;
import magia.render;

import std.stdio;

/// Instance of sphere
class Sphere : Instance3D, Drawable3D {
    protected {
        Mesh3D[] _meshes;

        // Sphere parameters
        int   _resolution;
        float _radius;

        // Debug params
        bool _debug;
    }

    /// Constructor
    this(int resolution, float radius) {
        transform = Transform3D.identity;

        _resolution = resolution;
        _radius = radius;

        vec3f[] directions = [vec3f.up, vec3f.down, vec3f.left, vec3f.right, vec3f.forward, vec3f.back];

        for (int directionIdx = 0; directionIdx < directions.length; ++directionIdx) {
            generateFaceMesh(directions[directionIdx]);
        }
    }

    private void generateFaceMesh(vec3f directionY) {
        vec3f directionX = vec3f(directionY.y, directionY.z, directionY.x);
        vec3f directionZ = directionX.cross(directionY);

        const int nbVertices = _resolution * _resolution;
        Vertex[] vertices = new Vertex[nbVertices];

        int resolution2 = _resolution - 1;
        float fResolution2 = cast(float)(resolution2); 

        const int nbIndices = resolution2 * resolution2 * 6;
        GLuint[] indices = new uint[nbIndices];

        int indiceIdx = 0;
        for (int y = 0; y < _resolution; ++y) {
            for (int x = 0; x < _resolution; ++x) {
                float fx = cast(float)(x); 
                float fy = cast(float)(y);

                int vertexIdx = getVertexIdx(x, y);

                vertices[vertexIdx].position = generateSurfacePoint(directionX, directionY, directionZ, x, y, resolution2);
                vertices[vertexIdx].texUV = vec2f(fx / fResolution2, fy / fResolution2);
                vertices[vertexIdx].color = Color.red;
                vertices[vertexIdx].normal = computeNormal(vertices[vertexIdx].position);

                if (x != resolution2 && y != resolution2) {
                    // Map first triangle
                    indices[indiceIdx]     = vertexIdx;
                    indices[indiceIdx + 1] = vertexIdx + _resolution + 1;
                    indices[indiceIdx + 2] = vertexIdx + _resolution;

                    // Map second triangle
                    indices[indiceIdx + 3] = vertexIdx;
                    indices[indiceIdx + 4] = vertexIdx + 1;
                    indices[indiceIdx + 5] = vertexIdx + _resolution + 1;

                    // Increment indices counter
                    indiceIdx += 6;
                }
            }
        }

        _meshes ~= new Mesh3D(new VertexBuffer(vertices, layout3D), new IndexBuffer(indices));
    }

    /// Generate a point on the sphere's surface
    protected vec3f generateSurfacePoint(vec3f directionX, vec3f directionY, vec3f directionZ,
                                        int x, int y, int resolution) {
        const vec2f ratio = vec2f(x, y) / resolution;
        const vec2f ratioScale = (ratio - vec2f(0.5f, 0.5f)) * 2;

        vec3f surfacePoint = directionY + ratioScale.x * directionX + ratioScale.y * directionZ;
        return surfacePoint.normalized;
    }

    /// Get vertex id for position (x, y)
    protected int getVertexIdx(int x, int y) {
        return x + y * _resolution;
    }

    // Compute normals 
    private vec3f computeNormal(vec3f surfacePoint) {
        const vec3f center = transform.position;

        vec3f normal = surfacePoint - center;
        normal.normalize();

        /*if (_debug) {
            addLine(new Line(surfacePoint, surfacePoint + normal * _radius / 100, vec3f(0., 1., 0.)));
        }*/

        return normal;
    }

    /// Render the sphere
    void draw(Renderer3D renderer) {
        /// @TODO fetch real position in renderer space
        foreach(Mesh3D mesh; _meshes) {
            mesh.draw(modelShader, [defaultTexture], globalModel);
        }
    }
}