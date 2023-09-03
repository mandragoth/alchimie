module magia.render.entity;

import magia.core;
import magia.render.material;
import magia.render.texture;

/// An instance is an item with a transform that can be updated
abstract class Instance(type, uint dimension_) {
    /// Transform stating where the instance is located
    Transform!(type, dimension_) transform;

    /// Parent instance
    Instance parent;

    /// Children instances
    Instance[] children;

    @property {
        /// Get global transform
        Transform!(type, dimension_) globalTransform() {
            Transform toReturn = transform;

            Instance ancestor = parent;
            while(ancestor !is null) {
                toReturn = toReturn * ancestor.transform;
                ancestor = ancestor.parent;
            }

            return toReturn;
        }

        /// Set position
        void position(Vector!(type, dimension_) position_) {
            transform.position = position_;
        }

        /// Get local position
        Vector!(type, dimension_) localPosition() {
            return transform.position;
        }

        /// Get global position
        Vector!(type, dimension_) globalPosition2D() {
            return globalTransform.position;
        }

        /// Set rotation
        void rotation(Rotor!(type, dimension_) rotation_) {
            transform.rotation = rotation_;
        }

        /// Set scale
        void scale(Vector!(type, dimension_) scale_) {
            transform.scale = scale_;
        }
    }

    /// Add a child
    void addChild(Instance instance) {
        children ~= instance;
        instance.parent = this;
    }

    /// Update the object (given a deltaTime)
    void update() {}
}

alias Instance2D = Instance!(float, 2);
alias Instance3D = Instance!(float, 3);

/// An entity is a drawable instance
abstract class Entity(type, uint dimension_) : Instance!(type, dimension_) {
    /// Material stating how to render the item
    Material material;

    /// Render on screen
    void draw() {}
}

alias Entity2D = Entity!(float, 2);
alias Entity3D = Entity!(float, 3);