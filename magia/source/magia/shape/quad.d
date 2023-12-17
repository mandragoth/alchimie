module magia.shape.quad;

import std.path;
import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render;

/// Instance of quad
final class QuadInstance : Entity3D {
    private {
        Shader _shader;
        Material _material;
    }

    /// Constructor
    this() {
        transform = Transform3D.identity;

        _material.textures ~= [
            new Texture(buildNormalizedPath("assets", "texture", "planks.png"), TextureType.diffuse, 0),
            new Texture(buildNormalizedPath("assets", "texture", "planksSpec.png"), TextureType.specular, 1)
        ];

        _shader = modelShader;
    }

    /// Render the quad
    override void draw(Renderer3D renderer) {
        _shader.activate();

        // @TODO handle generically?
        foreach (Camera camera; renderer.cameras) {
            glViewport(camera.viewport.x, camera.viewport.y, camera.viewport.z, camera.viewport.w);
            _shader.uploadUniformVec3("u_CamPos", camera.globalPosition);
            _shader.uploadUniformMat4("u_CamMatrix", camera.matrix);

            quadMesh.draw(_shader, _material, globalModel);
        }
    }
}