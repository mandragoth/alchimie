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

    static if (dimension_ == 3) {
        mat4 combineModel() const {
            mat4 mTranslation = mat4.translation(position);
            mat4 mRotation = rotation.toMatrix();
            mat4 mScale = mat4.scaling(scale);

            return mTranslation * mRotation * mScale;
        }
    }

    static if (dimension_ == 2) {
        mat4 combineModel() const {
            mat4 mTranslation = mat4.translation(vec3f(position.x, position.y, 0f));
            mat4 mRotation = rotation.toMatrix();
            mat4 mScale = mat4.scaling(vec3f(scale.x, scale.y, 0f));

            return mTranslation * mRotation * mScale;
        }
    }
}

alias Transform2D = Transform!(2);
alias Transform3D = Transform!(3);