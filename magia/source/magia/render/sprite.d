module magia.render.sprite;

import std.exception;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;

/// Base rendering class.
final class Sprite {
    /// Mirroring property
    Flip flip = Flip.none;

    /// Texture region being rendered
    vec4i clip;

    /// Size of texture region being rendered
    vec2 size;

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
    }

    /// Constructor
    this(Sprite sprite) {
        _texture = sprite._texture;
    }

    /// Constructor given an SDL surface
    this(SDL_Surface* surface) {
        _texture = new Texture(surface);
    }

    /// Constructor given an image path
    this(string path) {
        _texture = new Texture(path);
    }

    /// Draw the sprite on the screen
    void draw(vec2 position) {
        renderer.drawTexture(texture, position, size, clip, flip);
    }

    /// Free image data
    ~this() {
        _texture.remove();
    }
}