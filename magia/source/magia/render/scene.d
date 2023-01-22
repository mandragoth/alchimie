module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core.timestep;
import magia.render.camera;
import magia.render.entity;
import magia.render.renderer;

alias Entities = Entity[];

/// Scene class
class Scene {
    private {
        /// @TODO replace entity array with hierarchy
        Entities _entities;
    }

    @property {
        /// Set camera
        void camera(Camera camera) {
            renderer.camera = camera;
        }
    }

    /// Constructor
    this() {
        renderer = new Renderer(new OrthographicCamera());
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
    void update(TimeStep timeStep) {
        renderer.update(timeStep);

        foreach(entity; _entities) {
            entity.update(timeStep);
        }
    }

    /// Draw scene
    void draw() {
        foreach(entity; _entities) {
            entity.draw();
        }
    }
}
