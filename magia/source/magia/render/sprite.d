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
    @property {
        /// Temporary
        Texture texture() {
            return material.textures[0];
        }

        /// Return texture id
        int textureId() {
            return texture.id;
        }

        /// Underlying texture width
        uint width() {
            return texture.width;
        }

        /// Underlying texture height
        uint height() {
            return texture.height;
        }

        /// Underlying sprite size
        vec2 size() {
            return vec2(material.clip.width, material.clip.height);
        }
    }

    /// Copy constructor
    this(Sprite other) {
        material = other.material;
    }

    /// Constructor given an image path
    this(Texture texture, Clip clip = defaultClip) {
        transform = Transform2D.identity;
        material = new Material(texture);
        material.clip = clip;
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
        Transform2D targetTransform = globalTransform;
        targetTransform.scale *= size;

        Transform2D rendererTransform = renderer.toRenderSpace(targetTransform);
        renderer.drawMaterial(material, rendererTransform.combineModel());
    }
}
