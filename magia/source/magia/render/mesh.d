module magia.render.mesh;

import std.conv;
import std.stdio;
import std.string;

import bindbc.opengl;

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.material;
import magia.render.texture;
import magia.render.scene;
import magia.render.shader;
import magia.render.vertex;

/// Class handling mesh data and draw call
final class Mesh {
    private {
        VertexArray _vertexArray;

        uint _instances;
        bool _traceDeep = false;
    }

    /// Constructor (@TODO pack instanceMatrices inside VBO on caller side)
    this(VertexBuffer vertexBuffer, uint[] indices = null,
         uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        _instances = instances;

        // Generate and bind VAO
        _vertexArray = new VertexArray();
        _vertexArray.bind();

        // Add vertex buffer to vertex array
        _vertexArray.addVertexBuffer(vertexBuffer);

        // Transpose all matrices to pass them onto the VBO properly (costly?)
        for (int instanceId = 0; instanceId < instanceMatrices.length; ++instanceId) {
            instanceMatrices[instanceId].transpose();
        }

        // Generate instancing vertex buffer
        VertexBuffer instanceVertexBuffer = new VertexBuffer(instanceMatrices);

        // Generate EBO
        _vertexArray.setIndexBuffer(new IndexBuffer(indices));

        // Link instance VBO attributes to VAO @TODO
        _vertexArray.linkAttributes(instanceVertexBuffer, 4, 4, GL_FLOAT, mat4.sizeof, null);
        _vertexArray.linkAttributes(instanceVertexBuffer, 5, 4, GL_FLOAT, mat4.sizeof, cast(void*)(1 * vec4.sizeof));
        _vertexArray.linkAttributes(instanceVertexBuffer, 6, 4, GL_FLOAT, mat4.sizeof, cast(void*)(2 * vec4.sizeof));
        _vertexArray.linkAttributes(instanceVertexBuffer, 7, 4, GL_FLOAT, mat4.sizeof, cast(void*)(3 * vec4.sizeof));
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);
        glVertexAttribDivisor(7, 1);
    }

    /// Bind shader, VAO
    void bindData(Shader shader, Material material) {
        shader.activate();
        _vertexArray.bind();

        uint nbSpriteTextures = 0;
        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;

        // Forward material textures to shader
        uint textureId = 0;
        foreach (Texture texture; material.textures) {
            const TextureType type = texture.type;

            string name;
            if (type == TextureType.sprite) {
                name = "u_Sprite" ~ to!string(nbSpriteTextures);
                ++nbSpriteTextures;
            } else if (type == TextureType.diffuse) {
                name = "u_Diffuse" ~ to!string(nbDiffuseTextures);
                ++nbDiffuseTextures;
            } else if (type == TextureType.specular) {
                name = "u_Specular" ~ to!string(nbSpecularTextures);
                ++nbSpecularTextures;
            } 

            shader.uploadUniformInt(toStringz(name), textureId);
            texture.bind();
            ++textureId;
        }
    }

    /// Draw call
    void draw(Shader shader, Material material, Transform transform = Transform.identity) {
        bindData(shader, material);

        if (_instances == 1) {
            shader.uploadUniformMat4("u_Transform", transform.model);
            glDrawElements(GL_TRIANGLES, _vertexArray.indexBuffer.count, GL_UNSIGNED_INT, null);
        } else {
            shader.uploadUniformMat4("u_Transform", mat4.identity);
            glDrawElementsInstanced(GL_TRIANGLES, _vertexArray.indexBuffer.count, GL_UNSIGNED_INT, null, _instances);
        }
    }
}
