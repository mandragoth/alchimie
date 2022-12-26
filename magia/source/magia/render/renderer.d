module magia.render.renderer;

import bindbc.opengl; /// @TODO remove (encapsulation should fix this)

import magia.core.color;
import magia.core.mat;
import magia.core.vec;

import magia.render.camera;
import magia.render.material;
import magia.render.shader;
import magia.render.sprite;
import magia.render.vao;
import magia.render.vbo;
import magia.render.window;

/// Global renderer
Renderer renderer;

/// 2D renderer
class Renderer {
    private {
        VAO _VAO;
        Shader _shader;

        // @TODO remove / factorize
        GLint _resolutionUniform;
        GLint _positionUniform;
        GLint _sizeUniform;
        GLint _modelUniform;
        GLint _clipUniform;
        GLint _colorUniform;
        GLint _flipUniform;
    }

    /// Constructor
    this() {
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

        _shader = new Shader("image.vert", "image.frag");
        _sizeUniform = glGetUniformLocation(_shader.id, "size");
        _positionUniform = glGetUniformLocation(_shader.id, "position");
        _colorUniform = glGetUniformLocation(_shader.id, "color");
    }

    /// Prepare to render 2D items
    void setup2DRender() {
        glDisable(GL_DEPTH_TEST);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        glDisable(GL_CULL_FACE);
    }

    /// Prepare to render 3D items
    void setup3DRender() {
        glEnable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glEnable(GL_CULL_FACE);
    }

    /// Render the rectangle
    void drawFilledRect(vec2 origin, vec2 size, Color color = Color.white, float alpha = 1f) {
        origin = transformRenderSpace(origin) / screenSize();
        size = size * transformScale() / screenSize();

        setupShader(origin, size, color, alpha);
        drawCall();
    }

    /// Render a circle
    void drawFilledCircle(vec2 center, float radius, Color color = Color.white, float alpha = 1f) {
        setupShader(center, vec2(radius, radius), color, alpha);
        drawCall();
    }

    /// Render a sprite @TODO handle clip, transform, sprite
    void drawSprite(Sprite sprite, mat4 transform, float posX, float posY, float sizeX, float sizeY,
                    vec4i clip, Flip flip = Flip.none, Blend blend = Blend.alpha,
                    Color color = Color.white, float alpha = 1f) {
        // Cut texture depending on clip parameters
        const float clipX = cast(float) clip.x / cast(float) sprite.width;
        const float clipY = cast(float) clip.y / cast(float) sprite.height;
        const float clipW = clipX + (cast(float) clip.z / cast(float) sprite.width);
        const float clipH = clipY + (cast(float) clip.w / cast(float) sprite.height);

        // Remap global clip
        vec4 clipf = vec4(clipX, clipY, clipW, clipH);

        setupShader(vec2(posX, posY), vec2(sizeX, sizeY), color, alpha, transform, clipf, flip, blend);
        drawCall();
    }

    private void setupShader(vec2 pos, vec2 size, Color color = Color.white, float alpha = 1f,
                             mat4 transform = mat4.identity, vec4 clip = vec4.one,
                             Flip flip = Flip.none, Blend blend = Blend.alpha) {
        // Activate shader
        _shader.activate();

        // Set resolution
        vec2i resolution = getWindowSize();
        glUniform2f(_resolutionUniform, resolution.x, resolution.y);

        // Set model
        mat4 local = mat4.identity;
        local.scale(size.x, size.y, 1f);
        local.translate(pos.x * 2f + size.x, pos.y * 2f + size.y, 0f);
        transform = transform * local;
        glUniformMatrix4fv(_modelUniform, 1, GL_TRUE, transform.value_ptr);

        // Set clip
        glUniform4f(_clipUniform, clip.x, clip.y, clip.z, clip.w);

        // Set color
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        // Set flip
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

        // Set blend
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
    }

    /// @TODO batching
    private void drawCall() {
        _VAO.bind();
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}