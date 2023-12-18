/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.circle;

import std.conv : to;
import std.algorithm.comparison : min, max;
import std.math : ceil, abs;

import runa.core;

import runa.render.graphic;
import runa.render.renderer;
import runa.render.writabletexture;

final class Circle : Graphic {
    private {
        float _radius = 0f;
        float _thickness = 1f;
        bool _filled = true;
        bool _isDirty;

        WritableTexture _cache;
    }

    bool noCache;

    @property {
        float radius() const {
            return _radius;
        }

        float radius(float radius_) {
            if (_radius != radius_) {
                _radius = radius_;
                _isDirty = true;
            }
            return _radius;
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

    this(float radius_, bool filled_, float thickness_) {
        _radius = radius_;
        _filled = filled_;
        _thickness = thickness_;
        _isDirty = true;
    }

    this(Circle circle) {
        super(circle);
        _filled = circle._filled;
        _radius = circle._radius;
        _thickness = circle._thickness;
        _isDirty = true;
    }

    void cache() {
        _isDirty = false;

        uint size = cast(uint) ceil(_radius * 2f);

        _cache = (_radius >= 1f) ? new WritableTexture(size, size) : null;

        if (!_cache)
            return;

        struct RasterData {
            float radius;
            float thickness;
            bool filled;
            vec2 center;
        }

        RasterData rasterData;
        rasterData.radius = _radius;
        rasterData.filled = _filled;
        rasterData.thickness = _thickness;
        rasterData.center = vec2.one * _radius;

        _cache.write(function(uint* dest, uint*, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            if (data.filled) {
                for (int iy; iy < texHeight; ++iy) {
                    for (int ix; ix < texWidth; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(data.center);
                        float value = clamp(dist - data.radius, 0f, 1f);

                        dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) lerp(255f, 0f, value));
                    }
                }
            } else {
                for (int iy; iy < texHeight; ++iy) {
                    for (int ix; ix < texWidth; ++ix) {
                        vec2 point = vec2(ix, iy) + .5f;
                        float dist = point.distance(data.center);
                        float value = clamp(abs((dist + data.thickness) - data.radius) - data.thickness,
                            0f, 1f);

                        dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) lerp(255f, 0f, value));
                    }
                }
            }
        }, &rasterData);
    }

    void draw(float x, float y) {
        if (_isDirty && !noCache)
            cache();

        if (!_cache)
            return;

        _cache.color = color;
        _cache.blend = blend;
        _cache.alpha = alpha;
        _cache.draw(x - (anchorX * _radius), y - (anchorY * _radius), _radius,
            _radius, vec4i(0, 0, _cache.width, _cache.height), angle, pivotX,
            pivotY, flipX, flipY);
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(float x, float y) {
        _radius = min(x, y);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(float x, float y) {
        _radius = max(x, y);
    }
}
