module magia.core.transform;

import magia.core.mat;
import magia.core.quat;
import magia.core.vec;
import magia.core.util;

/// Transform structure
struct Transform {
    /// Object position
    vec3 position = vec3.zero;

    /// Object rotation
    quat rotation = quat.identity;

    /// Object scale
    vec3 scale = vec3.one;

    /// Matrix model
    private mat4 _model;

    @property {
        /// Default transform
        static @property Transform identity() {
            return Transform(vec3.zero);
        }

        /// Get model
        mat4 model() const {
            return _model;
        }

        /// Get 2D position
        vec2 position2D() const {
            return vec2(position.x, position.y);
        }

        /// Setup internal quaternion given euler angles
        void rotationFromEuler(vec3 eulerAngles) {
            rotation = quat.euler_rotation(eulerAngles.x, eulerAngles.y, eulerAngles.z);
        }

        /// Get euler rotation given a quaternion
        vec3 rotationToEuler() const {
            return vec3(rotation.roll, rotation.pitch, rotation.yaw) * radToDeg;
        }
    }

    /// Constructor given position, scale
    this(vec3 position_, vec3 scale_) {
        position = position_;
        scale = scale_;
        _model = combineModel(position, rotation, scale);
    }

    /// Constructor given position, rotation, scale
    this(vec3 position_, quat rotation_ = quat.identity, vec3 scale_ = vec3.one) {
        position = position_;
        rotation = rotation_;
        scale = scale_;
        _model = combineModel(position, rotation, scale);
    }

    /// Constructor (given model)
    this(mat4 model_, vec3 position_ = vec3.zero,
         quat rotation_ = quat.identity, vec3 scale_ = vec3.one) {
        _model = model_;
        position = position_;
        rotation = rotation_;
        scale = scale_;
    }

    /// Compute transform model
    void recomputeModel() {
        _model = combineModel(position, rotation, scale);
    }

    /// Compute 
    mat4 applyTransform(Transform other) {
        return _model * combineModel(other);
    }
}

/// Combine position, rotation and scale into model matrix
mat4 combineModel(vec3 position, quat rotation, vec3 scale) {
    mat4 localTranslation = mat4.identity.translate(position);
    mat4 localRotation = rotation.to_matrix!(4, 4);
    mat4 localScale = mat4.identity.scale(scale);

    return localTranslation * localRotation * localScale;
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}