module magia.shape.raytracer;

import magia.core;
import magia.main;
import magia.render.buffer;
import magia.render.data;
import magia.render.drawable;
import magia.render.instance;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.shader;

/// RayTracer
class RayTracer : Instance2D, Drawable2D {
    private {
        Shader _shader;
        Mesh2D _mesh;
    }

    /// Constructor
    this() {
        _shader = Magia.res.get!Shader("raytracer");

        _mesh = new Mesh2D(new VertexBuffer([
            -1f, -1f, 0f, 0f, // 3-----2
             1f, -1f, 1f, 0f, // |     |
             1f,  1f, 1f, 1f, // |     |
            -1f,  1f, 0f, 1f  // 0-----1
        ], layout2D), new IndexBuffer([
            0, 1, 2,
            2, 3, 0
        ]));
    }

    /// Draw call
    void draw(Renderer2D renderer) {
        renderer.draw(_mesh, _shader, [rayTracerTexture]);
    }
}