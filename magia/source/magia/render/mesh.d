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
final class Mesh(uint dimension_) {
    private {
        VertexArray _vertexArray;
        VertexBuffer _vertexBuffer;
        VertexBuffer _instanceBuffer;
        GLenum _drawMode;
        uint _nbInstances = 1;
    }

    /// Constructor
    this(VertexBuffer vertexBuffer, IndexBuffer indexBuffer = null, GLenum drawMode = GL_TRIANGLES) {
        // Setup members from ctr
        _drawMode = drawMode;
        _vertexBuffer = vertexBuffer;

        // Generate and bind vertex array
        _vertexArray = new VertexArray(_vertexBuffer, indexBuffer);
        _vertexArray.bind();
    }

    /// Copy constructor
    this(Mesh!dimension_ other) {
        _vertexArray = other._vertexArray;
        _vertexBuffer = other._vertexBuffer;
        _instanceBuffer = other._instanceBuffer;
        _drawMode = other._drawMode;
        _nbInstances = other._nbInstances;
    }

    /// Add per instance vertex buffer
    void addInstancedVertexBuffer(VertexBuffer instanceBuffer, uint firstLayoutId) {
        _instanceBuffer = instanceBuffer;
        _vertexArray.addInstanceVertexBuffer(_instanceBuffer, firstLayoutId);
    }

    /// Update instance data before draw call
    void updateInstanceData(type)(type[] data, uint nbInstances, uint offset = 0) {
        _nbInstances = nbInstances;
        _instanceBuffer.updateData(data, offset);
    }

    /// Bind shader, vertex array
    void bindData(Shader shader, Texture[] textures) {
        shader.activate();
        _vertexArray.bind();

        uint nbSpriteTextures = 0;
        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;

        // Forward textures to shader
        uint textureId = 0;
        foreach (ref Texture texture; textures) {
            const TextureType type = texture.type;

            // Pack texture type and id into name
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

            // Upload texture index (@TODO should it be texture.id?)
            shader.uploadUniformInt(toStringz(name), textureId);

            // Bind texture
            texture.bind();

            // Increment texture index
            ++textureId;
        }
    }

    /// Override for a single texture
    void bindData(Shader shader, Texture texture) {
        bindData(shader, [texture]);
    }

    /// Draw call
    void draw(Shader shader, Texture[] textures) {
        // Bind shader and textures
        bindData(shader, textures);

        // Index buffer: defer to glDrawElements* methods
        if (_vertexArray.count) {
            drawElements(shader);
        }
        // No index buffer, defer to glDrawArrays* methods
        else {
            drawArrays(shader);
        }
    }

    /// Draw call (override with transform matrix)
    void draw(Shader shader, Texture[] textures, mat4 model) {
        // Bind shader and textures
        bindData(shader, textures);

        // Upload transform as uniform
        shader.uploadUniformMat4("u_Transform", model);
        
        // Index buffer: defer to glDrawElements* methods
        if (_vertexArray.count) {
            drawElements(shader);
        }
        // No index buffer, defer to glDrawArrays* methods
        else {
            drawArrays(shader);
        } 
    }

    private void drawElements(Shader shader) {
        if (_nbInstances == 1) {
            glDrawElements(_drawMode, _vertexArray.count, GL_UNSIGNED_INT, null);
        } else {
            glDrawElementsInstanced(_drawMode, _vertexArray.count, GL_UNSIGNED_INT, null, _nbInstances);
        }
    }

    private void drawArrays(Shader shader) {
        if (_nbInstances == 1) {
            glDrawArrays(_drawMode, 0, _vertexBuffer.count);
        } else {
            glDrawArraysInstanced(_drawMode, 0, _vertexBuffer.count, _nbInstances);
        }
    }
}

alias Mesh2D = Mesh!(2);
alias Mesh3D = Mesh!(3);