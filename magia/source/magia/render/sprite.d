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
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;
import magia.render.window;

import std.stdio;

// Instance data
struct SpriteData {
    mat4 model;
    vec4 clip;
    vec2 flip;
}

class SpritePool : Drawable2D {
    private {
        Texture _texture;
        Sprite[] _sprites;

        SpriteData[] _spriteData;
    }

    /// Constructor
    this(Texture texture) {
        _texture = texture;
    }

    /// Add a sprite to the pool
    void addSprite(Sprite sprite) {
        _sprites ~= sprite;
    }

    /// Add sprite data to the pool
    void addSpriteData(mat4 model, vec4 clip, vec2 flip) {
        _spriteData ~= SpriteData(model, clip, flip);
    }

    void draw(Renderer2D renderer) {
        foreach(Sprite sprite; _sprites) {
            sprite.draw(renderer);
        }

        if (_spriteData.length) {
            renderer.drawSprites(_texture, _spriteData);
        }

        _spriteData.length = 0;
    }
}

/// Base rendering class.
final class Sprite : Entity2D, Resource!Sprite {
    private {
        // @TODO remove
        Texture _texture;
        SpritePool _spritePool;

        vec4 _clip;
        vec2 _flip;
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
        _texture = other._texture;
        _spritePool = other._spritePool;
        _clip = other._clip;
        _flip = other._flip;
        _size = other._size;
    }

    /// Constructor given an image path
    this(Texture texture, SpritePool spritePool = null, Clip clip = defaultClip, Flip flip = Flip.none) {
        transform = Transform2D.identity;

        // Save sprite pool reference
        _spritePool = spritePool;
        _texture = texture;

        // Default clip has x, y = 0 and w, h = 1
        _clip = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != defaultClip) {
            _clip.x = cast(float) clip.x / cast(float) texture.width;
            _clip.y = cast(float) clip.y / cast(float) texture.height;
            _clip.z = _clip.x + (cast(float) clip.z / cast(float) texture.width);
            _clip.w = _clip.y + (cast(float) clip.w / cast(float) texture.height);
        }

        final switch (flip) with (Flip) {
            case none:
                _flip = vec2.zero;
                break;
            case horizontal:
                _flip = vec2(1f, 0f);
                break;
            case vertical:
                _flip = vec2(0f, 1f);
                break;
            case both:
                _flip = vec2.one;
                break;
        }

        _size = vec2u(clip.width, clip.height);
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    void register() {
        _spritePool.addSprite(this);
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
        // Add instance data to the pool list
        _spritePool.addSpriteData(getTransformModel(renderer).transposed, _clip, _flip);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
