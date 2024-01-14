module magia.render.texture;

import bindbc.sdl;
import bindbc.opengl;

import magia.core;
import magia.main;

import std.exception;
import std.conv;
import std.path;
import std.stdio;
import std.string;

/// Possible types of textures
enum TextureType {
    sprite,
    diffuse,
    specular,
    cubemap,
    postprocess,
    multisample,
    shadowmap,
    picking,
    depth
}

// Trace
private {
    static bool s_Trace = false;
}

/// Class holding texture data
class Texture : Resource!Texture {
    protected {
        /// Texture index
        GLuint _id;

        // Teture image attributes
        int _width, _height;

        // Texture type
        TextureType _type;

        // Slot
        GLuint _slot;

        // Target
        GLenum _target;

        // Input image data format
        GLenum _dataFormat;

        // Internal texture format
        GLenum _internalFormat;

        // Internal texture type
        GLenum _memoryType;

        // Nb textures internally loaded
        uint _nbTextures = 0;
    }

    @property {
        /// Get texture id
        GLuint id() const {
            return _id;
        }

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

        /// Get texture size
        vec2 size() const {
            return vec2(_width, _height);
        }
    }

    /// Base constructor (used for inheriting classes)
    this(uint width, uint height, GLenum target, TextureType type) {
        _width = width;
        _height = height;
        _target = target;
        _type = type;
    }

    /// Constructor for empty texture
    this(uint width, uint height, uint data) {
        _type = TextureType.diffuse;
        _target = GL_TEXTURE_2D;
        _width = width;
        _height = height;

        glGenTextures(1, &_id);
        glBindTexture(_target, _id);

        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_REPEAT);

        _dataFormat = GL_RGBA;
        _internalFormat = GL_RGBA;

        assert(data.sizeof == width * height * 4);
        glTexImage2D(_target, 0, _internalFormat, _width, _height, 0,
            _dataFormat, GL_UNSIGNED_BYTE, &data);
        _nbTextures = 1;
    }

    /// Constructor for usual 2D texture from path
    this(string filePath, TextureType type = TextureType.sprite, GLuint slot = 0) {
        // Get surface and process it
        const(ubyte)[] data = Magia.res.read(filePath);
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        SDL_Surface* surface = IMG_Load_RW(rw, 1);
        enforce(surface, "can't load image `" ~ filePath ~ "`");

        // Setup data from surface
        setupData(surface, type, slot);

        // Free surface
        SDL_FreeSurface(surface);
    }

    /// Constructor for usual 2D texture from surface
    this(SDL_Surface* surface, TextureType type = TextureType.sprite, GLuint slot = 0) {
        setupData(surface, type, slot);
    }

    /// Copy constructor
    this(Texture texture_) {
        _id = texture_._id;
        _type = texture_.type;
        _width = texture_._width;
        _height = texture_._height;
        _slot = texture_._slot;
        _target = texture_._target;
        _nbTextures = texture_._nbTextures;
    }

    /// Accès à la ressource
    Texture fetch() {
        return this;
    }

    /// Setup data
    void setupData(SDL_Surface* surface, TextureType type, GLuint slot) {
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
        glGenTextures(1, &_id);
        glBindTexture(_target, _id);

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

        const uint nbChannels = surface.format.BytesPerPixel;

        if (s_Trace) {
            writeln("Loaded texture with ", nbChannels, " channels");
        }

        // For now, consider diffuses as RGBA, speculars as R
        if (nbChannels == 4) {
            _internalFormat = GL_RGBA;
            _dataFormat = GL_RGBA;
        } else if (nbChannels == 3) {
            _internalFormat = GL_RGB;
            _dataFormat = GL_RGB;
        } else if (nbChannels == 1) {
            _internalFormat = GL_RED;
            _dataFormat = GL_RED;
        } else {
            new Exception("Unsupported texture format for " ~ to!string(type) ~ " texture type");
        }

        // Generate texture image
        _memoryType = GL_UNSIGNED_BYTE;
        glTexImage2D(_target, 0, _internalFormat, _width, _height, 0,
            _dataFormat, _memoryType, surface.pixels);
        _nbTextures = 1;

        // Generate mipmaps
        if (type == TextureType.sprite) {
            glTexParameteri(_target, GL_TEXTURE_MAX_LEVEL, 0);
        } else {
            glGenerateMipmap(_target);
        }
    }

    /// Constructor for cubemap texture
    this(string[6] filePaths) {
        // Setup type
        _type = TextureType.cubemap;

        // Setup target
        _target = GL_TEXTURE_CUBE_MAP;

        // Setup slot
        _slot = 0;

        // Generate texture and bind data
        glGenTextures(1, &_id);
        glBindTexture(_target, _id);

        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

        // Setup formats
        _internalFormat = GL_RGB;
        _dataFormat = GL_RGB;
        _memoryType = GL_UNSIGNED_BYTE;

        for (int cubeMapId = 0; cubeMapId < filePaths.length; ++cubeMapId) {
            string filePath = filePaths[cubeMapId];
            const(ubyte)[] data = Magia.res.read(filePath);
            SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
            SDL_Surface* surface = IMG_Load_RW(rw, 1);
            enforce(surface, "can't load image `" ~ filePath ~ "`");

            // Read data from handler
            _width = surface.w;
            _height = surface.h;

            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + cubeMapId, 0, _internalFormat,
                _width, _height, 0, _dataFormat, _memoryType, surface.pixels);
            ++_nbTextures;

            SDL_FreeSurface(surface);
        }
    }

    /// Bind texture
    void bind() const {
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(_target, _id);
    }

    /// Bind texture
    void bind(GLuint slot) {
        glActiveTexture(GL_TEXTURE0 + slot);
        glBindTexture(_target, _id);
    }

    /// Unbind texture
    static void unbind(GLenum target) {
        glBindTexture(target, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(_nbTextures, &_id);
    }
}

