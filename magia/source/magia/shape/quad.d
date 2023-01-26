module magia.shape.quad;

import std.path;
import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;
import magia.shape.light;

/// Instance of quad
final class QuadInstance : Entity {
    private {
        Mesh _mesh;
        Shader _shader;
    }

    /// Constructor
    this() {
        transform = Transform.identity;

        // Quad vertices
        Vertex[] vertices = [
            //     COORDINATES                /     NORMALS         /    COLORS        /    TexCoord   //
	        Vertex(vec3(-1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 0.0f)),
	        Vertex(vec3(-1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 0.0f))
        ];

        // Quad indices
        GLuint[] indices = [
            0, 1, 2,
            0, 2, 3
        ];

        Texture[] textures = [
            new Texture(buildNormalizedPath("assets", "texture", "planks.png"), TextureType.diffuse, 0),
            new Texture(buildNormalizedPath("assets", "texture", "planksSpec.png"), TextureType.specular, 1)
        ];

        _mesh = new Mesh(vertices, indices, textures);
        _shader = new Shader("default.vert", "default.frag");
    }

    /// Render the quad
    override void draw() {
        _mesh.draw(_shader, transform);
    }
}