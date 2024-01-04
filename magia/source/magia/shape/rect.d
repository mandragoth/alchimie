module magia.shape.rect;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.main;
import magia.render.data;
import magia.render.drawable;
import magia.render.entity;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;
import magia.render.window;

// Instance data
struct RectData {
    mat4 model;
    vec4 clip;
    Color color;
    float alpha;
}

class RectPool : Drawable2D {
    mixin Singleton;

    private {
        Rect[] _rectangles;
        RectData[] _rectData;
    }

    /// Add a rect to the pool
    void addRect(Rect rect) {
        _rectangles ~= rect;
    }

    /// Add rect data to the pool
    void addRectData(RectData rectData) {
        _rectData ~= rectData;
    }

    /// Draw all rectangles held by the pool
    void draw(Renderer2D renderer) {
        foreach(Rect rect; _rectangles) {
            rect.draw(renderer);
        }

        if (_rectData.length) {
            renderer.drawRectangles(_rectData);
        }

        _rectData.length = 0;
    }
}

/// Instance of rectangle
final class Rect : Entity2D {
    private {
        RectData _rectData;
    }

    @property {
        /// Size
        vec2 size() const {
            return vec2(_rectData.clip.width, _rectData.clip.height);
        }
    }

    /// Copy constructor
    this(Rect other) {
        _rectData = other._rectData;
    }

    /// Constructor given an image path
    this(vec2u size, Color color) {
        transform = Transform2D.identity;

        // Clip
        _rectData.clip = vec4(0f, 0f, cast(float)size.x, cast(float)size.y);

        // Color and alpha
        _rectData.color = color;
        _rectData.alpha = 1f;
    }

    /// Subscribe to related pool
    void register() {
        RectPool().addRect(this);
    }

    /// Draw the rectangle on the screen
    override void draw(Renderer2D renderer) {
        // Reference model for draw call
        _rectData.model = getTransformModel(renderer).transposed;

        // Add instance data to the pool list
        RectPool().addRectData(_rectData);
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
