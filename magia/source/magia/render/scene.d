module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core.timestep;
import magia.render.camera;
import magia.render.entity;
import magia.render.renderer;
import magia.render.skybox;

alias Entities = Entity[];

/// Scene class
class Scene {
    private {
        /// @TODO replace entity array with hierarchy
        Entities _entities;

        Skybox _skybox;
    }

    /// Constructor
    this() {
        renderer = new Renderer();
        _skybox = new Skybox();
    }

    /// Add an entity
    void addEntity(Entity entity) {
        _entities ~= entity;
    }

    /// Clear scene from all its entities
    void clear() {
        _entities.length = 0;
    }

    /// Update scene
    void update() {
        renderer.update();

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
