module magia.core.transform;

import magia.core.mat;
import magia.core.quat;
import magia.core.vec;
import magia.core.util;

/// Identity transform
Transform identity = Transform.identity;

/// Transform structure
struct Transform {
    /// Object position
    vec3 position = vec3.zero;

    /// Object rotation
    quat rotation = quat.identity;

    /// Object scale
    vec3 scale = vec3.one;

    @property {
        /// Default transform
        static @property Transform identity() {
            return Transform(vec3.zero);
        }

        /// Get model
        mat4 model() const {
            return combineModel(position, rotation, scale);
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
    }

    /// Constructor given position, rotation, scale
    this(vec3 position_, quat rotation_ = quat.identity, vec3 scale_ = vec3.one) {
        position = position_;
        rotation = rotation_;
        scale = scale_;
    }

    /// Combine two transforms
    Transform opBinary(string op : "*")(Transform other) const {
        return Transform(other.position + position,
                         other.rotation * rotation,
                         other.scale * scale);
    }
}

/// Combine translation, rotation and scale into model matrix
mat4 combineModel(vec3 translation, quat rotation, vec3 scale) {
    mat4 mTranslation = mat4.identity.translate(translation);
    mat4 mRotation = rotation.to_matrix!(4, 4);
    mat4 mScale = mat4.identity.scale(scale);

    return mTranslation * mRotation * mScale;
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}