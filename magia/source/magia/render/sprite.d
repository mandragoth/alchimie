module magia.render.sprite;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.main;
import magia.render.data;
import magia.render.drawable;
import magia.render.entity;
import magia.render.material;
import magia.render.pool;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.window;

import std.stdio;

// Instance data
struct SpriteData {
    mat4 model;
    vec4 clip;
    vec4 color;
    vec2 flip;
}

/// Sprite handler
class SpritePool : DrawablePool!(2, Sprite, SpriteData) {
    /// Constructor
    this(Texture texture) {
        writeln("Fetching shader sprite");
        _shader = Magia.res.get!Shader("sprite");
        _textures ~= texture;
    }
}

/// Instance of sprite
final class Sprite : Entity2D, Resource!Sprite {
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
        vec2 size() const {
            return cast(vec2)_size;
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
        _instanceData.clip = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != defaultClip) {
            _instanceData.clip.x = cast(float) clip.x / cast(float) texture.width;
            _instanceData.clip.y = cast(float) clip.y / cast(float) texture.height;
            _instanceData.clip.z = _instanceData.clip.x + (cast(float) clip.z / cast(float) texture.width);
            _instanceData.clip.w = _instanceData.clip.y + (cast(float) clip.w / cast(float) texture.height);
        }

        _instanceData.color = vec4.one;

        final switch (flip) with (Flip) {
            case none:
                _instanceData.flip = vec2.zero;
                break;
            case horizontal:
                _instanceData.flip = vec2(1f, 0f);
                break;
            case vertical:
                _instanceData.flip = vec2(0f, 1f);
                break;
            case both:
                _instanceData.flip = vec2.one;
                break;
        }

        _size = vec2u(clip.width, clip.height);
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    /// Subscribe to related pool
    void register() {
        _spritePool.addDrawable(this);
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
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
