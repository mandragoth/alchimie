module magia.render.joint;

import magia.core.vec;
import bindbc.opengl;

/// Structure holding Joint
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