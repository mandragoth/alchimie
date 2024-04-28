module magia.render.skybox;

import std.stdio;
import std.string;
import std.conv;

import bindbc.opengl;

import magia.core;
import magia.kernel;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.data;
import magia.render.drawable;
import magia.render.postprocess;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling skybox data and draw call
final class Skybox : Drawable3D, Resource!Skybox {
    private {
        Shader _shader;
        Texture _texture;
    }

    // @TODO use new layout architecture

    /// Constructor
    this(string[6] files) {
        _shader = Magia.res.get!Shader("skybox");
        _shader.activate();
        _shader.uploadUniformInt("u_Skybox", 0);

        _texture = new Texture(files);
    }

    /// Accès à la ressource
    Skybox fetch() {
        return this;
    }

    /// Draw call
    override void draw(Renderer3D renderer) {
        glDepthFunc(GL_LEQUAL);

        skyboxMesh.bindData(_shader, _texture);

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
