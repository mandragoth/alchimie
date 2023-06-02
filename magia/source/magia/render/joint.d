module magia.render.joint;

import magia.core.mat;
import magia.core.vec;
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
struct Bone {
    /// Offset matrix
    mat4 offsetMatrix;
    /// Final transform
    mat4 finalTransform;

    /// Constructor
    this(mat4 model) {
        offsetMatrix = model;
        finalTransform = mat4.identity;
    }
}