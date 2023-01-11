module magia.render.renderer;

import bindbc.opengl; /// @TODO remove (encapsulation should fix this)

import magia.core.color;
import magia.core.mat;
import magia.core.timestep;
import magia.core.transform;
import magia.core.vec;

import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.material;
import magia.render.postprocess;
import magia.render.shader;
import magia.render.sprite;
import magia.render.window;

// @TODO remove
import std.stdio;

/// 2D renderer
class Renderer {
    Camera camera;

    private {
        VertexArray _vertexArray;
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

    @property {
        /// Set background color
        void backgroundColor(Color color) {
            bgColor = color;
            glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
        }
    }

    /// Constructor
    this(Camera camera_) {
        // Rectangle vertices @TODO size should be -1/1 for full screen to multiply by size
        vec2[] vertices = [
            vec2(-1f, -1f),
            vec2( 1f, -1f),
            vec2( 1f,  1f),
            vec2(-1f,  1f)
        ];

        // Define shader layout
        BufferLayout layout = new BufferLayout([
            BufferElement("a_Position", LayoutType.ltFloat2)
        ]);

        // Create and bind vertex array
        _vertexArray = new VertexArray();
        _vertexArray.bind();

        // Create vertex buffer and attach layout, set it in the vertex array
        VertexBuffer vertexBuffer = new VertexBuffer(vertices);
        vertexBuffer.layout = layout;
        _vertexArray.addVertexBuffer(vertexBuffer);

        // Create index buffer and set it into vertex buffer
        uint[] indices = [0, 1, 2, 2, 3, 0];
        _vertexArray.setIndexBuffer(new IndexBuffer(indices));

        // Load global shader to render 2D textured/colored quads
        _shader = new Shader("image.vert", "image.frag");
        _sizeUniform = glGetUniformLocation(_shader.id, "size");
        _positionUniform = glGetUniformLocation(_shader.id, "position");
        _colorUniform = glGetUniformLocation(_shader.id, "color");

        glEnable(GL_MULTISAMPLE);
        glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);

        camera = camera_;
    }

    /// Clear rendered frame
    void clear() {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
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
        glCullFace(GL_FRONT);
    }

    /// Update
    void update(TimeStep timeStep) {
        camera.update(timeStep);
    }

    /// Render the rectangle
    void drawFilledRect(vec2 origin, vec2 size, Color color = Color.white, float alpha = 1f) {
        origin = transformRenderSpace(origin) / screenSize();
        size = size * transformScale() / screenSize();

        Transform transform = Transform(vec3(origin, 0), vec3(size, 0));
        setupShader(transform.model, color, alpha);
        drawIndexed(_vertexArray);
    }

    /// Render a circle
    void drawFilledCircle(vec2 center, float radius, Color color = Color.white, float alpha = 1f) {
        Transform transform = Transform(vec3(center, 0), vec3(radius, radius, 0));
        setupShader(transform.model, color, alpha);
        drawIndexed(_vertexArray);
    }

    /// Render a sprite @TODO handle clip, transform, sprite
    void drawSprite(Sprite sprite, Transform transform,
                    vec4i clip, Flip flip = Flip.none, Blend blend = Blend.alpha,
                    Color color = Color.white, float alpha = 1f) {
        // Cut texture depending on clip parameters
        const float clipX = cast(float) clip.x / cast(float) sprite.width;
        const float clipY = cast(float) clip.y / cast(float) sprite.height;
        const float clipW = clipX + (cast(float) clip.z / cast(float) sprite.width);
        const float clipH = clipY + (cast(float) clip.w / cast(float) sprite.height);

        // Remap global clip
        vec4 clipf = vec4(clipX, clipY, clipW, clipH);

        setupShader(transform.model, color, alpha, clipf, flip, blend);
        drawIndexed(_vertexArray);
    }

    private void setupShader(mat4 transform = mat4.identity, Color color = Color.white, float alpha = 1f,
                             vec4 clip = vec4.one, Flip flip = Flip.none, Blend blend = Blend.alpha) {
        // Activate shader
        _shader.activate();

        // Set color
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        // Set camera
        _shader.uploadUniformMat4("camMatrix", camera.matrix);

        // Set transform
        _shader.uploadUniformMat4("transform", transform);

        // Set resolution
        /*vec2i resolution = getWindowSize();
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
        }*/
    }

    /// Submit a vertex array to the render queue
    void submit(VertexArray vertexArray) {

    }

    /// @TODO batching
    void drawIndexed(const VertexArray vertexArray) {
        vertexArray.bind();
        glDrawElements(GL_TRIANGLES, vertexArray.indexBuffer.count, GL_UNSIGNED_INT, null);
    }
}