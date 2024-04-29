module magia.render.font.truetype;

import std.conv : to;
import std.exception : enforce;
import std.file : read;
import std.string : toStringz, fromStringz;

import bindbc.sdl;
import bindbc.opengl;

import magia.core;
import magia.kernel;
import magia.render.material;
import magia.render.sprite;
import magia.render.texture;
import magia.render.font.font;
import magia.render.font.glyph;

/// Police correspondant à un fichier TrueType
final class TrueTypeFont : Font, Resource!TrueTypeFont {
    private {
        TTF_Font* _trueTypeFont;
        uint _size, _outline;
        Glyph[dchar] _cache;
        bool _isSmooth;
        int _posX, _posY;
        int _surfaceW = 1024, _surfaceH = 1024;
        Texture _texture;
        SpritePool _spritePool;
    }

    @property {
        /// Taille de la police
        int size() const {
            return TTF_FontHeight(_trueTypeFont);
        }
        /// Jusqu’où peut monter un caractère au-dessus la ligne
        int ascent() const {
            return TTF_FontAscent(_trueTypeFont);
        }
        /// Jusqu’où peut descendre un caractère en-dessous la ligne
        int descent() const {
            return TTF_FontDescent(_trueTypeFont);
        }
        /// Distance entre chaque ligne
        int lineSkip() const {
            return TTF_FontLineSkip(_trueTypeFont);
        }
        /// Taille de la bordure
        int outline() const {
            return _outline;
        }
    }

    /// Copy ctor
    this(TrueTypeFont font) {
        _trueTypeFont = font._trueTypeFont;
        _size = font._size;
        _outline = font._outline;
    }

    static TrueTypeFont fromMemory(const(ubyte)[] data, uint size_ = 12u, uint outline_ = 0) {
        return new TrueTypeFont(data, size_, outline_);
    }

    static TrueTypeFont fromResource(const string filePath, uint size_ = 12u, uint outline_ = 0) {
        const(ubyte)[] data = Magia.res.read(filePath);
        return new TrueTypeFont(data, size_, outline_);
    }

    static TrueTypeFont fromFile(const string filePath, uint size_ = 12u, uint outline_ = 0) {
        const(ubyte)[] data = cast(const(ubyte)[]) read(filePath);
        return new TrueTypeFont(data, size_, outline_);
    }

    private this(const(ubyte)[] data, uint size_, uint outline_) {
        _size = size_;
        _outline = outline_;
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);

        assert(_size != 0u, "can't render a font with no size");
        if (null != _trueTypeFont)
            TTF_CloseFont(_trueTypeFont);
        _trueTypeFont = TTF_OpenFontRW(rw, 1, _size);
        assert(_trueTypeFont, "can't load font");

        TTF_SetFontKerning(_trueTypeFont, 1);

