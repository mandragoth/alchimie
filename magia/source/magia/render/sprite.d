module magia.render.sprite;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import gl3n.linalg;
import magia.core;
import magia.render.texture;
import magia.render.shader;
import magia.render.vao;
import magia.render.vbo;
import magia.render.window;

/// Indicate if something is mirrored.
enum Flip {
    none,
    horizontal,
    vertical,
    both
}

/// Blending algorithm \
/// none: Paste everything without transparency \
/// modular: Multiply color value with the destination \
/// additive: Add color value with the destination \
/// alpha: Paste everything with transparency (Default one)
enum Blend {
    none,
    //modular,
    additive,
    alpha
}

/// Base rendering class.
final class Sprite {
    private {
        // @TODO factorize prototype (rect)
        VAO _VAO;

        // @TODO factorize shader load (one for all sprites)
        Shader _shader;
        GLint _clipUniform;
        GLint _flipUniform;
        GLint _colorUniform;
        GLint _modelUniform;

        // @TODO texture cache?
        Texture _texture;

        // @TODO defer to texture?
        SDL_Surface* _surface = null;
        uint _width, _height;
        bool _isLoaded, _ownData;
    }

    @property {
        /// loaded ?
        bool isLoaded() const {
            return _isLoaded;
        }
        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }
    }

    /// Constructor
    this(Sprite sprite) {
        _isLoaded = sprite._isLoaded;
        _width = sprite._width;
        _height = sprite._height;
        _shader = sprite._shader;
        _texture = sprite._texture;
        _VAO = sprite._VAO;
        _clipUniform = sprite._clipUniform;
        _flipUniform = sprite._flipUniform;
        _colorUniform = sprite._colorUniform;
        _modelUniform = sprite._modelUniform;
        _ownData = false;
    }

    /// Constructor given an SDL surface
    this(SDL_Surface* surface, bool preload = false) {
        // Image data
        _surface = surface;
        enforce(_surface, "invalid surface");

        _width = _surface.w;
        _height = _surface.h;

        if (!preload) {
            postload();
        }
    }

    /// Constructor given an image path
    this(string path, bool preload = false) {
        // Image data
        _surface = IMG_Load(toStringz(path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        _width = _surface.w;
        _height = _surface.h;
        _ownData = true;

        if (!preload) {
            postload();
        }
    }

    ~this() {
        unload();
    }

    package void load(SDL_Surface* surface) {
        _width = surface.w;
        _height = surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Call it if you set the preload flag on ctor.
    void postload() {
        if (_isLoaded) {
            return;
        }

        _texture = new Texture(_surface, "sprite");

        if (_ownData) {
            SDL_FreeSurface(_surface);
            _surface = null;
        }

        // Rectangle vertices
        vec2[] vertices = [
	        vec2( 1.0f,  1.0f),
	        vec2(-1.0f,  1.0f),
	        vec2( 1.0f, -1.0f),
	        vec2(-1.0f, -1.0f)
        ];

        _VAO = new VAO();
        _VAO.bind();

        VBO _VBO = new VBO(vertices);
        _VAO.linkAttributes(_VBO, 0, 2, GL_FLOAT, vec2.sizeof, null);

        _shader = new Shader("sprite.vert", "sprite.frag");
        _clipUniform = glGetUniformLocation(_shader.id, "clip");
        _flipUniform = glGetUniformLocation(_shader.id, "flip");
        _colorUniform = glGetUniformLocation(_shader.id, "color");
        _modelUniform = glGetUniformLocation(_shader.id, "model");
    }

    /// Free image data
    void unload() {
        if (!_ownData) {
            return;
        }

        _shader.remove();
        _texture.remove();
        _isLoaded = false;
    }

    /// Draw sprite at given position
    void draw(mat4 transform, float posX, float posY, float sizeX, float sizeY,
              Vec4i clip, Flip flip = Flip.none, Blend blend = Blend.alpha,
              Color color = Color.white, float alpha = 1f) const {
        // Select flip
        final switch (flip) with (Flip) {
            case none:
                glUniform2f(_flipUniform, 0f, 0f);
                break;
            case horizontal:
                glUniform2f(_flipUniform, 1f, 0f);
                break;
            case vertical:
                glUniform2f(_flipUniform, 0f, 1f);
                break;
            case both:
                glUniform2f(_flipUniform, 1f, 1f);
                break;
        }

        _texture.bind();
        _shader.activate();

        const float clipX = cast(float) clip.x / cast(float) _width;
        const float clipY = cast(float) clip.y / cast(float) _height;
        const float clipW = clipX + (cast(float) clip.z / cast(float) _width);
        const float clipH = clipY + (cast(float) clip.w / cast(float) _height);

        glUniform4f(_clipUniform, clipX, clipY, clipW, clipH);
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        mat4 local = mat4.identity;
        local.scale(sizeX, sizeY, 1f);
        local.translate(posX * 2f + sizeX, posY * 2f + sizeY, 0f);
        transform = transform * local;

        glUniformMatrix4fv(_modelUniform, 1, GL_TRUE, transform.value_ptr);

        _VAO.bind();

        glEnable(GL_BLEND);
        final switch (blend) with (Blend) {
            case none:
                glBlendFuncSeparate(GL_SRC_COLOR, GL_ZERO, GL_ONE, GL_ZERO);
                glBlendEquation(GL_FUNC_ADD);
                break;
            case additive:
                glBlendFuncSeparate(GL_SRC_ALPHA, GL_DST_COLOR, GL_ZERO, GL_ONE);
                glBlendEquation(GL_FUNC_ADD);
                break;
            case alpha:
                glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
                glBlendEquation(GL_FUNC_ADD);
                break;
        }
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
    }
}
