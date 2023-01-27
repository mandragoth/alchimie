module magia.render.sprite;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.render.entity;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;

/// Base rendering class.
final class Sprite : Entity {
    /// Mirroring property
    Flip flip = Flip.none;

    /// Relative center of the sprite
    vec2 anchor; // @TODO

    /// Blending algorithm
    Blend blend = Blend.alpha;

    /// Color added to the sprite
    Color color = Color.white;

    /// Alpha
    float alpha = 1f;

    private {
        // Texture reference
        Texture _texture;
        
        /// Texture region being rendered
        vec4i _clip;

        /// Size of texture region being rendered
        vec2 _size;

        // Angle along Z axis
        float zAngle;
    }

    @property {
        /// Temporary
        Texture texture() {
            return _texture;
        }

        /// Return texture id
        int textureId() const {
            return _texture.id;
        }

        /// Underlying texture width
        uint width() const {
            return _texture.width;
        }

        /// Underlying texture height
        uint height() const {
            return _texture.height;
        }

        /// Size setter (@TODO remove?, used by glyph)
        void size(vec2 size_) {
            _size = size_;
        }

        /// Size setter (@TODO remove?, used by glyph)
        void clip(vec4i clip_) {
            _clip = clip_;
        }
    }

    /// Constructor
    this(Sprite sprite) {
        _texture = sprite._texture;
    }

    /// Constructor given an SDL surface
    this(string name, SDL_Surface* surface) {
        _texture = new Texture(name, surface);
    }

    /// Constructor given an image path
    this(string fileName, vec4i clip = vec4i.zero) {
        transform = Transform.identity;
        _texture = fetchPrototype!Texture(fileName);
        _size = vec2(clip.z, clip.w);
        _clip = clip;
    }

    /// Draw the sprite on the screen
    override void draw() {
        renderer.drawTexture(texture, position2D, _size, _clip, flip);
    }

    /// Free image data
    ~this() {
        _texture.remove();
    }
}