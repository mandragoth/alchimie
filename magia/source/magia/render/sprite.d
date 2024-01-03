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

class SpritePool : Drawable2D {
    private {
        Texture _texture;
        Sprite[] _sprites;

        // Instance data
        mat4[] _models;
    }

    /// Constructor
    this(Texture texture) {
        _texture = texture;
    }

    /// Add a sprite to the pool
    void addSprite(Sprite sprite) {
        _sprites ~= sprite;
    }

    /// Add a model to the pool
    void addModel(mat4 model) {
        _models ~= model;
    }

    void draw(Renderer2D renderer) {
        foreach(Sprite sprite; _sprites) {
            sprite.draw(renderer);
        }

        if (_models.length) {
            renderer.drawSprites(_texture, _sprites[0]._clipf, _sprites[0]._flipf, _models);
        }

        _models.length = 0;
    }
}

/// Base rendering class.
final class Sprite : Entity2D, Resource!Sprite {
    private {
        // @TODO remove
        Texture _texture;
        SpritePool _spritePool;

        vec2u _size;
    }

    /// @TODO move back to private
    vec4 _clipf;
    vec2 _flipf;

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
        _clipf = other._clipf;
        _flipf = other._flipf;
        _size = other._size;
    }

    /// Constructor given an image path
    this(Texture texture, SpritePool spritePool = null, Clip clip = defaultClip, Flip flip = Flip.none) {
        transform = Transform2D.identity;

        // Save sprite pool reference
        _spritePool = spritePool;
        _texture = texture;

        // Default clip has x, y = 0 and w, h = 1
        _clipf = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != defaultClip) {
            _clipf.x = cast(float) clip.x / cast(float) texture.width;
            _clipf.y = cast(float) clip.y / cast(float) texture.height;
            _clipf.z = _clipf.x + (cast(float) clip.z / cast(float) texture.width);
            _clipf.w = _clipf.y + (cast(float) clip.w / cast(float) texture.height);
        }

        final switch (flip) with (Flip) {
            case none:
                _flipf = vec2.zero;
                break;
            case horizontal:
                _flipf = vec2(1f, 0f);
                break;
            case vertical:
                _flipf = vec2(0f, 1f);
                break;
            case both:
                _flipf = vec2.one;
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
        // Get model
        mat4 model = getTransformModel(renderer);

        // Add it to the pool list
        _spritePool.addModel(model.transposed);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
