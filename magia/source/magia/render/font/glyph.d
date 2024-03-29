module magia.render.font.glyph;

import magia.core;
import magia.render.material;
import magia.render.renderer;
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
    void draw(Renderer2D renderer, Transform2D transform, Color color, float alpha) {
        _sprite.transform = transform;
        /*_sprite.material.clip = vec4i(_packX, _packY, _packWidth, _packHeight);
        _sprite.material.color = color;
        _sprite.material.alpha = alpha;*/
        _sprite.draw(renderer);
    }
}
