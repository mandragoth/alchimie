module magia.render.vertex;

import magia.core;
import magia.render.joint;
import magia.render.renderer;

/// Structure holding a Vertex
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

    /// Draw normals for debug
    void drawNormal() {
        renderer.drawLine(position, position + normal, Color.blue);
    }
}

/// Structure holding packed vertex and joint data
struct AnimatedVertexData {
    /// Where to place the vertex
    vec3 position;
    /// Normal vector (for lights, etc.)
    vec3 normal;
    /// Color of the vertex
    Color color;
    /// Texture coordinates
    vec2 texUV;
    /// Joint associated vertex
    vec4i boneIds;
    /// Joint associated weight
    vec4 weights;

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