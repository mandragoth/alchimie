module runa.render.font.text;

import std.conv : to;

import runa.render.font.def, runa.render.font.glyph;

/// Render text on screen
/+void drawText(string text, vec2 start, Color color, float alpha = 1f, Font font = null) {
    if (!font)
        font = getDefaultFont();
    const _charScale = 1;
    const _charSpacing = 0;
    vec2 pos = start;
    dchar prevChar;
    foreach (dchar ch; to!dstring(text)) {
        if (ch == '\n') {
            pos.x = start.x;
            pos.y += font.lineSkip * _charScale;
            prevChar = 0;
        }
        else {
            Glyph metrics = font.getMetrics(ch);
            pos.x += font.getKerning(prevChar, ch) * _charScale;
            vec2 drawPos = vec2(pos.x + metrics.offsetX * _charScale,
                    pos.y - metrics.offsetY * _charScale);
            metrics.draw(drawPos, _charScale, color, alpha);
            pos.x += (metrics.advance + _charSpacing) * _charScale;
            prevChar = ch;
        }
    }
}

/// Returns the size of the text if it was rendered on screen
vec2 getTextSize(string text, Font font = null) {
    if (!font)
        font = getDefaultFont();
    const _charScale = 1;
    const _charSpacing = 0;
    vec2 size = vec2(0f, font.ascent - font.descent) * _charScale;
    float pos = 0f;
    dchar prevChar;
    foreach (dchar ch; to!dstring(text)) {
        if (ch == '\n') {
            pos = 0;
            size.y += font.lineSkip * _charScale;
            prevChar = 0;
        }
        else {
            Glyph metrics = font.getMetrics(ch);
            pos += font.getKerning(prevChar, ch) * _charScale;
            pos += (metrics.advance + _charSpacing) * _charScale;
            if (pos > size.x)
                size.x = pos;
            prevChar = ch;
        }
    }
    return size;
}+/
