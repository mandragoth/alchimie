module magia.render.skybox;

import std.stdio;
import std.string;
import std.conv;

import bindbc.opengl;

import magia.render.array;
import magia.render.buffer;
import magia.render.postprocess;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling skybox data and draw call
final class Skybox {
    private {
        // dfmt off
        /// Vertices
        float[] _vertices = [
            // Coordinates
            -1.0f, -1.0f,  1.0f,   //      7---------6
             1.0f, -1.0f,  1.0f,   //     /|        /|
             1.0f, -1.0f, -1.0f,   //    4---------5 |
            -1.0f, -1.0f, -1.0f,   //    | |       | |
            -1.0f,  1.0f,  1.0f,   //    | 3-------|-2
             1.0f,  1.0f,  1.0f,   //    |/        |/
             1.0f,  1.0f, -1.0f,   //    0---------1
            -1.0f,  1.0f, -1.0f    //
        ];

        /// Indices
        GLuint[] _indices = [
            // Right
            6, 5, 1,
            1, 2, 6,
            // Left
            0, 4, 7,
            7, 3, 0,
            // Top
            4, 5, 6,
            6, 7, 4,
            // Bottom
            0, 3, 2,
            2, 1, 0,
            // Back
            0, 1, 5,
            5, 4, 0,
            // Front
            3, 7, 6,
            6, 2, 3 
        ];
        // dfmt on

        Shader _shader;
        Texture _texture;
        
        VertexArray _vertexArray;
        IndexBuffer _indexBuffer;
    }

    @property {
        /// Get skybox shader
        Shader shader() {
            return _shader;
        }
    }

    /// Constructor
    this() {
        _shader = new Shader("skybox.vert", "skybox.frag");

        string[6] faceCubemaps = [
            "night/right.png", "night/left.png", "night/top.png",
            "night/bottom.png", "night/front.png", "night/back.png"
        ];

        _texture = new Texture(faceCubemaps);
        _shader.uploadUniformInt(toStringz(to!string(_texture.type)), 0);

        // Generate and bind VAO
        _vertexArray = new VertexArray();
        _vertexArray.bind();

        // Generate and bind VBO, EBO
        VertexBuffer vertexBuffer = new VertexBuffer(_vertices);
        _indexBuffer = new IndexBuffer(_indices);

        // Link VBO attributes
        _vertexArray.linkAttributes(vertexBuffer, 0, 3, GL_FLOAT, 3 * float.sizeof, null);

        // Unbind all objects
        VertexArray.unbind();
        VertexBuffer.unbind();
        IndexBuffer.unbind();
    }

    /// Draw call
    void draw() {
        glDepthFunc(GL_LEQUAL);

        _vertexArray.bind();
        _texture.bind();
        _shader.activate();
        _shader.uploadUniformFloat("gamma", gamma);
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, null);

        glDepthFunc(GL_LESS);
    }
}
