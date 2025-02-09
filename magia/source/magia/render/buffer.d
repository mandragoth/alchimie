module magia.render.buffer;

import bindbc.opengl;

import magia.core.color;
import magia.core.mat;
import magia.core.type;
import magia.core.vec;
import magia.render.joint;
import magia.render.vertex;
import magia.render.layout;

/// Vertex Buffer Objects hold data sent from CPU to GPU
class VertexBuffer {
    private {
        /// Index
        uint _id;

        /// Preallocated length in bytes
        uint _length;

        /// Number of vertices
        uint _count;

        /// Shader data layout
        BufferLayout _layout;
    }

    @property {
        /// Number of indices (used for draw call)
        uint count() const {
            return _count;
        }
    }

    /// Constructor given type array and layout
    this(type)(type[] data, BufferLayout layout_) {
        assert(data.length < uint.max);

        _count = cast(uint)data.length;
        _length = _count * cast(uint)type.sizeof;
        _layout = layout_;

        glCreateBuffers(1, &_id);
        glBindBuffer(GL_ARRAY_BUFFER, _id);
        glBufferData(GL_ARRAY_BUFFER, _length, data.ptr, GL_STATIC_DRAW);
    }

    /// Copy constructor
    this(VertexBuffer other) {
        // Copy plain old data
        _layout = other._layout;

        // Generate new buffer and copy data from other buffer
        glCreateBuffers(1, &_id);
        /// @TODO copy data
    }

    /// Destructor
    ~this() {
        glDeleteBuffers(1, &_id);
    }

    /// Setup elements
    void setupElements() {
        assert(_layout, "No layout set for VertexBuffer");
        assert(_layout.count, "No elements in VertexBuffer layout");
        glBindBuffer(GL_ARRAY_BUFFER, _id);
        _layout.setupElements();
    }
}

import std.stdio;

/// Instance Buffer Objects are special Vertex Buffer Object streaming per instance dynamic data
class InstanceBuffer {
    private {
        /// Index
        uint _id;

        /// Shader data layout
        BufferLayout _layout;
    }

    /// Constructor given future max element count and layout
    this(BufferLayout layout_) {
        _layout = layout_;
        glCreateBuffers(1, &_id);
    }

    /// Copy constructor
    this(InstanceBuffer other) {
        // Copy plain old data
        _layout = other._layout;

        // Generate new buffer and copy data from other buffer
        glCreateBuffers(1, &_id);
        /// @TODO copy data
    }

    /// Destructor
    ~this() {
        glDeleteBuffers(1, &_id);
    }

    /// Update data (for a GL_STREAM_DRAW)
    void setData(type)(type[] data) {
        glBindBuffer(GL_ARRAY_BUFFER, _id);
        glBufferData(GL_ARRAY_BUFFER, data.length * type.sizeof, data.ptr, GL_STREAM_DRAW);
    }

    /// Setup divisors
    void setupDivisors(uint layoutId) {
        assert(_layout, "No layout set for VertexBuffer");
        assert(_layout.count, "No elements in VertexBuffer layout");
        glBindBuffer(GL_ARRAY_BUFFER, _id);
        _layout.setupDivisors(layoutId);
    }
}

/// Index Buffer Objects hold data referencing triangles indices
class IndexBuffer {
    private {
        /// Index
        uint _id;

        /// Data length
        uint _count;
    }

    @property {
        /// Number of indices (used for draw call)
        uint count() const {
            return _count;
        }
    }
    
    /// Constructor given
    this(uint[] indices) {
        assert(indices.length < uint.max);

        glCreateBuffers(1, &_id);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _id);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);
        _count = cast(uint)indices.length;
    }

    /// Copy constructor
    this(IndexBuffer other) {
        // Copy plain old data
        _count = other._count;

        // Generate new buffer and copy data from other buffer
        glCreateBuffers(1, &_id);
        /// @TODO copy data
    }

    /// Destructor
    ~this() {
        glDeleteBuffers(1, &_id);
    }

    /// Bind for usage
    void bind() const {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _id);
    }

    /// Unbind (static as we bind default)
    static void unbind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
}