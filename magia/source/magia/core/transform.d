module magia.core.transform;

import magia.core.mat;
import magia.core.quat;
import magia.core.rot;
import magia.core.vec;
import magia.core.util;

/// Transform structure
struct Transform(uint dimension_) {
    alias vec = Vector!(float, dimension_);
    alias rot = Rotor!(float, dimension_);

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

alias Transform2D = Transform!(2);
alias Transform3D = Transform!(3);


/// Combine translation, rotation and scale into model matrix
mat4 combineModel(vec3 translation, quat rotation, vec3 scale) {
    mat4 mTranslation = mat4.identity.translate(translation);
    mat4 mRotation = rotation.to_matrix!(4, 4);
    mat4 mScale = mat4.identity.scale(scale);

    return mTranslation * mRotation * mScale;
}

/// Combine translation, rotation and scale into model matrix
mat4 combineModel(vec3 translation, rot3 rotation, vec3 scale) {
    mat4 mTranslation = mat4.identity.translate(translation);
    mat4 mRotation = rotation.toMatrix();
    mat4 mScale = mat4.identity.scale(scale);

    return mTranslation * mRotation * mScale;
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform3D transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform2D transform) {
    vec3 position = vec3(transform.position.x, transform.position.y, 0f);
    quat rotation = quat.euler_rotation(0f, 0f, transform.rotation.angle);
    vec3 scale    = vec3(transform.scale.x, transform.scale.y, 0f);
    return combineModel(position, rotation, scale);
}