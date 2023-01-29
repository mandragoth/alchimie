module magia.render.vertex;

import magia.core.vec;
import magia.core.color;

/// Class holding a Vertex
struct Vertex {
    /// Where to place the vertex
    vec3 position;
    /// Normal vector (for lights, etc.)
    vec3 normal;
    /// Color of the vertex
    Color color;
    /// Texture coordinates
    vec2 texUV;

    /// Constructor
    this(vec3 position_, vec2 texUV_ = vec2.zero, vec3 normal_ = vec3.zero, Color color_ = Color.white) {
        position = position_;
        normal = normal_;
        color = color_;
        texUV = texUV_;
    }
}