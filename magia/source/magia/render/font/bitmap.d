/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.render.font.bitmap;

import bindbc.sdl, bindbc.sdl.ttf;
import magia.core;
import magia.render.sprite;
import magia.render.font.font, magia.render.font.glyph;

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
    this(string name_, string texturePath, Metrics metrics) {
        _name = name_;
        _metrics = metrics;
        _sprite = new Sprite(texturePath, true);
    }

    /// Copy ctor
    this(BitmapFont font) {
        _name = font._name;
        _metrics = font._metrics;
        _sprite = new Sprite(font._sprite);
    }

    /// Call only after Renderer is created in main thread.
    void postload() {
        _sprite.postload();
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
                        _metrics.offsetY[i], _metrics.width[i],
                        _metrics.height[i], _metrics.packX[i], _metrics.packY[i],
                        _metrics.width[i], _metrics.height[i], _sprite);
                return metrics;
            }
        }
        return Glyph();
    }
}
