module magia.shape.rect;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.main;
import magia.render.data;
import magia.render.entity;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;
import magia.render.window;

/// Instance of rectangle
final class Rect : Entity2D {
    @property {
        /// Rectangle size
        vec2 size() {
            return vec2(material.clip.width, material.clip.height);
        }
    }

    /// Copy constructor
    this(Rect other) {
        material = other.material;
    }

    /// Constructor given an image path
    this(vec2i size, Color color) {
        transform = Transform2D.identity;
        material.clip = Clip(0, 0, size.x, size.y);
        material.color = color;
    }

    /// Draw the rectangle on the screen
    override void draw(Renderer2D renderer) {
        renderer.drawRectangle(material, getTransformModel(renderer));
    }

    private mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }
}
