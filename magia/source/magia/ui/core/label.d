module magia.ui.core.label;

import std.algorithm.comparison : min;
import std.conv : to;

import magia.core;
import magia.render;
import magia.ui.core.element;

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
    this(string text_ = "", Font font_) {
        _text = to!dstring(text_);
        _font = font_;
        reload();
    }
/*
    override void draw(Renderer2D renderer) {
        Color color = Color.white;
        vec2f pos = vec2f.zero;

        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                pos.x = transform.position.x;
                pos.y += _font.lineSkip * _charScale;
                prevChar = 0;
            } else {
                Glyph metrics = _font.getGlyph(ch);
                pos.x += _font.getKerning(prevChar, ch) * _charScale;

                Transform2D glyphTransform;
                transform.position.x = pos.x + metrics.offsetX * _charScale;
                transform.position.y = pos.y + metrics.offsetY * _charScale;
                transform.scale *= _charScale;

                metrics.draw(renderer, glyphTransform, color, alpha);
                pos.x += (metrics.advance + _charSpacing) * _charScale;
                prevChar = ch;
            }
        }
    }*/

    private void reload() {
        /*vec2f totalSize_ = vec2f(0f, _font.ascent - _font.descent) * _charScale;
        float lineWidth = 0f;

        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * _charScale;
            } else {
                const Glyph metrics = _font.getGlyph(ch);
                lineWidth += _font.getKerning(prevChar, ch) * _charScale;
                lineWidth += metrics.advance * _charScale;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }

        size.x = totalSize_.x;
        size.y = totalSize_.y;*/
    }
}
