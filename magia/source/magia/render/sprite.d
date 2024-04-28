module magia.render.sprite;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.render.buffer;
import magia.render.data;
import magia.render.drawable;
import magia.render.instance;
import magia.render.material;
import magia.render.mesh;
import magia.render.pool;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.window;

import std.stdio;

/// Instance data
struct SpriteData {
    /// Sprite model
    mat4 model;

    /// Sprite clip
    vec4f clip;

    /// Sprite color
    vec4f color;

    /// Sprite flip
    vec2f flip;
}

/// Sprite handler
class SpritePool : DrawablePool!(2, Sprite, SpriteData), Resource!SpritePool {
    /// Constructor
    this(Texture texture) {
        _textures ~= texture;
    }

    /// Ressource
    SpritePool fetch() {
        return this;
    }

    /// Load resources
    void loadResources() {
        if(!_loaded) {
            // Fetch shader
            _shader = Magia.res.get!Shader("sprite");

            // Fetch mesh
            _mesh = Magia.res.get!Mesh2D("rectMesh");

            /*_mesh = new Mesh2D(new VertexBuffer([
                -1f, -1f, 0f, 0f, // 3-----2
                 1f, -1f, 1f, 0f, // |     |
                 1f,  1f, 1f, 1f, // |     |
                -1f,  1f, 0f, 1f  // 0-----1
            ], layout2D), new IndexBuffer([
                0, 1, 2,
                2, 3, 0
            ]));*/

            // Information to forward for each rendered instance
            BufferLayout instanceLayout = new BufferLayout([
                BufferElement("a_Transform[0]", LayoutType.ltFloat4),
                BufferElement("a_Transform[1]", LayoutType.ltFloat4),
                BufferElement("a_Transform[2]", LayoutType.ltFloat4),
                BufferElement("a_Transform[3]", LayoutType.ltFloat4),
                BufferElement("a_Clip", LayoutType.ltFloat4),
                BufferElement("a_Color", LayoutType.ltFloat4),
                BufferElement("a_Flip", LayoutType.ltFloat2)
            ]);

            // Per instance vertex buffer
            InstanceBuffer instanceBuffer = new InstanceBuffer(instanceLayout);
            _mesh.addInstanceBuffer(instanceBuffer, layout2D.count);

            Magia.currentScene2D.addDrawable(this);
            _loaded = true;
        }
    }
}

/// Instance of sprite
final class Sprite : Instance2D, Drawable2D, Resource!Sprite {
    private {
        SpritePool _spritePool;
        SpriteData _instanceData;

        vec2u _size;
    }

    @property {
        /// Width
        uint width() const {
            return _size.x;
        }

        /// Height
        uint height() const {
            return _size.y;
        }

        /// Size
        vec2f size() const {
            return cast(vec2f)_size;
        }
    }

    /// Copy constructor
    this(Sprite other) {
        _spritePool = other._spritePool;
        _instanceData = other._instanceData;
        _size = other._size;
    }

    /// Constructor given an image path
    this(Texture texture, SpritePool spritePool = null, Clip clip = defaultClip, Flip flip = Flip.none) {
        transform = Transform2D.identity;

        // Save sprite pool reference
        _spritePool = spritePool;

        // Default clip has x, y = 0 and w, h = 1
        _instanceData.clip = vec4f(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != defaultClip) {
            _instanceData.clip.x = cast(float) clip.x / cast(float) texture.width;
            _instanceData.clip.y = cast(float) clip.y / cast(float) texture.height;
            _instanceData.clip.z = _instanceData.clip.x + (cast(float) clip.z / cast(float) texture.width);
            _instanceData.clip.w = _instanceData.clip.y + (cast(float) clip.w / cast(float) texture.height);
        }

        _instanceData.color = vec4f.one;

        final switch (flip) with (Flip) {
            case none:
                _instanceData.flip = vec2f.zero;
                break;
            case horizontal:
                _instanceData.flip = vec2f(1f, 0f);
                break;
            case vertical:
                _instanceData.flip = vec2f(0f, 1f);
                break;
            case both:
                _instanceData.flip = vec2f.one;
                break;
        }

        _size = vec2u(clip.width, clip.height);
    }

    /// Access to resource
    Sprite fetch() {
        return new Sprite(this);
    }

    /// Subscribe to related pool
    void register() {
        _spritePool.loadResources(); 
        _spritePool.addDrawable(this);
    }

    /// Draw the sprite on the screen
    void draw(Renderer2D renderer) {
        // Reference model for draw call
        _instanceData.model = getTransformModel(renderer).transposed;

        // Add instance data to the pool list
        _spritePool.addInstanceData(_instanceData);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
