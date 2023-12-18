/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.rectangle;

import std.conv : to;

import runa.core;

import runa.render.graphic;
import runa.render.renderer;
import runa.render.writabletexture;

final class Rectangle : Graphic {
    private {
        float _sizeX = 0f, _sizeY = 0f;
        float _thickness = 1f;
        bool _filled = true;
        bool _isDirty;

        WritableTexture _cache;
    }

    @property {
        float sizeX() const {
            return _sizeX;
        }

        float sizeX(float sizeX_) {
            if (_sizeX != sizeX_) {
                _sizeX = sizeX_;
                _isDirty = true;
            }
            return _sizeX;
        }

        float sizeY() const {
            return _sizeY;
        }

        float sizeY(float sizeY_) {
            if (_sizeY != sizeY_) {
                _sizeY = sizeY_;
                _isDirty = true;
            }
            return _sizeY;
        }

        bool filled() const {
            return _filled;
        }

        bool filled(bool filled_) {
            if (_filled != filled_) {
                _filled = filled_;
                _isDirty = true;
            }
            return _filled;
        }

        float thickness() const {
            return _thickness;
        }

        float thickness(float thickness_) {
            if (_thickness != thickness_) {
                _thickness = thickness_;
                _isDirty = true;
            }
            return _thickness;
        }
    }

    this(float sizeX_, float sizeY_, bool filled_, float thickness_) {
        _sizeX = sizeX_;
        _sizeY = sizeY_;
        _filled = filled_;
        _thickness = thickness_;
        _isDirty = true;
    }

    this(Rectangle rect) {
        super(rect);
        _sizeX = rect._sizeX;
        _sizeY = rect._sizeY;
        _filled = rect._filled;
        _thickness = rect._thickness;
        _isDirty = true;
    }

    private void _cacheTexture() {
        _isDirty = false;

        _cache = (_sizeX >= 1f && _sizeY >= 1f) ? new WritableTexture(cast(uint) _sizeX,
            cast(uint) _sizeY) : null;

        if (!_cache)
            return;

        struct RasterData {
            float radius;
            float thickness;
            bool filled;
        }

        RasterData rasterData;
        rasterData.filled = _filled;
        rasterData.thickness = _thickness;

        _cache.write(function(uint* dest, uint*, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;

            if (data.filled) {
                for (int iy; iy < texHeight; ++iy) {
                    for (int ix; ix < texWidth; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }
                }
            }
            else {
                const int thickness = cast(int) data.thickness;

                // Bord supérieur
                for (int iy; iy < thickness; ++iy) {
                    for (int ix; ix < texWidth; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }
                }

                // Bord inférieur
                for (int iy = (texHeight - thickness); iy < texHeight; ++iy) {
                    for (int ix; ix < texWidth; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }
                }

                // Bords latéraux
                for (int iy = thickness; iy < (texHeight - thickness); ++iy) {
                    // Bord gauche
                    for (int ix; ix < thickness; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }

                    // Bord droite
                    for (int ix = (texWidth - thickness); ix < texWidth; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }
                }
            }
        }, &rasterData);
    }

    void draw(float x, float y) {
        if (_isDirty)
            _cacheTexture();

        if (!_cache)
            return;

        _cache.color = color;
        _cache.blend = blend;
        _cache.alpha = alpha;
        _cache.draw(x, y, _sizeX, _sizeY, vec4i(0, 0, _cache.width,
                _cache.height), angle, pivotX, pivotY, flipX, flipY);
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(float x, float y) {
        vec2 size = to!vec2(clip.zw).fit(vec2(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(float x, float y) {
        vec2 size = to!vec2(clip.zw).contain(vec2(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }
}
