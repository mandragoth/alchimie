module runa.render.font.def;

import runa.core;
import runa.render.texture;
import runa.render.font.glyph;
import runa.render.font.truetype;
import runa.render.font.vera;

private {
    Font _defaultFont, _veraFont;
}

/// Initialize the default font
void initFont() {
    _veraFont = new TrueTypeFont(veraFontData);
    _defaultFont = _veraFont;
}

void setDefaultFont(Font font) {
    if (!font) {
        _defaultFont = _veraFont;
        return;
    }

    _defaultFont = font;
}

Font getDefaultFont() {
    return _defaultFont;
}

/// Font that renders text to texture.
interface Font {
    @property {
        /// Font name
        string name() const;
        /// Default font size
        int size() const;
        /// Where the top is above the baseline
        int ascent() const;
        /// Where the bottom is below the baseline
        int descent() const;
        /// Distance between each baselines
        int lineSkip() const;
    }

    int getKerning(dchar prevChar, dchar currChar);

    Glyph getMetrics(dchar character);
}
