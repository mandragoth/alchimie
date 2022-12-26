module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core, magia.render;
import magia.common.event;
import magia.shape.light;
import magia.shape.line;
import magia.shape.terrain;

alias Entities = Entity[];

/// Scene class
class Scene() {
    private {
        /// Default camera is also an entity
        Camera _camera;

        /// @TODO replace entity array with hierarchy
        Entities _entities;
    }

    /// Constructor
    this(Camera camera) {
        _camera = camera;
        _entities ~= camera;
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
    void update(float deltaTime) {
        foreach(entity; _entities) {
            entity.update(deltaTime);
        }
    }

    /// Draw scene
    void draw() {
        foreach(entity; _entities) {
            entity.draw();
        }
    }
}