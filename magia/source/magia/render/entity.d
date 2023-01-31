module magia.render.entity;

import magia.core;
import magia.render.material;
import magia.render.texture;

/// An instance is an item with a transform that can be updated
abstract class Instance {
    /// Transform stating where the instance is located
    Transform transform;

    @property {
        /// Set position (2D)
        void position(vec2 position_) {
            transform.position = vec3(position_, 0f);
        }

        /// Set position (3D)
        void position(vec3 position_) {
            transform.position = position_;
        }

        /// Get position (2D)
        vec2 position2D() {
            return vec2(transform.position.x, transform.position.y);
        }

        /// Get position (3D)
        vec3 position() {
            return transform.position;
        }

        /// Set scale (2D)
        void scale(vec2 scale_) {
            transform.scale = vec3(scale_, 0f);
        }

        /// Set scale (3D)
        void scale(vec3 scale_) {
            transform.scale = scale_;
        }
    }

    /// Update the object (given a deltaTime)
    void update(TimeStep) {}
}

/// An entity is a drawable instance
abstract class Entity : Instance {
    /// Material stating how to render the item
    Material material;

    /// Render on screen
    void draw() {}
}