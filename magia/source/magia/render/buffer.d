module magia.render.buffer;

import bindbc.opengl;

import magia.core.color;
import magia.core.mat;
import magia.core.type;
import magia.core.vec;
import magia.render.joint;
import magia.render.vertex;

import std.conv;
import std.format;

/// Get size of layout data type
uint layoutTypeSize(LayoutType type) {
    final switch (type) with (LayoutType) {
    case ltFloat:
    case ltInt:
    case ltUint:
        return 4;
    case ltFloat2:
    case ltInt2:
        return 4 * 2;
    case ltFloat3:
    case ltInt3:
        return 4 * 3;
    case ltFloat4:
    case ltInt4:
        return 4 * 4;
    case ltMat3:
        return 4 * 3 * 3;
    case ltMat4:
        return 4 * 4 * 4;
    case ltBool:
        return 1;
    }
}

string layouTypeToString(LayoutType type) {
    final switch (type) with (LayoutType) {
        case ltFloat:
        case ltFloat2:
        case ltFloat3:
        case ltFloat4:
        case ltMat3:
        case ltMat4:
            return "GL_FLOAT";
        case ltInt:
        case ltInt2:
        case ltInt3:
        case ltInt4:
            return "GL_INT";
        case ltUint:
            return "GL_UNSIGNED_INT";
        case ltBool:
            return "GL_BOOL";
    }
}

/// Buffer element for shader layout
struct BufferElement {
    /// Name of element in the shader
    string name;

    /// Type of element
    LayoutType type;

    /// Size of data in bytes
    uint typeSize;

    /// Offset in layout in bytes
    uint offset;

    /// Divisor in layout
    uint divisor;

    @property {
        /// Size of this item
        uint size() const {
            return typeSize;
        }

        /// Number of entries for this item
        uint count() const {
            final switch (type) with (LayoutType) {
            case ltFloat:
            case ltInt:
            case ltUint:
            case ltBool:
                return 1;
            case ltFloat2:
            case ltInt2:
                return 2;
            case ltFloat3:
            case ltInt3:
                return 3;
            case ltFloat4:
            case ltInt4:
                return 4;
            case ltMat3:
                return 3 * 3;
            case ltMat4:
                return 4 * 4;
            }
        }

        /// Layout type as openGL data type
        GLenum glType() {
            final switch (type) with (LayoutType) {
            case ltFloat:
            case ltFloat2:
            case ltFloat3:
            case ltFloat4:
            case ltMat3:
            case ltMat4:
                return GL_FLOAT;
            case ltInt:
            case ltInt2:
            case ltInt3:
            case ltInt4:
                return GL_INT;
            case ltUint:
                return GL_UNSIGNED_INT;
            case ltBool:
                return GL_BOOL;
            }
        }
    }

    /// Constructor
    this(string name_, LayoutType type_, uint divisor_ = 0) {
        name = name_;
        type = type_;
        divisor = divisor_;
        typeSize = layoutTypeSize(type_);
    }
}

alias BufferElements = BufferElement[];

/// Layout of elements to feed to the shader
class BufferLayout {
    private {
        BufferElements _elements;
        uint _stride;
    }

    @property {
        uint size() const {
            uint size = 0;
            foreach (BufferElement element; _elements) {
                size += element.size;
            }
            return size;
        }

        /// Elements count
        uint count() const {
            return cast(uint)_elements.length;
        }

        /// Stride
        uint stride() const {
            return _stride;
        }

        /// Format internal data as string for debug purposes
        string as_string() const {
            string toReturn = format("%s", _elements);
            toReturn ~= ", stride: " ~ to!string(_stride);
            return toReturn;
        }
        alias toString = as_string;
    }

    /// Constructor
    this(BufferElements elements) {
        _elements = elements;
        computeOffsets();
    }

    /// Setup elements
    void setupElements() {
        uint layoutId = 0;
        foreach(ref BufferElement element; _elements) {
            glEnableVertexAttribArray(layoutId);

            if (element.glType == GL_INT || element.glType == GL_UNSIGNED_INT) {
                glVertexAttribIPointer(layoutId,
                                       element.count,
                                       element.glType,
                                       stride,
                                       cast(void *)element.offset);
            } else {
                glVertexAttribPointer(layoutId,
                                      element.count,
                                      element.glType,
                                      GL_FALSE, // No normalization
                                      stride,
                                      cast(void *)element.offset);
            }
            ++layoutId;
        }
    }

    /// Setup divisors
    void setupDivisors(uint layoutId) {
        foreach(ref BufferElement element; _elements) {
            glEnableVertexAttribArray(layoutId);

            if (element.glType == GL_INT || element.glType == GL_UNSIGNED_INT) {
                glVertexAttribIPointer(layoutId,
                                       element.count,
                                       element.glType,
                                       stride,
                                       cast(void *)element.offset);
            } else {
                glVertexAttribPointer(layoutId,
                                      element.count,
                                      element.glType,
                                      GL_FALSE, // No normalization
                                      stride,
                                      cast(void *)element.offset);
            }

            glVertexAttribDivisor(layoutId, 1);
            ++layoutId;
        }
    }

    private void computeOffsets() {
        uint offset = 0;
        foreach (ref BufferElement element; _elements) {
            element.offset = offset;
            offset += element.typeSize;
        }
        _stride = offset;
    }
}

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