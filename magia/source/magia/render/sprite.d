module magia.render.sprite;

import std.exception;
import std.path;
import std.string;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.render.entity;
import magia.render.material;
import magia.render.renderer;
import magia.render.scene;
import magia.render.texture;
import magia.render.window;

/// Base rendering class.
final class Sprite : Entity2D {
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
    this(string name, SDL_Surface* surface) {
        Texture texture = new Texture(name, surface);
        material = new Material(texture);
        /// @TODO pass UIElement alignment HERE!!!
    }

    /// Constructor given an image path
    this(string fileName, vec4i clip = vec4i.zero) {
        transform = Transform2D.identity;
        Texture texture = fetchPrototype!Texture(fileName);
        material = new Material(texture);
        material.clip = clip;
        alignment = CoordinateSystem.topLeft;
    }

    /// Draw the sprite on the screen
    override void draw(Renderer2D renderer) {
        Transform2D worldTransfrom = alignment.toRenderSpace(globalPosition, size, renderer.window.screenSize);
        renderer.drawMaterial(material, worldTransfrom);
    }
}