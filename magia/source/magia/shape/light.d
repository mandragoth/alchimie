module magia.shape.light;

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

/// Instance of light
final class Light : Entity {
    private {
        Mesh _mesh;
        Shader _shader;
        Color _color;
        LightType _lightType;
    }

    @property {
        /// Gets color
        Color color() {
            return _color;
        }
    }

    /// Constructor
    this(LightType lightType) {
        _lightType = lightType;

        // Quad light vertices
        Vertex[] vertices = [
            //  COORDINATES
            Vertex(vec3(-0.01f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f, -0.01f)),
            Vertex(vec3( 0.1f,  0.1f, -0.01f)),
            Vertex(vec3( 0.1f,  0.1f,  0.1f))
        ];

        // Quad light indices
        GLuint[] indices = [
            0, 1, 2,
            0, 2, 3,
            0, 4, 7,
            0, 7, 3,
            3, 7, 6,
            3, 6, 2,
            2, 6, 5,
            2, 5, 1,
            1, 5, 4,
            1, 4, 0,
            4, 5, 6,
            4, 6, 7
        ];

        // @TODO cache mesh (quad from resource cache)
        _mesh = new Mesh(vertices, indices);
        _shader = fetchPrototype!Shader("light");
        _color = Color.white;
    }

    /// Setup light casting and receiving shaders
    void setupShaders(Shader materialShader) {
        vec4 lightColor = vec4(_color.r, color.g, color.b, 1.0f);

        _shader.activate();
        _shader.uploadUniformVec4("lightColor", lightColor);

        materialShader.activate();
        materialShader.uploadUniformInt("lightType", _lightType);
        materialShader.uploadUniformVec3("lightPos", position);
        materialShader.uploadUniformVec4("lightColor", lightColor);
    }

    /// Render the light object (for debug)
    override void draw() {
        _mesh.draw(_shader, transform);
    }
}