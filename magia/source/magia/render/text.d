module magia.render.text;

import std.conv : to;

import magia.core;
import magia.render.font;
import magia.render.postprocess;

/// Render text on screen
void drawText(Transform2D transform, string text, float x, float y, Font font = null) {
    if (!font) {
        font = getDefaultFont();
    }

    const _charScale = 1;
    const _charSpacing = 0;

    vec2 pos = vec2(x, y);

    dchar prevChar;
    foreach (dchar ch; to!dstring(text)) {
        if (ch == '\n') {
            pos.x = x;
            pos.y += font.lineSkip * _charScale;
            prevChar = 0;
        }
        else {
            // Get current glyph metric
            Glyph metrics = font.getMetrics(ch);

            // Get current position depending on kerning
            pos.x += font.getKerning(prevChar, ch) * _charScale;
            
            const float drawPosX = pos.x + metrics.offsetX * _charScale;
            const float drawPosY = pos.y - metrics.offsetY * _charScale;
            metrics.draw(transform, drawPosX, drawPosY, _charScale, bgColor, bgAlpha);

            // Update char position
            pos.x += (metrics.advance + _charSpacing) * _charScale;
            prevChar = ch;
        }
    }
}
