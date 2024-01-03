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

        // Set up vertex buffer elements
        vertexBuffer.setupElements();

        // Save index buffer set it up
        _indexBuffer = indexBuffer;
    }

    /// Add per instance vertex buffer
    void addInstanceBuffer(InstanceBuffer instanceBuffer, uint firstLayoutId) {
        // Set up instance buffer divisors
        instanceBuffer.setupDivisors(firstLayoutId);
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