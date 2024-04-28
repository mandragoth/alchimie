module magia.render.joint;

import magia.core.vec;

/// Structure holding per-vertex joint data
struct Joint {
    /// Associated vertex
    vec4i boneIds;
    /// Associated weight
    vec4f weights;

    /// Constructor
    this(vec4i boneIds_, vec4f weights_) {
        boneIds = boneIds_;
        weights = weights_;
    }
}