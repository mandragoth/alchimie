module magia.render.entity;

import magia.audio;
import magia.core;
import magia.render.material;
import magia.render.renderer;
import magia.render.texture;

/// An instance is an item with a transform that can be updated
abstract class Instance(uint dimension_) {
    alias vec = Vector!(float, dimension_);
    alias rot = Rotor!(float, dimension_);

    /// Transform stating where the instance is located
    Transform!(dimension_) transform;

    /// Parent instance
    Instance parent;

    /// Children instances
    Instance[] children;

    @property {
        /// Get global transform
        Transform!(dimension_) globalTransform() {
            Transform!(dimension_) toReturn = transform;

            Instance ancestor = parent;
            while(ancestor !is null) {
                toReturn = toReturn * ancestor.transform;
                ancestor = ancestor.parent;
            }

            return toReturn;
        }

        /// Set position
        void position(vec position_) {
            transform.position = position_;
        }

        /// Get local position
        vec localPosition() {
            return transform.position;
        }

        /// Get global position
        vec globalPosition() {
            return globalTransform.position;
        }

        /// Set rotation
        void rotation(rot rotation_) {
            transform.rotation = rotation_;
        }

        /// Set scale
        void scale(vec scale_) {
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

alias Instance2D = Instance!(2);
alias Instance3D = Instance!(3);

/// An entity is a drawable instance
abstract class Entity(uint dimension_) : Instance!(dimension_) {
    /// Material stating how to render the item
    Material material;

    /// Render on screen
    void draw(Renderer!(dimension_) renderer) {}
}

alias Entity2D = Entity!(2);
alias Entity3D = Entity!(3);