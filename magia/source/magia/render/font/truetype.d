/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.render.font.truetype;

import std.conv : to;
import std.exception : enforce;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

import magia.core;
import magia.render.sprite;
import magia.render.texture;
import magia.render.font.font;
import magia.render.font.glyph;

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
            Sprite sprite = new Sprite(texture, spritePool, vec4i(0, 0, texture.width, texture.height));
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
            Sprite sprite = new Sprite(texture, spritePool, vec4i(0, 0, texture.width, texture.height));
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
