module runa.ui.label;

import std.algorithm.comparison : min;
import std.conv : to;
import std.stdio;

import runa.core;
import runa.render;
import runa.ui.element;

/// Label
final class Label : UIElement {
    private {
        dstring _text;
        Font _font;
        float _charScale = 1f, _charSpacing = 0f;
    }

    @property {
        /// Texte affiché
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            reload();
            return text_;
        }

        /// La police de caractère utilisée
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            reload();
            return _font;
        }

        /// Espacement additionnel entre chaque lettre
        float charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        float charSpacing(float charSpacing_) {
            return _charSpacing = charSpacing_;
        }
    }

    /// Constructor
    this(string text_ = "", Font font_ = getDefaultFont()) {
        _text = to!dstring(text_);
        _font = font_;
        reload();
    }

    override void draw() {
        vec2 pos = vec2.zero;
        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                pos.x = 0f;
                pos.y += _font.lineSkip * _charScale;
                prevChar = 0;
            } else {
                Glyph metrics = _font.getMetrics(ch);
                if (!metrics.exists)
                    continue;
                pos.x += _font.getKerning(prevChar, ch) * _charScale;

                float x = pos.x + metrics.offsetX * _charScale;
                float y = pos.y - metrics.offsetY * _charScale;

                metrics.draw(x, y, _charScale, Color.white, 1f);
                pos.x += (metrics.advance + _charSpacing) * _charScale;
                prevChar = ch;
            }
        }
    }

    private void reload() {
        vec2 totalSize_ = vec2(0f, _font.ascent - _font.descent) * _charScale;
        float lineWidth = 0f;

        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * _charScale;
            } else {
                const Glyph metrics = _font.getMetrics(ch);
                lineWidth += _font.getKerning(prevChar, ch) * _charScale;
                lineWidth += metrics.advance * _charScale;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }

        sizeX = totalSize_.x;
        sizeY = totalSize_.y;
    }
}
