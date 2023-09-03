module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core.timestep;
import magia.core.transform;
import magia.render.camera;
import magia.render.entity;
import magia.render.renderer;
import magia.render.skybox;

/// Scene class
class Scene(uint dimension_) {
    alias Entities = Entity!(dimension_)[];

    private {
        Renderer!(dimension_) _renderer;
        Entities _entities;
    }

    /// Constructor
    this(Renderer!(dimension_) renderer) {
        _renderer = renderer;
    }

    /// Add an entity
    void addEntity(Entity!(dimension_) entity) {
        _entities ~= entity;
    }

    /// Clear scene from all its entities
    void clear() {
        _entities.length = 0;
    }

    /// Update scene
    void update() {
        foreach(entity; _entities) {
            entity.update();
        }
    }

    /// Draw scene
    void draw() {
        _renderer.setup();
        foreach(entity; _entities) {
            entity.draw(_renderer);
        }
    }
}

alias Scene2D = Scene!(2);
alias Scene3D = Scene!(3);