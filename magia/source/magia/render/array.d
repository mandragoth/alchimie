module magia.render.array;

import bindbc.opengl;

import magia.render.buffer;

alias VertexBuffers = VertexBuffer[];

/// Class holding a Vertex Array Object
class VertexArray {
    private uint _id;

    @property {
        /// Return index buffer element count if any
        uint count() {
            return _indexBuffer ? _indexBuffer.count : 0;
        }
    }

    private {
        IndexBuffer _indexBuffer;
    }

    /// Constructor
    this(VertexBuffer vertexBuffer, IndexBuffer indexBuffer) {
        // Create vertex array and bind it
        glCreateVertexArrays(1, &_id);
        glBindVertexArray(_id);

        // Bind vertex buffer, set up its elements, unbind it
        vertexBuffer.bind();
        vertexBuffer.setupElements();
        vertexBuffer.unbind();

        // Save index buffer set it up
        _indexBuffer = indexBuffer;
    }

    /// Add per instance vertex buffer
    void addInstanceVertexBuffer(VertexBuffer vertexBuffer, uint firstLayoutId) {
        // Bind vertex buffer, link its attributes, unbind it
        vertexBuffer.bind();
        vertexBuffer.setupDivisors(firstLayoutId);
        vertexBuffer.unbind();
    }

    /// Destructor
    ~this() {
        glDeleteVertexArrays(1, &_id);
    }

    /// Bind VAO
    void bind() const {
        glBindVertexArray(_id);

        if (_indexBuffer) {
            _indexBuffer.bind();
        }
    }

    /// Unbind VAO
    static void unbind() {
        glBindVertexArray(0);
        IndexBuffer.unbind();
    }

    /// Delete VAO
    void remove() const {
        glDeleteBuffers(1, &_id);
    }
}