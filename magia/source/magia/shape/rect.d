module magia.shape.rect;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.main;
import magia.render.buffer;
import magia.render.data;
import magia.render.drawable;
import magia.render.instance;
import magia.render.material;
import magia.render.mesh;
import magia.render.pool;
import magia.render.renderer;
import magia.render.scene;
import magia.render.shader;
import magia.render.window;

import std.stdio;

/// Instance data
struct RectData {
    /// Model
    mat4 model;

    /// Sprite clip
    vec4 clip;

    /// Sprite color
    vec4 color;
}

/// Rectangle handler
class RectPool : DrawablePool!(2, Rect, RectData) {
    mixin Singleton;

    /// Constructor
    this() {
        _textures ~= defaultTexture;

        // Fetch shader
        _shader = Magia.res.get!Shader("rect");

        // Fetch mesh
        //_mesh = Magia.res.get!Mesh2D("rectMesh");

        _mesh = new Mesh2D(new VertexBuffer([
            -1f, -1f, 0f, 0f, // 3-----2
             1f, -1f, 1f, 0f, // |     |
             1f,  1f, 1f, 1f, // |     |
            -1f,  1f, 0f, 1f  // 0-----1
        ], layout2D), new IndexBuffer([
            0, 1, 2,
            2, 3, 0
        ]));

        // Information to forward for each rendered instance
        BufferLayout instanceLayout = new BufferLayout([
            BufferElement("a_Transform[0]", LayoutType.ltFloat4),
            BufferElement("a_Transform[1]", LayoutType.ltFloat4),
            BufferElement("a_Transform[2]", LayoutType.ltFloat4),
            BufferElement("a_Transform[3]", LayoutType.ltFloat4),
            BufferElement("a_Clip", LayoutType.ltFloat4),
            BufferElement("a_Color", LayoutType.ltFloat4)
        ]);

        // Per instance vertex buffer
        InstanceBuffer instanceBuffer = new InstanceBuffer(instanceLayout);
        _mesh.addInstanceBuffer(instanceBuffer, layout2D.count);

        // Add to current scene2D
        Magia.currentScene2D.addDrawable(this);
    }
}

/// Instance of rectangle
final class Rect : Instance2D, Drawable2D {
    private {
        RectData _rectData;
    }

    @property {
        /// Size
        vec2 size() const {
            return vec2(_rectData.clip.width, _rectData.clip.height);
        }
    }

    /// Copy constructor
    this(Rect other) {
        _rectData = other._rectData;
    }

    /// Constructor given an image path
    this(vec2u size, Color color) {
        transform = Transform2D.identity;

        // Clip
        _rectData.clip = vec4(0f, 0f, cast(float)size.x, cast(float)size.y);

        // Color and alpha
        _rectData.color = vec4(color.r, color.g, color.b, 1f);
    }

    /// Subscribe to related pool
    void register() {
        RectPool().addDrawable(this);
    }

    /// Draw the rectangle on the screen
    void draw(Renderer2D renderer) {
        // Reference model for draw call
        _rectData.model = getTransformModel(renderer).transposed;

        // Add instance data to the pool list
        RectPool().addInstanceData(_rectData);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
