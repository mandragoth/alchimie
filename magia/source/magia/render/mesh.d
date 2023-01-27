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

        // Define shader layout
        BufferLayout mainLayout = new BufferLayout([
            BufferElement("a_Position", LayoutType.ltFloat3),
            BufferElement("a_Normal", LayoutType.ltFloat3),
            BufferElement("a_Color", LayoutType.ltFloat3), // @TODO maybe color should be an uniform instead
            BufferElement("a_TexCoords", LayoutType.ltFloat2)
        ]);

        // Generate and bind VAO
        _vertexArray = new VertexArray();
        _vertexArray.bind();

        // Transpose all matrices to pass them onto the VBO properly (costly?)
        for (int instanceId = 0; instanceId < instanceMatrices.length; ++instanceId) {
            instanceMatrices[instanceId].transpose();
        }

        // Generate vertex buffers
        _vertexBuffer = new VertexBuffer(_vertices);
        _vertexBuffer.layout = mainLayout;
        _instanceVertexBuffer = new VertexBuffer(instanceMatrices);

        // Generate EBO
        _indexBuffer = new IndexBuffer(_indices);

        // Link main VBO attributes to VAO
        _vertexArray.addVertexBuffer(_vertexBuffer);

        // Link instance VBO attributes to VAO @TODO
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
            shader.uploadUniformMat4("u_Transform", transform.model);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        } else {
            shader.uploadUniformMat4("u_Transform", mat4.identity);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            glDrawElementsInstanced(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null, _instances);
            //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
    }
}
