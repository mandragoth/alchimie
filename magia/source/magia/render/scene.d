module magia.render.scene;

import std.stdio;

import bindbc.opengl;

import magia.core.timestep;
import magia.core.transform;
import magia.render.camera;
import magia.render.entity;
import magia.render.renderer;
import magia.render.skybox;

alias Entities = Entity[];

/// Hierarchy of transforms
class Hierarchy {
    /// Parent transform
    Transform *_pParent;

    /// Current transform
    Transform *_pCurrent;

    /// Children
    Hierarchy[] _aChildren;

    /// Default constructor for root
    this() {
        _pParent = null;
        _pCurrent = &identity;
    }

    /// Constructor for children
    this(Transform *pCurrent, Transform *pParent = null) {
        _pCurrent = pCurrent;
        _pParent = pParent;
    }

    /// Add a child to the current level of the hierarchy
    void addChild(Transform transform) {
        _aChildren ~= new Hierarchy(&transform, _pCurrent);
    }

    /// Remove all children
    void clear() {
        _aChildren.length = 0;
    }
}

/// Scene class
class Scene {
    private {
        Hierarchy _hierarchy;
        Entities _entities;

        Skybox _skybox;
    }

    /// Constructor
    this() {
        _skybox = new Skybox();
        _hierarchy = new Hierarchy();
    }

    /// Add an entity
    void addEntity(Entity entity) {
        _entities ~= entity;
        _hierarchy.addChild(entity.transform);
    }

    /// Clear scene from all its entities
    void clear() {
        _entities.length = 0;
        _hierarchy.clear();
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
        // Setup 3D
        renderer.setup3DRender();

        foreach(entity; _entities) {
            entity.draw();
        }

        _skybox.draw();
    }
}
