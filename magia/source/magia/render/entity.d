module magia.render.entity;

import magia.core.transform;
import magia.render.material;

/// An instance is an item with a transform that can be updated
abstract class Instance {
    /// Transform stating where the instance is located
    Transform transform;

    /// Update the object (given a deltaTime)
    void update(float) {}
}

/// An entity is a drawable instance
abstract class Entity : Instance {
    /// Material stating how to render the item
    Material material;

    /// Render on screen
    void draw() {}
}