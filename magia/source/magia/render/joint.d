module magia.render.joint;

import magia.core;
import magia.render.animation;
import bindbc.opengl;

/// Structure holding per-vertex joint data
struct Joint {
    /// Associated vertex
    vec4i boneIds;
    /// Associated weight
    vec4 weights;

    /// Constructor
    this(vec4i boneIds_, vec4 weights_) {
        boneIds = boneIds_;
        weights = weights_;
    }
}

/// Structure holding bone data
class Bone {
    /// Index
    uint _id;
    /// Name
    string _name;
    /// Offset matrix
    mat4 _offsetMatrix;
    /// Paremt transform
    mat4 _bindTransform;
    /// Final transform
    mat4 _finalTransform;

    @property {
        /// Model used to move this bone around
        mat4 model() const {
            return _finalTransform;
        }

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

    /// Compute bind pose for bone
    void computeBindPose(mat4 bindModel) {
        /// Global model is used to setup bind pose
        _bindTransform = bindModel;

        /// Compute final transformation in case we do not animate the model
        _finalTransform = bindModel * _offsetMatrix;
    }

    void computeAnimatedPose(Animation animation) {
        // Updat animation
        animation.update();

        // Only proceed if the animation already started
        if (animation.validTime) {
            const mat4 animationModel = animation.computeInterpolatedModel();

            // Recompute final transform (parent * current * offset)
            _finalTransform = _bindTransform * animationModel * _offsetMatrix;
        }
    }
}