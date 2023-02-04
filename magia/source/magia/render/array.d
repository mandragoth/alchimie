module magia.render.array;

import bindbc.opengl;

import magia.render.buffer;

alias VertexBuffers = VertexBuffer[];

/// Class holding a Vertex Array Object
class VertexArray {
    /// Index
    uint id;

    /// Element count
    uint elementCount;

    /// Constructor
    this(VertexBuffer vertexBuffer) {
        // Create vertex array and bind it
        glCreateVertexArrays(1, &id);
        glBindVertexArray(id);

        // Bind vertex buffer, set up its elements, unbind it
        vertexBuffer.bind();
        vertexBuffer.setupElements();
        vertexBuffer.unbind();
    }

    /// Destructor
    ~this() {
        glDeleteVertexArrays(1, &id);
    }

    /// Add index buffer to context
    void setIndexBuffer(IndexBuffer indexBuffer) {
        // Bind vertex array
        glBindVertexArray(id);
        elementCount = indexBuffer.count;
    }

    /// Bind VAO
    void bind() const {
        glBindVertexArray(id);
    }

    /// Unbind VAO
    static void unbind() {
        glBindVertexArray(0);
    }

    /// Delete VAO
    void remove() const {
        glDeleteBuffers(1, &id);
    }
}