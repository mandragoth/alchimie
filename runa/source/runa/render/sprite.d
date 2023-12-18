/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.sprite;

import std.conv : to;

import runa.core;
import runa.render.graphic;
import runa.render.texture;
import runa.render.util;

final class Sprite : Graphic, Resource!Sprite {
    private {
        Texture _texture;
    }

    float sizeX = 0f, sizeY = 0f;

    @property {
        pragma(inline) uint width() const {
            return _texture.width;
        }

        pragma(inline) uint height() const {
            return _texture.height;
        }
    }

    this(Texture tex, vec4i clip_) {
        _texture = tex;
        clip = clip_;
        sizeX = _texture.width;
        sizeY = _texture.height;
    }

    this(Sprite other) {
        super(other);
        _texture = other._texture;
        sizeX = other.sizeX;
        sizeY = other.sizeY;
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    void draw(float x, float y) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, clip, angle, pivotX, pivotY, flipX, flipY);
    }

    /// Redimensionne l’sprite pour qu’elle puisse tenir dans une taille donnée
    override void fit(float x, float y) {
        vec2 size = to!vec2(clip.zw).fit(vec2(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }

    /// Redimensionne l’sprite pour qu’elle puisse contenir une taille donnée
    override void contain(float x, float y) {
        vec2 size = to!vec2(clip.zw).contain(vec2(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }
}
