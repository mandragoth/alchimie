module magia.render.rbo;

import bindbc.opengl;

/// Class holding a Render Buffer Object
class RBO {
    /// Index
    GLuint id;

    /// Constructor
    this(uint size) {
        glGenRenderbuffers(1, &id);
        glBindRenderbuffer(GL_RENDERBUFFER, id);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, size, size);
    }

    /// Constructor for multisampling
    this(uint size, uint nbSamples) {
        glGenRenderbuffers(1, &id);
        glBindRenderbuffer(GL_RENDERBUFFER, id);
        glRenderbufferStorageMultisample(GL_RENDERBUFFER, nbSamples, GL_DEPTH24_STENCIL8, size, size);
    }

    /// Bind RBO
    void bind() {
        glBindRenderbuffer(GL_RENDERBUFFER, id);
    }

    /// Unbind RBO
    static void unbind() {
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }

    /// Delete RBO
    void remove() {
        glDeleteRenderbuffers(1, &id);
    }

    /// Attach FBO to RBO
    void attachFBO() {
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, id);
    }
}