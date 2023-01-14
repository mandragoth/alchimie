module magia.render.sprite;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import magia.core;
import magia.render.texture;
import magia.render.shader;
import magia.render.window;

/// Base rendering class.
final class Sprite {
    private {
        // @TODO texture cache? with Resource.fetch
        Texture _texture;

        // Is sprite loaded
        bool _isLoaded, _ownData;
    }

    @property {
        /// Loaded?
        bool isLoaded() const {
            return _isLoaded;
        }

        /// Return texture id
        int textureId() {
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
        _isLoaded = sprite._isLoaded;
        _ownData = false;
    }

    /// Constructor given an SDL surface
    this(SDL_Surface* surface, bool preload = false) {
        // Image data
        _texture = new Texture(surface, "sprite");
        _isLoaded = true;
    }

    /// Constructor given an image path
    this(string path, bool preload = false) {
        // Image data
        _texture = new Texture(path, "sprite");
        _ownData = true;
        _isLoaded = true;
    }

    ~this() {
        unload();
    }

    /// Free image data
    void unload() {
        if (!_ownData) {
            return;
        }

        _texture.remove();
        _isLoaded = false;
    }
}