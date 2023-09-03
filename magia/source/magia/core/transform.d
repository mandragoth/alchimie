module magia.core.transform;

import magia.core.mat;
import magia.core.quat;
import magia.core.rot;
import magia.core.vec;
import magia.core.util;

/// Transform structure
struct Transform(type, uint dimension_) {
    alias vec = Vector!(type, dimension_);
    alias rot = Rotor!(type, dimension_);

    /// Object position
    vec position = vec.zero;

    /// Object rotation
    rot rotation = rot.zero;

    /// Object scale
    vec scale = vec.one;

    @property {
        /// Default transform
        static Transform identity() {
            return Transform(vec.zero);
        }

        /// Get model
        /*mat4 model() const {
            return combineModel(position, rotation, scale);
        }*/

        /// Setup internal quaternion given euler angles
        /*void rotationFromEuler(vec3 eulerAngles) {
            rotation = quat.euler_rotation(eulerAngles.x, eulerAngles.y, eulerAngles.z);
        }

        /// Get euler rotation given a quaternion
        vec3 rotationToEuler() const {
            return vec3(rotation.roll, rotation.pitch, rotation.yaw) * radToDeg;
        }*/
    }

    /// Constructor given position, scale
    this(vec position_, vec scale_) {
        position = position_;
        scale = scale_;
    }

    /// Constructor given position, rotation, scale
    this(vec position_, rot rotation_ = rot.zero, vec scale_ = vec.one) {
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

alias Transform2D = Transform!(float, 2);
alias Transform3D = Transform!(float, 3);

/// Combine translation, rotation and scale into model matrix
mat4 combineModel(vec3 translation, quat rotation, vec3 scale) {
    mat4 mTranslation = mat4.identity.translate(translation);
    mat4 mRotation = rotation.to_matrix!(4, 4);
    mat4 mScale = mat4.identity.scale(scale);

    return mTranslation * mRotation * mScale;
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform3D transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}