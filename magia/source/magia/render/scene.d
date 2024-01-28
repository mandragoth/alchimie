module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core.timestep;
import magia.core.transform;
import magia.render.camera;
import magia.render.drawable;
import magia.render.renderer;
import magia.render.skybox;
import magia.render.updatable;

/// Scene class
class Scene(uint dimension_) {
    alias Updatables = Updatable[];
    alias Drawables = Drawable!(dimension_)[];

    private {
        Renderer!(dimension_) _renderer;
        Updatables _updatables;
        Drawables _drawables;
    }

    /// Constructor
    this(Renderer!(dimension_) renderer) {
        _renderer = renderer;
    }

    /// Add an updatable object
    void addUpdatable(Updatable updatable) {
        _updatables ~= updatable;
    }

    /// Add a drawable object
    void addDrawable(Drawable!(dimension_) drawable) {
        _drawables ~= drawable;
    }

    /// Update scene
    void update() {
        foreach(updatable; _updatables) {
            updatable.update();
        }
    }

    /// Draw scene
    void draw() {
        _renderer.setup();

        // Draw each drawable
        foreach(drawable; _drawables) {
            drawable.draw(_renderer);
        }
    }
}

alias Scene2D = Scene!(2);
alias Scene3D = Scene!(3);