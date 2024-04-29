module magia.render.font.glyph;

import magia.core;
import magia.render.material;
import magia.render.renderer;
import magia.render.sprite;
import magia.render.texture;
import magia.render.window;
/*
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
}*/

/// Information about a single character
interface Glyph {
    @property {
        /// Is the character defined ?
        bool exists() const;
        /// Width to advance cursor from previous position.
        int advance() const;
        /// Offset
        int offsetX() const;
        /// Ditto
        int offsetY() const;
        /// Character size
        int width() const;
        /// Ditto
        int height() const;
    }

    /// Render glyph
    void draw(Renderer2D renderer, Transform2D transform, Color color, float alpha);
}

/// Ditto
final class BasicGlyph : Glyph {
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
        /// ImageData
        Sprite _sprite;
    }

    this() {
        _exists = false;
    }

    this(bool exists_, int advance_, int offsetX_, int offsetY_, int width_,
        int height_, int packX_, int packY_, int packWidth_, int packHeight_, Texture texture, SpritePool spritePool) {
        _exists = exists_;
        _advance = advance_;
        _offsetX = offsetX_;
        _offsetY = offsetY_;
        _width = width_;
        _height = height_;
        _packX = packX_;
        _packY = packY_;
        _packWidth = packWidth_;
        _packHeight = packHeight_;
        _sprite = new Sprite(texture, spritePool, vec4u(_packX, _packY, _width, _height));
    }

    /// Render glyph
    /*void draw(Vec2f position, float scale, Color color, float alpha) {
        _imageData.color = color;
        _imageData.blend = Blend.alpha;
        _imageData.alpha = alpha;
        _imageData.draw(position, Vec2f(_width * scale, _height * scale),
            Vec4u(_packX, _packY, _packWidth, _packHeight), 0f);
    }*/
    

    /// Render glyph (@TODO rewrite?)
    void draw(Renderer2D renderer, Transform2D transform, Color color, float alpha) {
        _sprite.transform = transform;
        /*_sprite.material.clip = vec4i(_packX, _packY, _packWidth, _packHeight);
        _sprite.material.color = color;
        _sprite.material.alpha = alpha;*/
        _sprite.draw(renderer);
    }
}
