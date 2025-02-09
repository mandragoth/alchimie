module magia.render.ssbo;

import bindbc.opengl;

/// Shader buffer storage object (SSBO)
class ShaderBuffer {
    private {
        uint _id;
    }

    /// Default constructor
    this() {
        glCreateBuffers(1, &_id);
    }

    /// Forward data to shader
    void forwardData(type)(type[] data) {
        const GLsizeiptr bufferSize = data.length * type.sizeof;

        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, _id);
        glBufferData(GL_SHADER_STORAGE_BUFFER, bufferSize, data.ptr, GL_DYNAMIC_DRAW);
    }
}