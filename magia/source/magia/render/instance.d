module magia.render.instance;

import magia.core;

/// An instance is an item with a transform that can be updated
abstract class Instance(uint dimension_) {
    alias vec = Vector!(float, dimension_);
    alias rot = Rotor!(float, dimension_);
    alias mat = Matrix!(float, dimension_ + 1, dimension_ + 1);

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

        /// Get global model
        mat4 globalModel() {
            Transform!(dimension_) globalTransform = globalTransform();
            return globalTransform.combineModel();
        }

        /// Set position
        void position(vec position_) {
            transform.position = position_;
        }

        /// Set rotation
        void rotation(rot rotation_) {
            transform.rotation = rotation_;
        }

        /// Set scale
        void scale(vec scale_) {
            transform.scale = scale_;
        }

        /// Set model
        void model(mat model_) {
            transform.model = model_;
        }

        /// Get local position
        vec localPosition() {
            return transform.position;
        }

        /// Get global position
        vec globalPosition() {
            return globalTransform.position;
        }

        /// Get angle
        static if (dimension_ == 2) {
            float angle() {
                return transform.rotation.angle;
            }
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