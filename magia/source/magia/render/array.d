module magia.render.array;

import bindbc.opengl;

import magia.render.buffer;

alias VertexBuffers = VertexBuffer[];

/// Class holding a Vertex Array Object
class VertexArray {
    /// Index
    uint id;

    private {
        VertexBuffers _vertexBuffers;
        IndexBuffer   _indexBuffer;
    }

    @property {
        /// Get vertex buffers
        auto vertexBuffers() const {
            return _vertexBuffers;
        }

        /// Get index buffer
        auto indexBuffer() const {
            return _indexBuffer;
        }
    }

    /// Constructor
    this() {
        glCreateVertexArrays(1, &id);
    }

    /// Destructor
    ~this() {
        glDeleteVertexArrays(1, &id);
    }

    /// Add vertex buffer to context
    void addVertexBuffer(VertexBuffer vertexBuffer) {
        assert(vertexBuffer.layout, "No layout set for VertexBuffer");
        assert(vertexBuffer.layout.elements.length, "No elements in VertexBuffer layout");

        glBindVertexArray(id);
        vertexBuffer.bind();

        uint layoutId = 0;
        foreach(BufferElement element; vertexBuffer.layout.elements) {
            glEnableVertexAttribArray(layoutId);
            glVertexAttribPointer(layoutId,
                                  element.count,
                                  element.glType,
                                  GL_FALSE, // @TODO normalization
                                  vertexBuffer.layout.stride,
                                  cast(void *)element.offset);
            ++layoutId;
        }

        _vertexBuffers ~= vertexBuffer;
    }

    /// Add index buffer to context
    void setIndexBuffer(IndexBuffer indexBuffer) {
        glBindVertexArray(id);
        indexBuffer.bind();

        _indexBuffer = indexBuffer;
    }

    /// Link VAO to VBO
    void linkAttributes(VertexBuffer vertexBuffer, uint layout, uint nbComponents, GLenum type, int stride, void * offset) const {
        vertexBuffer.bind();
        glEnableVertexAttribArray(layout);
        glVertexAttribPointer(layout, nbComponents, type, GL_FALSE, stride, offset); // @TODO normalization
        vertexBuffer.unbind();
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