/// Frame buffer texture
class FrameBufferTexture : Texture {
    // @TODO extract to parent class fully?
    protected {
        GLenum _attachment;
        GLint _wrapMode;
    }

    /// Constructor given frame buffer type
    this(TextureType type, uint width, uint height, uint nbSamples = 0) {
        GLenum target = GL_TEXTURE_2D;
        if (type == TextureType.multisample) {
            target = GL_TEXTURE_2D_MULTISAMPLE;
        }

        super(width, height, target, type);

        // Generate and bind texture
        glGenTextures(1, &_id);
        glBindTexture(_target, _id);

        _memoryType = GL_UNSIGNED_BYTE;
        _attachment = GL_COLOR_ATTACHMENT0;
        _wrapMode = GL_CLAMP_TO_EDGE;

        switch (type) {
        case TextureType.postprocess:
            _internalFormat = GL_RGB16F;
            _dataFormat = GL_RGB;
            break;
            // Data format/memory type not used for multi sample texture
        case TextureType.multisample:
            _internalFormat = GL_RGB16F;
            break;
            // A shadow map uses a depth texture
        case TextureType.shadowmap:
        case TextureType.depth:
            _internalFormat = GL_DEPTH_COMPONENT;
            _dataFormat = GL_DEPTH_COMPONENT;
            _memoryType = GL_FLOAT;
            _attachment = GL_DEPTH_ATTACHMENT;
            _wrapMode = GL_CLAMP_TO_BORDER;
            break;
        case TextureType.picking:
            _internalFormat = GL_RGB32UI;
            _dataFormat = GL_RGB_INTEGER;
            _memoryType = GL_UNSIGNED_INT;
            break;
        default:
            throw new Exception("Unsupported frame buffer type");
        }

        // Generate parametrized texture
        if (type == TextureType.multisample) {
            glTexImage2DMultisample(_target, nbSamples, _internalFormat, _width, _height, GL_TRUE);
        } else {
            glTexImage2D(_target, 0, _internalFormat, _width, _height, 0,
                _dataFormat, _memoryType, null);
        }

        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, _wrapMode);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, _wrapMode);

        // Setup shadow color (black)
        if (type == TextureType.shadowmap) {
            float[] clampColor = [1.0, 1.0, 1.0, 1.0];
            glTexParameterfv(_target, GL_TEXTURE_BORDER_COLOR, clampColor.ptr);
        }

        // Bind to frame buffer
        bindToFrameBuffer();
    }

    /// Bind to frame buffer
    void bindToFrameBuffer() {
        glFramebufferTexture2D(GL_FRAMEBUFFER, _attachment, _target, _id, 0);
    }

    /// Unbind from frame buffer
    void unbindFromFrameBuffer() {
        glFramebufferTexture2D(GL_FRAMEBUFFER, _attachment, target, 0, 0);
    }
}
