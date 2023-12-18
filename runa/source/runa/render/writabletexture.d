/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.writabletexture;

import std.conv : to;
import std.string;
import std.exception : enforce;
import std.algorithm.comparison : clamp;

import bindbc.sdl;

import runa.core;
import runa.kernel;
import runa.render.renderer;
import runa.render.texture;
import runa.render.util;

/// Texture éditable
final class WritableTexture {
    private {
        SDL_Texture* _texture = null;
        SDL_Surface* _surface = null;
        uint _width, _height;
        Color _color = Color.white;
        float _alpha = 1f;
        Blend _blend = Blend.alpha;
    }

    @property {
        /// loaded ?
        bool isLoaded() const {
            return _texture !is null;
        }

        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }

        /// Color added to the canvas.
        Color color() const {
            return _color;
        }
        /// Ditto
        Color color(Color color_) {
            _color = color_;
            auto sdlColor = _color.toSDL();
            SDL_SetTextureColorMod(_texture, sdlColor.r, sdlColor.g, sdlColor.b);
            return _color;
        }

        /// Alpha
        float alpha() const {
            return _alpha;
        }
        /// Ditto
        float alpha(float alpha_) {
            _alpha = alpha_;
            SDL_SetTextureAlphaMod(_texture, cast(ubyte)(clamp(_alpha, 0f, 1f) * 255f));
            return _alpha;
        }

        /// Blending algorithm.
        Blend blend() const {
            return _blend;
        }
        /// Ditto
        Blend blend(Blend blend_) {
            _blend = blend_;
            SDL_SetTextureBlendMode(_texture, getSDLBlend(_blend));
            return _blend;
        }

        uint* pixels() {
            return cast(uint*) _surface.pixels;
        }
    }

    float sizeX = 0f, sizeY = 0f;

    /// Ctor
    this(const Texture texture) {
        load(texture.surface);
    }

    /// Ctor
    this(SDL_Surface* surface) {
        load(surface);
    }

    /// Ctor
    this(string path) {
        load(path);
    }

    /// Ctor
    this(uint width_, uint height_) {
        enforce(Runa.renderer.target, "the renderer does not exist");

        _width = width_;
        _height = height_;

        if (_texture)
            SDL_DestroyTexture(_texture);
        _texture = SDL_CreateTexture(Runa.renderer.target, SDL_PIXELFORMAT_RGBA8888,
            SDL_TEXTUREACCESS_STREAMING, _width, _height);
        enforce(_texture, "error occurred while converting a surface to a texture format.");

        updateSettings();
    }

    ~this() {
        unload();
    }

    package void load(SDL_Surface* surface) {
        enforce(Runa.renderer.target, "the renderer does not exist");
        enforce(surface, "invalid surface");

        _surface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
        enforce(_surface, "can't format surface");

        _width = _surface.w;
        _height = _surface.h;

        if (_texture)
            SDL_DestroyTexture(_texture);

        _texture = SDL_CreateTexture(Runa.renderer.target, SDL_PIXELFORMAT_RGBA8888,
            SDL_TEXTUREACCESS_STREAMING, _width, _height);

        enforce(_texture, "error occurred while converting a surface to a texture format.");

        updateSettings();
    }

    /// Load from file
    void load(string path) {
        enforce(Runa.renderer.target, "the renderer does not exist.");

        SDL_Surface* surface = IMG_Load(toStringz(path));
        enforce(surface, "can't load image file `" ~ path ~ "`");

        _surface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
        enforce(_surface, "can't format image file `" ~ path ~ "`");

        _width = _surface.w;
        _height = _surface.h;

        _texture = SDL_CreateTexture(Runa.renderer.target, SDL_PIXELFORMAT_RGBA8888,
            SDL_TEXTUREACCESS_STREAMING, _width, _height);

        enforce(_texture, "error occurred while converting `" ~ path ~ "` to a texture format.");

        updateSettings();
        SDL_FreeSurface(surface);
    }

    /// Free image data
    void unload() {
        if (_surface)
            SDL_FreeSurface(_surface);

        if (_texture)
            SDL_DestroyTexture(_texture);
    }

    void write(void function(uint*, uint*, uint, uint, void*) writeFunc, void* data = null) {
        uint* pixels;
        int pitch;
        if (SDL_LockTexture(_texture, null, cast(void**)&pixels, &pitch) == 0) {
            writeFunc(pixels, _surface ? (cast(uint*) _surface.pixels) : null,
                _width, _height, data);
            SDL_UnlockTexture(_texture);
        }
        else {
            throw new Exception("error while locking texture: " ~ to!string(
                    fromStringz(SDL_GetError())));
        }
    }

    /*void write(void function(uint*, uint*, uint, uint) writeFunc) {
        uint* pixels;
        int pitch;
        if (SDL_LockTexture(_texture, null, cast(void**)&pixels, &pitch) == 0) {
            writeFunc(pixels, _surface ? (cast(uint*) _surface.pixels) : null, _width, _height);
            SDL_UnlockTexture(_texture);
        }
        else {
            throw new Exception("error while locking texture: " ~ to!string(
                    fromStringz(SDL_GetError())));
        }
    }*/

    private void updateSettings() {
        auto sdlColor = _color.toSDL();
        SDL_SetTextureBlendMode(_texture, getSDLBlend(_blend));
        SDL_SetTextureColorMod(_texture, sdlColor.r, sdlColor.g, sdlColor.b);
        SDL_SetTextureAlphaMod(_texture, cast(ubyte)(clamp(_alpha, 0f, 1f) * 255f));
    }

    /// Render a section of the texture here
    void draw(float x, float y, float w, float h, vec4i clip, double angle,
        float pivotX = 0f, float pivotY = 0f, bool flipX = false, bool flipY = false) {

        SDL_Rect sdlSrc = clip.toSdlRect();
        SDL_FRect sdlDest = {x, y, w, h};
        SDL_FPoint sdlPivot = {pivotX, pivotY};

        SDL_RenderCopyExF(Runa.renderer.target, _texture, &sdlSrc, &sdlDest, angle, null, (flipX ?
    SDL_FLIP_HORIZONTAL : SDL_FLIP_NONE) | (flipY ? SDL_FLIP_VERTICAL : SDL_FLIP_NONE));
    }
}
