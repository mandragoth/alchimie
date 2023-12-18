module runa.render.texture;

import std.string;
import std.exception;
import std.algorithm.comparison : clamp;

import bindbc.sdl;

import runa.core;
import runa.kernel;
import runa.render.renderer;
import runa.render.util;

/// Base rendering class.
final class Texture {
    private {
        bool _isLoaded = false, _ownData, _isSmooth;
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

        /// underlaying surface
        package SDL_Surface* surface() const {
            return cast(SDL_Surface*) _surface;
        }
    }

    /// Ctor
    this(const Texture texture) {
        _isLoaded = texture._isLoaded;
        _texture = cast(SDL_Texture*) texture._texture;
        _surface = cast(SDL_Surface*) texture._surface;
        _width = texture._width;
        _height = texture._height;
        _isSmooth = texture._isSmooth;
        _blend = texture._blend;
        _color = texture._color;
        _alpha = texture._alpha;
        _ownData = false;
    }

    /// Ctor
    this(SDL_Surface* surface_, bool isSmooth_ = false) {
        _isSmooth = isSmooth_;
        load(surface_);
    }

    /// Ctor
    this(string filePath, bool isSmooth_ = false) {
        _isSmooth = isSmooth_;
        load(filePath);
    }

    ~this() {
        unload();
    }

    package void load(SDL_Surface* surface_) {
        if (_surface && _ownData)
            SDL_FreeSurface(_surface);

        _surface = surface_;

        enforce(_surface, "invalid surface");
        enforce(Runa.renderer.target, "the renderer does not exist");

        if (_texture)
            SDL_DestroyTexture(_texture);

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");

        _texture = SDL_CreateTextureFromSurface(Runa.renderer.target, _surface);

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

        enforce(_texture, "error occurred while converting a surface to a texture format.");
        updateSettings();

        _width = _surface.w;
        _height = _surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Load from file
    void load(string filePath) {
        if (_surface && _ownData)
            SDL_FreeSurface(_surface);

        const(ubyte)[] data = Runa.res.read(filePath);
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        _surface = IMG_Load_RW(rw, 1);
        enforce(_surface, "impossible de charger `" ~ filePath ~ "`");

        enforce(_surface, "can't load image file `" ~ filePath ~ "`");
        enforce(Runa.renderer.target, "the renderer does not exist");

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");

        _texture = SDL_CreateTextureFromSurface(Runa.renderer.target, _surface);

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

        enforce(_texture, "error occurred while converting `" ~ filePath ~ "` to a texture format.");
        updateSettings();

        _width = _surface.w;
        _height = _surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Free image data
    void unload() {
        if (!_ownData)
            return;

        if (_surface)
            SDL_FreeSurface(_surface);

        if (_texture)
            SDL_DestroyTexture(_texture);

        _isLoaded = false;
    }

    private void updateSettings() {
        auto sdlColor = _color.toSDL();
        SDL_SetTextureBlendMode(_texture, getSDLBlend(_blend));
        SDL_SetTextureColorMod(_texture, sdlColor.r, sdlColor.g, sdlColor.b);
        SDL_SetTextureAlphaMod(_texture, cast(ubyte)(clamp(_alpha, 0f, 1f) * 255f));
    }

    /// Dessine la texture
    void draw(float x, float y, float w, float h, vec4i clip, double angle,
        float pivotX = 0f, float pivotY = 0f, bool flipX = false, bool flipY = false) {
        enforce(_isLoaded, "can't render the texture: asset not loaded");

        SDL_Rect sdlSrc = clip.toSdlRect();
        SDL_FRect sdlDest = {x, y, w, h};
        SDL_FPoint sdlPivot = {pivotX, pivotY};

        SDL_RenderCopyExF(Runa.renderer.target, _texture, &sdlSrc, //
            &sdlDest, angle, null, //
            (flipX ?
    SDL_FLIP_HORIZONTAL : SDL_FLIP_NONE) | //
            (flipY ? SDL_FLIP_VERTICAL : SDL_FLIP_NONE));
    }
}
