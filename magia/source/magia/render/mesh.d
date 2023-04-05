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
        VertexBuffer _vertexBuffer;
        GLenum _drawMode;

        uint _instances;
        bool _traceDeep = false;
    }

    /// Constructor (@TODO pack instanceMatrices inside vertex buffer on caller side)
    this(VertexBuffer vertexBuffer, IndexBuffer indexBuffer = null, GLenum drawMode = GL_TRIANGLES,
         uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        // Setup members from ctr
        _drawMode = drawMode;
        _instances = instances;
        _vertexBuffer = vertexBuffer;

        // Generate and bind vertex array
        _vertexArray = new VertexArray(_vertexBuffer, indexBuffer);
        _vertexArray.bind();

        // Transpose all matrices to pass them onto the Vertex Buffer properly (costly?)
        /*for (int instanceId = 0; instanceId < instanceMatrices.length; ++instanceId) {
            instanceMatrices[instanceId].transpose();
        }

        // Generate instancing vertex buffer
        VertexBuffer instanceVertexBuffer = new VertexBuffer(instanceMatrices);

        // Link instance vertex buffer attributes to vertex array @TODO refactoring
        _vertexArray.linkAttributes(instanceVertexBuffer, 4, 4, GL_FLOAT, mat4.sizeof, null);
        _vertexArray.linkAttributes(instanceVertexBuffer, 5, 4, GL_FLOAT, mat4.sizeof, cast(void*)(1 * vec4.sizeof));
        _vertexArray.linkAttributes(instanceVertexBuffer, 6, 4, GL_FLOAT, mat4.sizeof, cast(void*)(2 * vec4.sizeof));
        _vertexArray.linkAttributes(instanceVertexBuffer, 7, 4, GL_FLOAT, mat4.sizeof, cast(void*)(3 * vec4.sizeof));
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);
        glVertexAttribDivisor(7, 1);*/
    }

    /// Bind shader, vertex array
    void bindData(Shader shader, Material material) {
        shader.activate();
        _vertexArray.bind();

        uint nbSpriteTextures = 0;
        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;

        // Forward material textures to shader
        uint textureId = 0;
        foreach (ref Texture texture; material.textures) {
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

            // @TODO Likely wrong, we want to update the id of the matching type
            shader.uploadUniformInt(toStringz(name), textureId);
            texture.bind();
            ++textureId;
        }
    }

    /// Draw call
    void draw(Shader shader, Material material, Transform transform = Transform.identity) {
        bindData(shader, material);
        
        // Index buffer: defer to glDrawElements* methods
        if (_vertexArray.elementCount) {
            drawElements(shader, transform);
        }
        // No index buffer, defer to glDrawArrays* methods
        else {
            drawArrays(shader, transform);
        }
    }

    private void drawElements(Shader shader, Transform transform) {
        if (_instances == 1) {
            shader.uploadUniformMat4("u_Transform", transform.model);
            glDrawElements(_drawMode, _vertexArray.elementCount, GL_UNSIGNED_INT, null);
        } else {
            shader.uploadUniformMat4("u_Transform", mat4.identity);
            glDrawElementsInstanced(_drawMode, _vertexArray.elementCount, GL_UNSIGNED_INT, null, _instances);
        }

        // Debug: normals
    }

    private void drawArrays(Shader shader, Transform transform) {
        if (_instances == 1) {
            shader.uploadUniformMat4("u_Transform", transform.model);
            //glDrawArrays(_drawMode, 0, );
        }
    }
}