        _texture = new Texture(_surfaceW, _surfaceH, GL_TEXTURE_2D, TextureType.sprite);
        _spritePool = new SpritePool(_texture);
    }

    ~this() {
        if (null != _trueTypeFont)
            TTF_CloseFont(_trueTypeFont);
    }

    TrueTypeFont fetch() {
        return this;
    }

    /// Toggle the glyph smoothing
    void setSmooth(bool isSmooth_) {
        if (isSmooth_ != _isSmooth)
            _cache.clear();
        _isSmooth = isSmooth_;
    }

    private Glyph _cacheGlyph(dchar ch) {
        int xmin, xmax, ymin, ymax, advance;
        if (_outline == 0) {
            if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax,
                    &ymin, &ymax, &advance))
                return new BasicGlyph();

            SDL_Color whiteColor = Color.white.toSDL();
            whiteColor.a = 0;

            SDL_Surface* surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, whiteColor);
            enforce(surface, "échec lors de la génération du glyphe TTF");

            SDL_Surface* convertedSurface = SDL_ConvertSurfaceFormat(surface,
                SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(convertedSurface, "échec lors de la conversion de la texture");

            uint ascent_ = ascent();
            uint descent_ = descent();

            if (_posX + surface.w >= _surfaceW) {
                _posX = 0;
                _posY += ascent_ - descent_;

                if (_posY + (ascent_ - descent_) > _surfaceH) {
                    _posY = 0;
                    _texture = new Texture(_surfaceW, _surfaceH,
                        GL_TEXTURE_2D, TextureType.sprite);
                    _spritePool = new SpritePool(_texture);
                }
            }

            _texture.update(vec4u(_posX, _posY, surface.w, surface.h),
                (cast(uint*) convertedSurface.pixels)[0 .. (surface.w * surface.h)]);

            Glyph metrics = new BasicGlyph(true, advance, 0, 0, surface.w,
                surface.h, _posX, _posY, surface.w, surface.h, _texture, _spritePool);

            _posX += surface.w;

            SDL_FreeSurface(surface);
            SDL_FreeSurface(convertedSurface);

            _cache[ch] = metrics;
            return metrics;
        } else {
            if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax,
                    &ymin, &ymax, &advance))
                return new BasicGlyph();

            SDL_Color whiteColor = Color.white.toSDL();
            whiteColor.a = 0;

            SDL_Color blackColor = Color.white.toSDL();
            blackColor.a = 0;

            TTF_SetFontOutline(_trueTypeFont, _outline);

            SDL_Surface* outlineSurface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, blackColor);
            enforce(outlineSurface, "échec lors de la génération du glyphe TTF");

            TTF_SetFontOutline(_trueTypeFont, 0);

            SDL_Surface* surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, Color.white.toSDL());
            enforce(surface, "échec lors de la génération du glyphe TTF");

            SDL_Rect srcRect = {0, 0, surface.w, surface.h};
            SDL_Rect dstRect = {_outline, _outline, surface.w, surface.h};

            SDL_BlitSurface(surface, &srcRect, outlineSurface, &dstRect);

            SDL_Surface* convertedSurface = SDL_ConvertSurfaceFormat(outlineSurface,
                SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(convertedSurface, "échec lors de la conversion de la texture");

            uint ascent_ = ascent();
            uint descent_ = descent();

            if (_posX + convertedSurface.w >= _surfaceW) {
                _posX = 0;
                _posY += ascent_ - descent_;

                if (_posY + (ascent_ - descent_) > _surfaceH) {
                    _posY = 0;
                    _texture = new Texture(_surfaceW, _surfaceH,
                        GL_TEXTURE_2D, TextureType.sprite);
                    _spritePool = new SpritePool(_texture);
                }
            }

            _texture.update(vec4u(_posX, _posY, surface.w, surface.h),
                (cast(uint*) convertedSurface.pixels)[0 .. (surface.w * surface.h)]);

            Glyph metrics = new BasicGlyph(true, advance, 0, 0, surface.w,
                surface.h, _posX, _posY, surface.w, surface.h, _texture, _spritePool);

            _posX += surface.w;

            SDL_FreeSurface(surface);
            SDL_FreeSurface(outlineSurface);
            SDL_FreeSurface(convertedSurface);

            _cache[ch] = metrics;
            return metrics;
        }
    }

    int getKerning(dchar prevChar, dchar currChar) {
        return TTF_GetFontKerningSizeGlyphs32(_trueTypeFont, prevChar, currChar);
    }

    Glyph getGlyph(dchar ch) {
        Glyph* glyph = ch in _cache;
        if (glyph)
            return *glyph;
        return _cacheGlyph(ch);
    }
}

