module magia.core.coord;

import magia.core.transform;
import magia.core.rot;
import magia.core.vec;

/// Representation of a 2D coordinate system
struct CoordinateSystem {
    /// Origin
    vec2 origin = vec2.topLeft;

    /// X,Y axis
    vec2 axis = vec2.bottomRight;

    /// Default coordinate system (center of screen)
    static CoordinateSystem center = CoordinateSystem(vec2.zero, vec2.one);

    /// Topleft coordinate system (looking towards bottom right)
    static CoordinateSystem topLeft = CoordinateSystem(vec2.topLeft, vec2.bottomRight);

    /// Compute transform for renderer given a set of positions and size
    Transform2D toRenderSpace(vec2 position, vec2 size, vec2 spaceSize) {
        // Express size as ratio of screen size
        size = size / spaceSize;

        // Express position as ratio of position and screen size
        position = origin + position / spaceSize * 2 * axis + size * axis;

        // Set transform
        return Transform2D(position, size);
    }

    /// Compute transform for renderer given a set of positions, angle and size
    Transform2D toRenderSpace(vec2 position, vec2 size, vec2 spaceSize, float angle) {
        Transform2D transform = toRenderSpace(position, size, spaceSize);
        transform.rotation = rot2(angle);
        return transform;
    }
}