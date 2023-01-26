module magia.render.mesh;

import std.conv;
import std.stdio;
import std.string;

import bindbc.opengl;

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.texture;
import magia.render.scene;
import magia.render.shader;
import magia.render.vertex;

/// Class handling mesh data and draw call
final class Mesh {
    private {
        Vertex[] _vertices;
        uint[] _indices;
        Texture[] _textures;

        VertexArray _vertexArray;
        VertexBuffer _vertexBuffer;
        IndexBuffer _indexBuffer;

        uint _instances;
        VertexBuffer _instanceVertexBuffer;

        bool _traceDeep = false;
    }

    /// Constructor
    this(Vertex[] vertices, uint[] indices = null, Texture[] textures = null,
         uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        _vertices = vertices;
        _indices = indices;
        _instances = instances;

        if (textures) {
            _textures = textures;
        }

        // Generate and bind VAO
        _vertexArray = new VertexArray();
        _vertexArray.bind();

        // Transpose all matrices to pass them onto the VAO properly
        for (int i = 0; i < instanceMatrices.length; ++i) {
            instanceMatrices[i].transpose();
        }

        // Generate VBOs
        _instanceVertexBuffer = new VertexBuffer(instanceMatrices);
        _vertexBuffer = new VertexBuffer(_vertices);

        // Generate EBO
        _indexBuffer = new IndexBuffer(_indices);

        // Link main VBO attributes
        _vertexArray.linkAttributes(_vertexBuffer, 0, 3, GL_FLOAT, Vertex.sizeof, null);
        _vertexArray.linkAttributes(_vertexBuffer, 1, 3, GL_FLOAT, Vertex.sizeof, cast(void*)(3 * float.sizeof));
        _vertexArray.linkAttributes(_vertexBuffer, 2, 3, GL_FLOAT, Vertex.sizeof, cast(void*)(6 * float.sizeof));
        _vertexArray.linkAttributes(_vertexBuffer, 3, 2, GL_FLOAT, Vertex.sizeof, cast(void*)(9 * float.sizeof));

        // Link instance VBO attributes
        _vertexArray.linkAttributes(_instanceVertexBuffer, 4, 4, GL_FLOAT, mat4.sizeof, null);
        _vertexArray.linkAttributes(_instanceVertexBuffer, 5, 4, GL_FLOAT, mat4.sizeof, cast(void*)(1 * vec4.sizeof));
        _vertexArray.linkAttributes(_instanceVertexBuffer, 6, 4, GL_FLOAT, mat4.sizeof, cast(void*)(2 * vec4.sizeof));
        _vertexArray.linkAttributes(_instanceVertexBuffer, 7, 4, GL_FLOAT, mat4.sizeof, cast(void*)(3 * vec4.sizeof));
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);
        glVertexAttribDivisor(7, 1);

        // Unbind all objects
        VertexArray.unbind();
        VertexBuffer.unbind();
        IndexBuffer.unbind();
    }

    /// Bind shader, VAO
    void bindData(Shader shader) {
        shader.activate();
        _vertexArray.bind();

        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;

        /// @TODO rewrite shader forward
        uint textureId = 0;
        foreach (Texture texture; _textures) {
            const TextureType type = texture.type;

            string name;
            if (type == TextureType.diffuse) {
                name = to!string(type) ~ to!string(nbDiffuseTextures);
                ++nbDiffuseTextures;
            } else if (type == TextureType.specular) {
                name = to!string(type) ~ to!string(nbSpecularTextures);
                ++nbSpecularTextures;
            } else {
                name = to!string(type);
            }

            shader.uploadUniformInt(toStringz(name), textureId);
            texture.bind();
            ++textureId;
        }
    }

    /// Draw call
    void draw(Shader shader, Transform transform = Transform.identity) {
        bindData(shader);

        if (_instances == 1) {
            shader.uploadUniformMat4("model", transform.model);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        } else {
            shader.uploadUniformMat4("model", mat4.identity);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glDrawElementsInstanced(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null, _instances);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
    }
}