/*
/// Font that load a TTF file.
final class TrueTypeFont : Font {
    private {
        TTF_Font* _trueTypeFont;
        bool _ownData;
        string _name;
        int _size, _outline;
        Glyph[dchar] _cache;
    }

    @property {
        /// Font name
        string name() const {
            return _name;
        }
        /// Default font size
        int size() const {
            return TTF_FontHeight(_trueTypeFont);
        }
        /// Where the top is above the baseline
        int ascent() const {
            return TTF_FontAscent(_trueTypeFont);
        }
        /// Where the bottom is below the baseline
        int descent() const {
            return TTF_FontDescent(_trueTypeFont);
        }
        /// Distance between each baselines
        int lineSkip() const {
            return TTF_FontLineSkip(_trueTypeFont);
        }
    }

    /// Copy ctor
    this(TrueTypeFont font) {
        _trueTypeFont = font._trueTypeFont;
        _name = font._name;
        _size = font._size;
        _outline = font._outline;
        _ownData = false;
    }

    /// Ctor
    this(const string path, int size_ = 12u, int outline_ = 0) {
        _size = size_;
        _outline = outline_;
        enforce(_size != 0u, "can't render a font with no size");
        if (null != _trueTypeFont && _ownData)
            TTF_CloseFont(_trueTypeFont);

        _trueTypeFont = TTF_OpenFont(toStringz(path), _size);
        enforce(_trueTypeFont, "can't load \'" ~ path ~ "\' font");

        TTF_SetFontKerning(_trueTypeFont, 1);

        _name = to!string(fromStringz(TTF_FontFaceFamilyName(_trueTypeFont)));
        _ownData = true;
    }

    /// Init from buffer
    this(const ubyte[] buffer, int size_ = 12u, int outline_ = 0) {
        SDL_RWops* rw = SDL_RWFromConstMem(buffer.ptr, cast(int) buffer.length);
        _size = size_;
        _outline = outline_;

        enforce(_size != 0u, "can't render a font with no size");
        if (null != _trueTypeFont && _ownData)
            TTF_CloseFont(_trueTypeFont);
        _trueTypeFont = TTF_OpenFontRW(rw, 1, _size);
        enforce(_trueTypeFont, "can't load font");

        TTF_SetFontKerning(_trueTypeFont, 1);

        _name = to!string(fromStringz(TTF_FontFaceFamilyName(_trueTypeFont)));
        _ownData = true;
    }

    ~this() {
        if (null != _trueTypeFont && _ownData)
            TTF_CloseFont(_trueTypeFont);
    }

    private Glyph cache(dchar ch) {
        int xmin, xmax, ymin, ymax, advance;
        TTF_SetFontKerning(_trueTypeFont, 1);

        if (_outline == 0) {
            if (-1 == TTF_GlyphMetrics(_trueTypeFont, cast(wchar) ch, &xmin,
                    &xmax, &ymin, &ymax, &advance)) {
                return Glyph();
            }

            SDL_Surface* surface = TTF_RenderGlyph_Blended(_trueTypeFont,
                cast(wchar) ch, Color.white.toSDL());
            enforce(surface);
            Texture texture = new Texture(surface, TextureType.sprite);
            SpritePool spritePool = new SpritePool(texture);
            // @TODO reference sprite pool in UI manager?
            Sprite sprite = new Sprite(texture, spritePool, Clip(0, 0, texture.width, texture.height));
            enforce(sprite);
            SDL_FreeSurface(surface);

            Glyph metrics = Glyph(true, advance, 0, 0, sprite.width,
                sprite.height, 0, 0, sprite.width, sprite.height, sprite);
            _cache[ch] = metrics;
            return metrics;
        } else {
            if (-1 == TTF_GlyphMetrics(_trueTypeFont, cast(wchar) ch, &xmin,
                    &xmax, &ymin, &ymax, &advance))
                return Glyph();

            TTF_SetFontOutline(_trueTypeFont, _outline);
            SDL_Surface* surfaceOutline = TTF_RenderGlyph_Blended(_trueTypeFont,
                cast(wchar) ch, Color.black.toSDL());
            enforce(surfaceOutline);

            TTF_SetFontOutline(_trueTypeFont, 0);

            SDL_Surface* surface = TTF_RenderGlyph_Blended(_trueTypeFont,
                cast(wchar) ch, Color.white.toSDL());
            enforce(surface);

            SDL_Rect srcRect = {0, 0, surface.w, surface.h};
            SDL_Rect dstRect = {_outline, _outline, surface.w, surface.h};

            SDL_BlitSurface(surface, &srcRect, surfaceOutline, &dstRect);

            Texture texture = new Texture(surfaceOutline, TextureType.sprite);
             SpritePool spritePool = new SpritePool(texture);
            // @TODO reference sprite pool in UI manager?
            Sprite sprite = new Sprite(texture, spritePool, Clip(0, 0, texture.width, texture.height));
            enforce(sprite);

            SDL_FreeSurface(surface);
            SDL_FreeSurface(surfaceOutline);

            Glyph metrics = Glyph(true, advance, 0, 0, sprite.width,
                sprite.height, 0, 0, sprite.width, sprite.height, sprite);
            _cache[ch] = metrics;
            return metrics;
        }
    }

    int getKerning(dchar prevChar, dchar currChar) {
        return TTF_GetFontKerningSizeGlyphs(_trueTypeFont,
            cast(ushort) prevChar, cast(ushort) currChar);
    }

    Glyph getMetrics(dchar ch) {
        Glyph* metrics = ch in _cache;

        if (metrics) {
            return *metrics;
        }
        return cache(ch);
    }
}
*/
