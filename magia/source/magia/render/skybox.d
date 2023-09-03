module magia.render.skybox;

import std.stdio;
import std.string;
import std.conv;

import bindbc.opengl;

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.data;
import magia.render.entity;
import magia.render.material;
import magia.render.postprocess;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling skybox data and draw call
final class Skybox : Entity3D {
    private {
        Shader _shader;
        Material _material;
    }

    // @TODO skybox resource cache?
    // @TODO use new layout architecture

    /// Constructor
    this() {
        _shader = fetchPrototype!Shader("skybox");
        _shader.activate();
        _shader.uploadUniformInt("u_Skybox", 0);

        string[6] faceCubemaps = [
            "night/right.png", "night/left.png", "night/top.png",
            "night/bottom.png", "night/front.png", "night/back.png"
        ];

        _material = new Material(new Texture(faceCubemaps));
    }

    /// Draw call
    override void draw() {
        glDepthFunc(GL_LEQUAL);

        skyboxMesh.bindData(_shader, _material);

        // @TODO handle generically?
        foreach (Camera camera; renderer.cameras) {
            glViewport(camera.viewport.x, camera.viewport.y, camera.viewport.z, camera.viewport.w);
            _shader.uploadUniformMat4("u_View", mat4(mat3(camera.view)));
            _shader.uploadUniformMat4("u_Projection", camera.projection);
            _shader.uploadUniformFloat("u_Gamma", gamma);

            glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, null);
        }

        glDepthFunc(GL_LESS);
    }
}
