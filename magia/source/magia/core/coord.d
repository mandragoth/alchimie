module magia.core.coord;

import magia.core.mat;
import magia.core.transform;
import magia.core.rot;
import magia.core.vec;

/// Representation of a cartesian coordinate system
struct Cartesian(uint dimension_) {
    alias vec = Vector!(float, dimension_);

    /// Origin
    vec origin;

    /// Axes
    vec axes;

    /// Default coordinate system (center of screen)
    static Cartesian3D center = Cartesian3D(vec3.zero, vec3.one);

    /// Compute transform for renderer given a set of positions and size
    Transform!(dimension_) toRenderSpace(Transform!(dimension_) transform) {
        // Adjust position
        transform.position = origin + axes * transform.position;

        // Set transform
        return transform;
    }
}

alias Cartesian2D = Cartesian!(2);
alias Cartesian3D = Cartesian!(3);