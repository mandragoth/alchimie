module magia.render.layout;

import magia.render.element;

import bindbc.opengl;
import std.format;
import std.conv;

alias BufferElements = BufferElement[];

/// Layout of elements to feed to the shader
class BufferLayout {
    private {
        BufferElements _elements;
        uint _stride;
    }

    @property {
        /// Elements size
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