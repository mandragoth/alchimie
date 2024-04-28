module magia.render.vertex;

import magia.core;
import magia.render.joint;
import magia.render.renderer;

/// Structure holding a Vertex
struct Vertex {
    /// Where to place the vertex
    vec3f position;
    /// Normal vector (for lights, etc.)
    vec3f normal;
    /// Color of the vertex
    Color color;
    /// Texture coordinates
    vec2f texUV;

    /// Constructor
    this(vec3f position_, vec2f texUV_ = vec2f.zero, vec3f normal_ = vec3f.zero, Color color_ = Color.white) {
        position = position_;
        normal = normal_;
        color = color_;
        texUV = texUV_;
    }
}

/// Structure holding packed vertex and joint data
struct AnimatedVertex {
    /// Where to place the vertex
    vec3f position;
    /// Normal vector (for lights, etc.)
    vec3f normal;
    /// Color of the vertex
    Color color;
    /// Texture coordinates
    vec2f texUV;
    /// Joint associated vertex
    vec4i boneIds;
    /// Joint associated weight
    vec4f weights;

    /// Constructor
    this(Vertex vertex, Joint joint) {
        position = vertex.position;
        normal = vertex.normal;
        color = vertex.color;
        texUV = vertex.texUV;
        boneIds = joint.boneIds;
        weights = joint.weights;
    }
}