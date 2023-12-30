module magia.render.sprite;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.main;
import magia.render.entity;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;
import magia.render.window;

import std.stdio;

/// Base rendering class.
final class Sprite : Entity2D, Resource!Sprite {
    private {
        // @TODO remove texture here
        Texture _texture;
    }

    @property {
        /// Width
        uint width() {
            return material.clip.width;
        }

        /// Height
        uint height() {
            return material.clip.height;
        }

        /// Size
        vec2 size() {
            return vec2(material.clip.width, material.clip.height);
        }

        /// Clip as float
        vec4 clipf() {
            // Default clip has x, y = 0 and w, h = 1
            vec4 clipf = vec4(0f, 0f, 1f, 1f);

            // Cut texture depending on clip parameters
            if (material.clip != defaultClip) {
                clipf.x = cast(float) material.clip.x / cast(float) _texture.width;
                clipf.y = cast(float) material.clip.y / cast(float) _texture.height;
                clipf.z = clipf.x + (cast(float) material.clip.z / cast(float) _texture.width);
                clipf.w = clipf.y + (cast(float) material.clip.w / cast(float) _texture.height);
            }

            return clipf;
        }

        /// Flip as float
        vec2 flipf() {
            vec2 flipf;
            final switch (material.flip) with (Flip) {
                case none:
                    flipf = vec2.zero;
                    break;
                case horizontal:
                    flipf = vec2(1f, 0f);
                    break;
                case vertical:
                    flipf = vec2(0f, 1f);
                    break;
                case both:
                    flipf = vec2.one;
                    break;
            }

            return flipf;
        }
    }

    /// Copy constructor
    this(Sprite other) {
        _texture = other._texture;
        material = other.material;
    }

    /// Constructor given an image path
    this(Texture texture, Clip clip = defaultClip, Flip flip = Flip.none) {
        transform = Transform2D.identity;
        material.clip = clip;
        material.flip = flip;
        _texture = texture;
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    mat4 getTransformModel(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        return rendererTransform.combineModel();
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size / 2f;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        renderer.drawRectangle(_texture, material, rendererTransform.combineModel());
    }
}
