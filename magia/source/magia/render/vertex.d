module magia.render.vertex;

import magia.core.vec;

/// Class holding a Vertex
struct Vertex {
    /// Where to place the vertex
    vec3 position;
    /// Normal vector (for lights, etc.)
    vec3 normal;
    /// Color of the vertex
    vec3 color;
    /// Texture coordinates
    vec2 texUV;
}