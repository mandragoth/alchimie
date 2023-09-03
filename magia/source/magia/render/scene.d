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
class Scene(type, uint dimension_) {
    alias Entities = Entity!(type, dimension_)[];

    private {
        Entities _entities;
        Skybox _skybox;
    }

    /// Constructor
    this() {
        _skybox = new Skybox();
    }

    /// Add an entity
    void addEntity(Entity!(type, dimension_) entity) {
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
        foreach(entity; _entities) {
            entity.draw();
        }

        _skybox.draw();
    }
}

alias Scene2D = Scene!(float, 2);
alias Scene3D = Scene!(float, 3);