module magia.render.skybox;

import std.stdio;
import std.string;
import std.conv;

import bindbc.opengl;

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.entity;
import magia.render.postprocess;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling skybox data and draw call
final class Skybox : Entity {
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

        Texture _texture;
        
        VertexArray _vertexArray;
        IndexBuffer _indexBuffer;
    }

    @property {
        /// Get skybox shader
        Shader shader() {
            return material.shaders[0];
        }
    }

    // @TODO skybox resource cache?
    // @TODO use new layout architecture

    /// Constructor
    this() {
        material.shaders ~= fetchPrototype!Shader("skybox");

        string[6] faceCubemaps = [
            "night/right.png", "night/left.png", "night/top.png",
            "night/bottom.png", "night/front.png", "night/back.png"
        ];

        _texture = new Texture(faceCubemaps);
        shader.uploadUniformInt("u_Skybox", 0);

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
    override void draw() {
        glDepthFunc(GL_LEQUAL);

        setupShader();
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, null);

        glDepthFunc(GL_LESS);
    }

    /// Setup shader for draw call
    private void setupShader() {
        _vertexArray.bind();
        _texture.bind();
        shader.activate();

        Camera camera = renderer.camera;
        shader.uploadUniformMat4("u_View", mat4(mat3(camera.view)));
        shader.uploadUniformMat4("u_Projection", camera.projection);
        shader.uploadUniformFloat("u_Gamma", gamma);
    }
}
