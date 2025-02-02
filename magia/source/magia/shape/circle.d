module magia.shape.circle;

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
/// @TODO handle duplicate
struct CircleData {
    /// Model
    mat4 model;

    /// Sprite clip
    vec4 clip;

    /// Sprite color
    vec4 color;
}

/// Circle handler
/// @TODO handle duplicates
class CirclePool : DrawablePool!(2, Circle, CircleData) {
    mixin Singleton;

    /// Constructor
    this() {
        _textures ~= defaultTexture;

        // Fetch shader
        _shader = Magia.res.get!Shader("circle");

        // Fetch mesh
        // @TODO handle mesh resource
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

/// Instance of circle
/// @TODO handle duplicate
final class Circle : Instance2D, Drawable2D {
    private {
        CircleData _circleData;
    }

    @property {
        /// Size
        float size() const {
            return _circleData.clip.width;
        }
    }

    /// Copy constructor
    this(Circle other) {
        _circleData = other._circleData;
    }

    /// Constructor given an image path
    this(uint size, Color color) {
        transform = Transform2D.identity;

        // Clip
        _circleData.clip = vec4(0f, 0f, cast(float)size, cast(float)size);

        // Color and alpha
        _circleData.color = vec4(color.r, color.g, color.b, 1f);
    }

    /// Subscribe to related pool
    void register() {
        CirclePool().addDrawable(this);
    }

    /// Draw the circle on the screen
    void draw(Renderer2D renderer) {
        // Reference model for draw call
        _circleData.model = getTransformModel(renderer).transposed;

        // Add instance data to the pool list
        CirclePool().addInstanceData(_circleData);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}