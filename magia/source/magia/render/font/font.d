module magia.render.font.font;

import magia.core;
import magia.render.sprite;
import magia.render.font.glyph;
import magia.render.font.truetype;
import magia.render.font.vera;
/*
private {
    Font _defaultFont, _veraFont;
}

/// Initialize the default font
void initFont() {
    _veraFont = new TrueTypeFont(veraFontData, 26, 2);
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
}*/

/// Font that renders text to texture.
interface Font {
    @property {
        /// Taille de la police
        int size() const;
        /// Jusqu’où peut monter un caractère au-dessus la ligne
        int ascent() const;
        /// Jusqu’où peut descendre un caractère en-dessous la ligne
        int descent() const;
        /// Distance entre chaque ligne
        int lineSkip() const;
        /// Taille de la bordure
        int outline() const;
    }

    int getKerning(dchar prevChar, dchar currChar);

    Glyph getGlyph(dchar character);
}
