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
class Scene {
    /// Main camera
    Camera camera;

    private {
        /// @TODO replace entity array with hierarchy
        Entities _entities;
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