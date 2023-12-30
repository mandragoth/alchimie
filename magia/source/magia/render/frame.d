module magia.render.frame;

import std.stdio;

import bindbc.opengl;
import magia.render.texture;

alias FrameBufferLayout = TextureType[];

/// Class holding a Frame Buffer Object
class FrameBuffer {
    /// Index
    GLuint id;

    protected {
        Texture[] _textures;
    }

    /// Constructor
    this(FrameBufferLayout layout, uint width, uint height, uint nbSamples = 0) {
        // Generate frame buffer and bind it
        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);

        // Create a frame buffer texture for each part of its layout and bind it
        foreach (TextureType type; layout) {
            _textures ~= new FrameBufferTexture(type, width, height, nbSamples);
        }

        // Unbind frame buffer (as it may be only used later)
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Bind frame buffer
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Bind frame buffer in read mode
    void bindRead() {
        glBindFramebuffer(GL_READ_FRAMEBUFFER, id);
    }

    /// Bind frame buffer in draw mode
    void bindDraw() {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, id);
    }

    /// Unbind texture from frame buffer
    void unbindTexture(uint textureId) {
        // @TODO correct when generic Texture class ready once again
        //_textures[textureId].unbindFromFrameBuffer();
    }

    /// Unbind frame buffer globally
    static void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Blit frame buffer
    static void blit(uint width, uint height) {
        glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    }

    /// Delete frame buffer
    void remove() {
        glDeleteFramebuffers(1, &id);
    }

    /// Bind attached texture
    void bindTexture(uint textureId, GLuint slot = 0) {
        _textures[textureId].bind(slot);
    }

    /// Check frame buffer status
    static void check(string name) {
        GLenum FBOStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (FBOStatus != GL_FRAMEBUFFER_COMPLETE) {
            writeln("Framebuffer ", name, " error: ", FBOStatus);
        }
    }
}