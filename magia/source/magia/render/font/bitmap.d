/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.render.font.bitmap;

import bindbc.sdl;

import magia.core;
import magia.render.sprite;
import magia.render.texture;
import magia.render.font.font, magia.render.font.glyph;

/*
/// Police de caractères formé depuis une texture
final class BitmapFont : Font, Resource!BitmapFont {
    private {
        ImageData _imageData;

        /// Taille de la police;
        int _size;

        /// Hauteur depuis la ligne (positif)
        int _ascent;

        /// Descente sous la ligne (négatif)
        int _descent;

        Metrics[dchar] _metrics;
        Glyph[dchar] _cache;
    }

    private final class Metrics {
        /// Distance horizontale depuis l’origine du caractère jusqu’au suivant
        int advance;

        /// Distance depuis l’origine du caractère à dessiner
        int offsetX, offsetY;

        /// Taille totale du caractère
        int width, height;

        /// Coordonnées dans la texture
        int posX, posY;

        /// Kerning
        int[dchar] kerning;
    }

    @property {
        /// Taille de la police
        int size() const {
            return _size;
        }
        /// Hauteur au dessus de la ligne
        int ascent() const {
            return _ascent;
        }
        /// Descente au dessous de la ligne
        int descent() const {
            return _descent;
        }
        /// Distance verticale entre chaque lignes
        int lineSkip() const {
            return (_ascent - _descent) + 1;
        }
        /// Taille de la bordure
        int outline() const {
            return 0;
        }
    }

    /// Init
    this(ImageData imageData, int size_, int ascent_, int descent_) {
        _imageData = imageData;
        _size = size_;
        _ascent = ascent_;
        _descent = descent_;
    }

    BitmapFont fetch() {
        return this;
    }

    void addCharacter(dchar ch, int advance, int offsetX, int offsetY, int width,
        int height, int posX, int posY, dchar[] kerningChar, int[] kerningOffset) {
        Metrics metrics = new Metrics;
        metrics.advance = advance;
        metrics.offsetX = offsetX;
        metrics.offsetY = offsetY;
        metrics.width = width;
        metrics.height = height;
        metrics.posX = posX;
        metrics.posY = posY;

        int count = cast(int) kerningChar.length;
        if (count > kerningOffset.length)
            count = cast(int) kerningOffset.length;

        for (int i; i < count; i++) {
            metrics.kerning[kerningChar[i]] = kerningOffset[i];
        }
        _metrics[ch] = metrics;
    }

    int getKerning(dchar prevChar, dchar currChar) {
        Metrics* metrics = currChar in _metrics;

        if (!metrics)
            return 0;

        int* kerning = prevChar in metrics.kerning;
        return kerning ? *kerning : 0;
    }

    private Glyph _cacheGlyph(dchar ch) {
        Metrics* metrics = ch in _metrics;
        Glyph glyph;

        if (metrics) {
            glyph = new BasicGlyph(true, metrics.advance, metrics.offsetX, metrics.offsetY,
                metrics.width, metrics.height, metrics.posX, metrics.posY,
                metrics.width, metrics.height, _imageData);
        }
        else {
            glyph = new BasicGlyph();
        }
        _cache[ch] = glyph;
        return glyph;
    }

    Glyph getGlyph(dchar ch) {
        Glyph* glyph = ch in _cache;
        if (glyph)
            return *glyph;
        return _cacheGlyph(ch);
    }
}
*/

/*
/// Font from a texture atlas.
final class BitmapFont : Font {
    private {
        string _name;
        Sprite _sprite;
        Metrics _metrics;
    }

    /// Glyphs metrics
    struct Metrics {
        /// Size of the font
        int size;

        /// How much the font rises from the baseline (Positive value)
        int ascent;

        /// How much the font drops below the baseline (Negative value)
        int descent;

        /// All the characters defined in the font
        int[] chars;

        /// Horizontal distance from the origin of the current character to the next
        int[] advance;

        /// Distance from the origin of the character to draw \
        /// Positive value = offset to the right
        int[] offsetX;

        /// Distance from the origin of the character to draw \
        /// Positive value = offset to the top
        int[] offsetY;

        /// Total width of the character
        int[] width;

        /// Total height of the character
        int[] height;

        /// Left coordinate of the glyph in the texture
        int[] packX;

        /// Top coordinate of the glyph in the texture
        int[] packY;

        /// Array of triple values (3 times the length of kerningCount) \
        /// Organised like this `..., PreviousChar, CurrentChar, OffsetX, ...`
        int[] kerning;

        /// The number of kerning triplets (a third of the size of the kerning array)
        int kerningCount;
    }

    /// Load from metrics and texture.
    this(string name_, Texture texture, Metrics metrics) {
        _name = name_;
        _metrics = metrics;
        _sprite = new Sprite(texture);
    }

    /// Copy ctor
    this(BitmapFont font) {
        _name = font._name;
        _metrics = font._metrics;
        _sprite = new Sprite(font._sprite);
    }

    @property {
        /// Font name
        string name() const {
            return _name;
        }
        /// Default font size
        int size() const {
            return _metrics.size;
        }
        /// Where the top is above the baseline
        int ascent() const {
            return _metrics.ascent;
        }
        /// Where the bottom is below the baseline
        int descent() const {
            return _metrics.descent;
        }
        /// Distance between each baselines
        int lineSkip() const {
            return (_metrics.ascent - _metrics.descent) + 1;
        }
    }

    int getKerning(dchar prevChar, dchar currChar) {
        for (int i; i < _metrics.kerningCount; ++i) {
            const int index = i * 3;
            if (_metrics.kerning[index] == prevChar && _metrics.kerning[index + 1] == currChar) {
                return _metrics.kerning[index + 2];
            }
        }
        return 0;
    }

    Glyph getMetrics(dchar character) {
        for (int i; i < _metrics.chars.length; ++i) {
            if (_metrics.chars[i] == character) {
                Glyph metrics = Glyph(true, _metrics.advance[i], _metrics.offsetX[i],
                    _metrics.offsetY[i], _metrics.width[i], _metrics.height[i],
                    _metrics.packX[i], _metrics.packY[i], _metrics.width[i],
                    _metrics.height[i], _sprite);
                return metrics;
            }
        }
        return Glyph();
    }
}
*/