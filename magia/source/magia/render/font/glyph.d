module magia.render.font.glyph;

import magia.core;
import magia.render.sprite;
import magia.render.window;

/// Information about a single character
struct Glyph {
    @property {
        /// Is the character defined ?
        bool exists() const {
            return _exists;
        }
        /// Width to advance cursor from previous position.
        int advance() const {
            return _advance;
        }
        /// Offset
        int offsetX() const {
            return _offsetX;
        }
        /// Ditto
        int offsetY() const {
            return _offsetY;
        }
        /// Character size
        int width() const {
            return _width;
        }
        /// Ditto
        int height() const {
            return _height;
        }
    }

    private {
        bool _exists;
        /// Width to advance cursor from previous position.
        int _advance;
        /// Offset
        int _offsetX, _offsetY;
        /// Character size
        int _width, _height;
        /// Coordinates in texture
        int _packX, _packY, _packWidth, _packHeight;
        /// Sprite
        Sprite _sprite;
    }

    /// Render glyph
    void draw(mat4 transform, float posX, float posY, float scale, Color color, float alpha) {
        _sprite.draw(transform, posX, posY, _width * scale, _height * scale,
                     vec4i(_packX, _packY, _packWidth, _packHeight),
                     Flip.none, Blend.alpha, color, alpha);
    }
}
