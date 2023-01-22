module magia.render.font.glyph;

import magia.core;
import magia.render.material;
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

    /// Render glyph (@TODO rewrite?)
    void draw(mat4 transform, float posX, float posY, float scale, Color color, float alpha) {
        _sprite.transform = Transform(transform);
        _sprite.position = vec2(posX, posY);
        _sprite.size = vec2(_width * scale, _height * scale);
        _sprite.clip = vec4i(_packX, _packY, _packWidth, _packHeight);
        _sprite.color = color;
        _sprite.alpha = alpha;
        _sprite.draw();
    }
}
