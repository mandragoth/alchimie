module magia.render.element;

import magia.core.type;

import bindbc.opengl;

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

/// Get openGL name for layout data type
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