/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.capsule;

import std.conv : to;
import std.algorithm.comparison : min, max;
import std.math : ceil, abs;

import runa.core;

import runa.render.graphic;
import runa.render.renderer;
import runa.render.writabletexture;

final class Capsule : Graphic {
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

    this(Capsule capsule) {
        super(capsule);
        _sizeX = capsule._sizeX;
        _sizeY = capsule._sizeY;
        _filled = capsule._filled;
        _thickness = capsule._thickness;
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
        rasterData.radius = min(_sizeX, _sizeY) / 2f;
        rasterData.filled = _filled;
        rasterData.thickness = _thickness;

        _cache.write(function(uint* dest, uint*, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            int corner = cast(int) data.radius;
            const offsetY = (texHeight - corner) * texWidth;
            const texInternalW = texWidth - (corner * 2);

            if (data.filled) {
                // Coins supérieurs
                for (int iy; iy < corner; ++iy) {
                    // Coin haut gauche
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(vec2(corner, corner));
                        float value = clamp(dist - corner, 0f, 1f);

                        dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) lerp(255f, 0f, value));
                    }

                    // Coin haut droite
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(vec2(0f, corner));
                        float value = clamp(dist - corner, 0f, 1f);

                        dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }
                }

                // Coins inférieurs
                for (int iy; iy < corner; ++iy) {
                    // Coin bas gauche
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(vec2(corner, 0f));
                        float value = clamp(dist - corner, 0f, 1f);

                        dest[iy * texWidth + ix + offsetY] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }

                    // Coin bas droite
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(vec2.zero);
                        float value = clamp(dist - corner, 0f, 1f);

                        dest[(iy + 1) * texWidth + ix + offsetY - corner] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }
                }

                // Bord supérieur
                for (int iy; iy < corner; ++iy) {
                    for (int ix; ix < texInternalW; ++ix) {
                        dest[iy * texWidth + ix + corner] = 0xFFFFFFFF;
                    }
                }

                // Bord inférieur
                for (int iy; iy < corner; ++iy) {
                    for (int ix; ix < texInternalW; ++ix) {
                        dest[iy * texWidth + ix + corner + offsetY] = 0xFFFFFFFF;
                    }
                }

                // Bords latéraux
                for (int iy = corner; iy < (texHeight - corner); ++iy) {
                    // Bord gauche
                    for (int ix; ix < corner; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }

                    // Bord droite
                    for (int ix; ix < corner; ++ix) {
                        dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFFFF;
                    }
                }

                // Centre
                for (int iy = corner; iy < (texHeight - corner); ++iy) {
                    for (int ix = corner; ix < (texWidth - corner); ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }
                }
            }
            else {
                const int thickness = cast(int) data.thickness;
                const float halfThickness = data.thickness / 2f - .5f;

                // Coins supérieurs
                for (int iy; iy < corner; ++iy) {
                    // Coin haut gauche
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy);
                        float dist = point.distance(vec2(corner, corner));
                        float value = clamp(abs((dist + halfThickness) - data.radius) - halfThickness,
                            0f, 1f);

                        dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) lerp(255f, 0f, value));
                    }

                    // Coin haut droite
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix + 1f, iy);
                        float dist = point.distance(vec2(0f, corner));
                        float value = clamp(abs((dist + halfThickness) - data.radius) - halfThickness,
                            0f, 1f);

                        dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }
                }

                // Coins inférieurs
                for (int iy; iy < corner; ++iy) {
                    // Coin bas gauche
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix, iy + 1f);
                        float dist = point.distance(vec2(corner, 0f));
                        float value = clamp(abs((dist + halfThickness) - data.radius) - halfThickness,
                            0f, 1f);

                        dest[iy * texWidth + ix + offsetY] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }

                    // Coin bas droite
                    for (int ix; ix < corner; ++ix) {
                        vec2 point = vec2(ix + 1f, iy + 1f);
                        float dist = point.distance(vec2.zero);
                        float value = clamp(abs((dist + halfThickness) - data.radius) - halfThickness,
                            0f, 1f);

                        dest[(iy + 1) * texWidth + ix + offsetY - corner] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                            0f, value));
                    }
                }

                // Bord supérieur
                for (int iy; iy < thickness; ++iy) {
                    for (int ix; ix < texInternalW; ++ix) {
                        dest[iy * texWidth + ix + corner] = 0xFFFFFFFF;
                    }
                }

                // Bord inférieur
                for (int iy = (corner - thickness); iy < corner; ++iy) {
                    for (int ix; ix < texInternalW; ++ix) {
                        dest[iy * texWidth + ix + corner + offsetY] = 0xFFFFFFFF;
                    }
                }

                // Bords latéraux
                for (int iy = corner; iy < (texHeight - corner); ++iy) {
                    // Bord gauche
                    for (int ix; ix < thickness; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFFFF;
                    }

                    // Bord droite
                    for (int ix = (corner - thickness); ix < corner; ++ix) {
                        dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFFFF;
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
