module magia.render.buffer;

import bindbc.opengl;

import magia.core.mat;
import magia.core.vec;
import magia.render.vertex;
import std.conv;
import std.format;

/// Type for shader layout element
enum LayoutType {
    ltFloat,
    ltFloat2,
    ltFloat3,
    ltFloat4,
    ltMat3,
    ltMat4,
    ltInt,
    ltInt2,
    ltInt3,
    ltInt4,
    ltBool
}

/// Get size of layout data type
uint layoutTypeSize(LayoutType type) {
    final switch (type) with (LayoutType) {
    case ltFloat:
    case ltInt:
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

/// Buffer element for shader layout
struct BufferElement {
    /// Name of element in the shader
    string name;

    /// Type of element
    LayoutType type;

    /// Size of data
    uint size;

    /// Offset in layout
    uint offset;

    @property {
        /// Number of entries for this item
        uint count() const {
            final switch (type) with (LayoutType) {
            case ltFloat:
            case ltInt:
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
            case ltBool:
                return GL_BOOL;
            }
        }
    }

    /// Constructor
    this(string name_, LayoutType type_) {
        name = name_;
        type = type_;
        size = layoutTypeSize(type_);
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
        /// Elements
        BufferElements elements() {
            return _elements;
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

    private void computeOffsets() {
        uint offset = 0;
        foreach (BufferElement element; _elements) {
            element.offset = offset;
            offset += element.size;
        }
        _stride = offset;
    }
}

/// Vertex Buffer Objects hold data sent from CPU to GPU
class VertexBuffer {
    /// Index
    uint id;

    /// Shader data layout
    BufferLayout layout;

    /// Constructor given vertex buffer
    this(float[] vertices) {
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given 3D vertices
    this(vec3[] vertices) {
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * vec3.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given 2D vertices
    this(vec2[] vertices) {
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * vec2.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given vertex buffer
    this(Vertex[] vertices) {
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given mat4 array
    this(mat4[] mat4s) {
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, mat4s.length * mat4.sizeof, mat4s.ptr, GL_STATIC_DRAW);
    }

    /// Destructor
    ~this() {
        glDeleteBuffers(1, &id);
    }

    /// Bind for usage
    void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    /// Unbind (static as we bind default)
    static void unbind() {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}

/// Index Buffer Objects hold data referencing triangles indices
class IndexBuffer {
    /// Index
    uint id;

    private {
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
        glCreateBuffers(1, &id);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);
        _count = cast(uint)indices.length;
    }

    /// Destructor
    ~this() {
        glDeleteBuffers(1, &id);
    }

    /// Bind for usage
    void bind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
    }

    /// Unbind (static as we bind default)
    static void unbind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
}