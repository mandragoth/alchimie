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

/// Base rendering class.
final class Sprite : Entity2D, Resource {
    /// Alignment used to render the sprites
    CoordinateSystem alignment;

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
            return vec2(material.clip.z, material.clip.w);
        }
    }

    /// Copy constructor
    this(Sprite other) {
        material = other.material;
    }

    /// Constructor given an SDL surface
    this(SDL_Surface* surface) {
        Texture texture = new Texture(surface);
        material = new Material(texture);
        /// @TODO pass UIElement alignment HERE!!!
    }

    /// Constructor given an image path
    this(Texture texture, vec4i clip = vec4i.zero) {
        transform = Transform2D.identity;
        material = new Material(texture);
        material.clip = clip;
        alignment = CoordinateSystem.topLeft;
    }

    /// Initialisation de la ressource
    void make() {
    }

    /// Accès à la ressource
    Resource fetch() {
        return new Sprite(this);
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
        Transform2D worldTransfrom = alignment.toRenderSpace(globalPosition,
            size, renderer.window.screenSize, angle);
        renderer.drawMaterial(material, worldTransfrom);
    }
}
