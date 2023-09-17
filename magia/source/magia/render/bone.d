module magia.render.bone;

import magia.core.mat;
import magia.render.animation;

/// Structure holding bone data
struct Bone {
    /// Index
    uint _id;
    /// Name
    string _name;
    /// Offset matrix
    mat4 _offsetMatrix;

    @property {
        /// Get bone id in model
        uint id() const {
            return _id;
        }

        /// Get bone name for debug/display purposes
        string name() const {
            return _name;
        }
    }

    /// Constructor
    this(uint id, string name, mat4 offsetMatrix) {
        _id = id;
        _name = name;
        _offsetMatrix = offsetMatrix;
    }

    /// Compute bone bind pose
    mat4 computeBindPose(mat4 bindTransform) {
        return bindTransform * _offsetMatrix;
    }

    /// Compute bone animated pose
    mat4 computeAnimatedPose(mat4 bindTransform, Animation animation) {
        // Updat animation
        animation.update();

        // Only proceed if the animation already started
        if (animation.validTime) {
            const mat4 animationModel = animation.computeInterpolatedModel();

            // Recompute final transform (parent * current * offset)
            return bindTransform * animationModel * _offsetMatrix;
        }

        // If the animation isn't valid, return to bind pose
        return computeBindPose(bindTransform);
    }
}