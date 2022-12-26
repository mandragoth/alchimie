module magia.render.sprite;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import magia.core;
import magia.render.texture;
import magia.render.shader;
import magia.render.vao;
import magia.render.vbo;
import magia.render.window;

/// Base rendering class.
final class Sprite {
    private {
        // @TODO texture cache?
        Texture _texture;

        // @TODO defer to texture?
        SDL_Surface* _surface = null;
        uint _width, _height;
        bool _isLoaded, _ownData;
    }

    @property {
        /// loaded ?
        bool isLoaded() const {
            return _isLoaded;
        }
        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }
    }

    /// Constructor
    this(Sprite sprite) {
        _isLoaded = sprite._isLoaded;
        _width = sprite._width;
        _height = sprite._height;
        _texture = sprite._texture;
        _ownData = false;
    }

    /// Constructor given an SDL surface
    this(SDL_Surface* surface, bool preload = false) {
        // Image data
        _surface = surface;
        enforce(_surface, "invalid surface");

        _width = _surface.w;
        _height = _surface.h;

        if (!preload) {
            postload();
        }
    }

    /// Constructor given an image path
    this(string path, bool preload = false) {
        // Image data
        _surface = IMG_Load(toStringz(path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        _width = _surface.w;
        _height = _surface.h;
        _ownData = true;

        if (!preload) {
            postload();
        }
    }

    ~this() {
        unload();
    }

    package void load(SDL_Surface* surface) {
        _width = surface.w;
        _height = surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Call it if you set the preload flag on ctor.
    void postload() {
        if (_isLoaded) {
            return;
        }

        _texture = new Texture(_surface, "sprite");

        if (_ownData) {
            SDL_FreeSurface(_surface);
            _surface = null;
        }
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