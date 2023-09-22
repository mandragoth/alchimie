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
    alias mat = Matrix!(float, dimension_ + 1, dimension_ + 1);

    /// Object position
    vec position = vec.zero;

    /// Object rotation
    rot rotation = rot.zero;

    /// Object scale
    vec scale = vec.one;

    /// Object model
    mat model = mat.identity;

    @property {
        /// Default transform
        static Transform identity() {
            return Transform(vec.zero);
        }
    }

    /// Constructor given position, rotation, scale, model
    this(vec position_, rot rotation_ = rot.zero, vec scale_ = vec.one, mat model_ = mat.identity) {
        position = position_;
        rotation = rotation_;
        scale = scale_;
        model = model_;
    }

    /// Constructor given position, scale
    this(vec position_, vec scale_) {
        position = position_;
        scale = scale_;
    }

    /// Combine two transforms
    Transform opBinary(string op : "*")(Transform other) const {
        return Transform(other.position + position,
                         other.rotation * rotation,
                         other.scale * scale,
                         other.model * model);
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

/// Combine translation, rotation and scale into model matrix
mat4 combineModel(vec2 translation, rot2 rotation, vec2 scale) {
    vec3 mTranslation = vec3(translation.x, translation.y, 0f);
    quat mRotation = quat.euler_rotation(0f, 0f, rotation.angle);
    vec3 mScale    = vec3(scale.x, scale.y, 0f);

    return combineModel(mTranslation, mRotation, mScale);
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(uint dimension_)(Transform!(dimension_) transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}