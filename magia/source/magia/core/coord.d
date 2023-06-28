module magia.core.coord;

import magia.core.transform;
import magia.core.vec;

/// Representation of a 2D coordinate system
struct CoordinateSystem {
    /// Origin
    vec2 origin;

    /// X,Y axis
    vec2 axis;

    /// Default coordinate system (center of screen)
    static CoordinateSystem center = CoordinateSystem(vec2.zero, vec2.one);

    /// Topleft coordinate system (looking towards bottom right)
    static CoordinateSystem topLeft = CoordinateSystem(vec2.topLeft, vec2.bottomRight);

    /// Compute transform for renderer given a set of positions and size
    Transform toRenderSpace(vec2 position, vec2 size, vec2 spaceSize) {
        size = size / spaceSize;

        // Express position as ratio of position and screen size
        position = origin + position / spaceSize * 2 * axis + size * axis;

        // Set transform
        return Transform(vec3(position, 0), vec3(size, 0));
    }
}