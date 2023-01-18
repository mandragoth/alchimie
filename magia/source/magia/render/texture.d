module magia.render.texture;

import bindbc.sdl;
import bindbc.opengl;

// @TODO remove dependency
import magia.render.shader;

import std.exception;
import std.conv;
import std.stdio;
import std.string;

/// Possible types of textures
enum TextureType {
    sprite,
    diffuse,
    specular,
    cubemap,
    multisample,
    postprocess,
    shadow
}

/// Class holding texture data
class Texture {
    /// Texture index
    GLuint id;

    protected {
        // Teture image attributes
        int _width, _height;

        // Texture type
        TextureType _type;

        // Slot
        GLuint _slot;

        // Target
        GLenum _target;

        // Trace
        bool _trace = false;

        // Nb textures internally loaded
        uint _nbTextures = 0;
    }

    @property {
        /// Get texture type
        TextureType type() const {
            return _type;
        }

        /// Get texture target
        GLenum target() const {
            return _target;
        }

        /// Get texture width
        int width() const {
            return _width;
        }

        /// Get texture height
        int height() const {
            return _height;
        }
    }

    /// Base constructor (used for inheriting classes)
    this(uint width, uint height, GLenum target, TextureType type) {
        _width = width;
        _height = height;
        _target = target;
        _type = type;
    }

    /// Constructor for usual 2D texture from path
    this(string path, TextureType type = TextureType.sprite, GLuint slot = 0) {
        // Prefix path
        path = "../assets/img/" ~ path;

        // Get surface and process it
        SDL_Surface *surface = IMG_Load(toStringz(path));
        enforce(surface, "can't load image `" ~ path ~ "`");
        setupData(surface, type, slot);

        // Free surface
        SDL_FreeSurface(surface);
    }

    /// Constructor for usual 2D texture from surface
    this(SDL_Surface *surface, TextureType type = TextureType.sprite, GLuint slot = 0) {
        setupData(surface, type, slot);
    }

    /// Setup data
    void setupData(SDL_Surface *surface, TextureType type, GLuint slot) {
        // Setup type
        _type = type;

        // Setup slot
        _slot = slot;

        // Setup target
        _target = GL_TEXTURE_2D;

        // Read data from handler
        _width = surface.w;
        _height = surface.h;

        // Generate texture and bind texture
        glGenTextures(1, &id);
        glBindTexture(_target, id);

        if (type == TextureType.sprite) {
            // Setup filter
            glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

            // Setup wrap
            glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        } else {
            // Setup filters
            glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

            // Setup wrap
            glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }

        const uint nbChannels = surface.format.BitsPerPixel / 8;

        if (_trace) {
            writeln("Loaded texture with ", nbChannels, " channels");
        }

        // For now, consider diffuses as RGBA, speculars as R
        GLenum format;
        GLenum internalFormat;
        if (nbChannels == 4) {
            format = GL_RGBA;
            internalFormat = GL_SRGB_ALPHA;
        } else if (nbChannels == 3) {
            format = GL_RGB;
            internalFormat = GL_SRGB;
        } else if (nbChannels == 1) {
            format = GL_RED;
            internalFormat = GL_SRGB;
        } else {
            new Exception("Unsupported texture format for " ~ to!string(type) ~ " texture type");
        }

        // Generate texture image
        glTexImage2D(_target, 0, internalFormat, _width, _height, 0, format, GL_UNSIGNED_BYTE, surface.pixels);
        _nbTextures = 1;

        // Generate mipmaps
        glGenerateMipmap(_target);
    }

    /// Constructor for cubemap texture
    this(string[6] paths) {
        // Setup type
        _type = TextureType.cubemap;

        // Setup target
        _target = GL_TEXTURE_CUBE_MAP;

        // Setup slot
        _slot = 0;

        // Generate texture and bind data
        glGenTextures(1, &id);
        glBindTexture(_target, id);
        
        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

        for (int i = 0; i < paths.length; ++i) {
            string path = "../assets/skybox/" ~ paths[i];

            SDL_Surface *surface = IMG_Load(toStringz(path));
            enforce(surface, "can't load image `" ~ path ~ "`");

            // Read data from handler
            _width = surface.w;
            _height = surface.h;

            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, _width, _height, 0,
                         GL_RGB, GL_UNSIGNED_BYTE, surface.pixels);
            ++_nbTextures;

            SDL_FreeSurface(surface);
        }
    }

    /// Pass texture onto shader (@TODO DELETE, DEPRECATED)
    void forwardToShader(Shader shader, string uniform, GLuint unit) {
        GLuint texUni = glGetUniformLocation(shader.id, toStringz(uniform));

        shader.activate();
        glUniform1i(texUni, unit);
    }

    /// Bind texture
    void bind() const {
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(_target, id);
    }

    /// Bind texture
    void bind(GLuint slot) {
        glActiveTexture(GL_TEXTURE0 + slot);
        glBindTexture(_target, id);
    }

    /// Unbind texture
    static void unbind(GLenum target) {
        glBindTexture(target, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(_nbTextures, &id);
    }
}

/// Texture for multi sample FBOs
class MultiSampleTexture : Texture {
    /// Constructor for FBO multisample texture
    this(uint width, uint height, uint nbSamples) {
        super(width, height, GL_TEXTURE_2D_MULTISAMPLE, TextureType.multisample);

        // Generate and bind texture
        glGenTextures(1, &id);
        glBindTexture(_target, id);

        // Create texture
        glTexImage2DMultisample(_target, nbSamples, GL_RGB16F, _width, _height, GL_TRUE);
        
        // Setup filters
        glTextureParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTextureParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTextureParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTextureParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        // Bind to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _target, id, 0);
    }
}

/// Texture for post process FBOs
class PostProcessTexture : Texture {
    /// Constructor for FBO postprocess texture
    this(uint width, uint height) {
        super(width, height, GL_TEXTURE_2D, TextureType.postprocess);

        // Generate and bind texture
        glGenTextures(1, &id);
        glBindTexture(_target, id);

        // Create texture
        glTexImage2D(_target, 0, GL_RGB16F, _width, _height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
        
        // Setup filters
        glTextureParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTextureParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTextureParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTextureParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        // Bind to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _target, id, 0);
    }
}

/// Texture for shadow FBOs
class ShadowmapTexture : Texture {
    /// Constructor for FBO shadow
    this(uint width, uint height) {
        super(width, height, GL_TEXTURE_2D, TextureType.shadow);

        // Generate and bind texture
        glGenTextures(1, &id);
        glBindTexture(_target, id);

        // Create texture
        glTexImage2D(_target, 0, GL_DEPTH_COMPONENT, _width, _height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        
        // Setup filters
        glTextureParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTextureParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTextureParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTextureParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

        // Setup shadow color (black)
        float[] clampColor = [1.0, 1.0, 1.0, 1.0];
        glTexParameterfv(_target, GL_TEXTURE_BORDER_COLOR, clampColor.ptr);

        // Bind to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _target, id, 0);
    }
}