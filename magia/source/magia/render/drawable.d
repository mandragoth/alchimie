module magia.render.drawable;

import magia.core.vec;
import magia.render.shader;

/// Interface for objects drawable in 3D
interface Drawable3D {
    /// Render on screen
    void draw(Shader shader);
}

/// Interface for objects drawable in 2D
interface Drawable2D {
    /// Render on screen
    void draw(const vec2 position);
}