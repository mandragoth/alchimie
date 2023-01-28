module magia.shape.quad;

import std.path;
import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render;

/// Instance of quad
final class QuadInstance : Entity {
    private {
        Shader _shader;
        Material _material;
    }

    /// Constructor
    this() {
        transform = Transform.identity;

        _material.textures ~= [
            new Texture(buildNormalizedPath("assets", "texture", "planks.png"), TextureType.diffuse, 0),
            new Texture(buildNormalizedPath("assets", "texture", "planksSpec.png"), TextureType.specular, 1)
        ];

        _shader = fetchPrototype!Shader("model");
    }

    /// Render the quad
    override void draw() {
        _shader.activate();
        _shader.uploadUniformVec3("u_CamPos", renderer.camera.position);
        _shader.uploadUniformMat4("u_CamMatrix", renderer.camera.matrix);

        quadMesh.draw(_shader, _material, transform);
    }
}