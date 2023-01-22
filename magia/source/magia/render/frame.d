module magia.render.frame;

import std.stdio;

import bindbc.opengl;
import magia.render.texture;

/// Frame Buffer Object type
enum FBOType {
    Multisample,
    Postprocess,
    Shadowmap,
}

/// Class holding a Frame Buffer Object
class FrameBuffer {
    /// Index
    GLuint id;

    private {
        Texture _texture;
    }

    /// Constructor
    this(FBOType type, uint size, uint nbSamples = 0) {
        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);

        if (type == FBOType.Postprocess) {
            _texture = new PostProcessTexture(size, size);
        } else if(type == FBOType.Multisample) {
            _texture = new MultiSampleTexture(size, size, nbSamples);
        } else {
            _texture = new ShadowmapTexture(size, size);
        }
    }

    /// Bind FBO
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Bind FBO in read mode
    void bindRead() {
        glBindFramebuffer(GL_READ_FRAMEBUFFER, id);
    }

    /// Bind FBO in draw mode
    void bindDraw() {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, id);
    }

    /// Clear FBO binding
    void clear() {
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _texture.target, 0, 0);
    }

    /// Unbind FBO (bind to default FBO)
    static void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Unbind FBO (bind to default FBO)
    static void unbindRead() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Unbind FBO (bind to default FBO)
    static void unbindDraw() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Blit frame buffer
    static void blit(uint width, uint height) {
        glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    }

    /// Delete FBO
    void remove() {
        glDeleteFramebuffers(1, &id);
    }

    /// Bind attached texture
    void bindTexture(GLuint slot = 0) {
        _texture.bind(slot);
    }

    /// Check FBO status
    static void check(string name) {
        GLenum FBOStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (FBOStatus != GL_FRAMEBUFFER_COMPLETE) {
            writeln("Framebuffer ", name, " error: ", FBOStatus);
        }
    }
}