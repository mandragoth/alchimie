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
import magia.render.texture;
import magia.render.window;

// @TODO remove or improve traces
import std.stdio;

/// Global renderer
Renderer renderer;

/// Representation of a 2D coordinate system
struct Coordinates {
    /// Origin
    vec2 origin;

    /// X,Y axis
    vec2 axis;
}

/// Default coordinate system
Coordinates defaultCoordinates = Coordinates(vec2.zero, vec2.one);

/// Topleft coordinate system
Coordinates topLeftCoordinates = Coordinates(vec2.topLeft, vec2.bottomRight);

/// 2D renderer
class Renderer {
    /// Renderer active camera
    Camera camera;

    private {
        Coordinates _coordinates;
        VertexArray _vertexArray;
        Shader _shader;
    }

    @property {
        /// Set background color
        void backgroundColor(Color color) {
            bgColor = color;
            glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
        }

        /// Set coordinates
        void coordinates(Coordinates coord) {
            _coordinates = coord;
        }
    }

    /// Constructor
    this(Camera camera_) {
        // Set screen origin
        _coordinates = defaultCoordinates;

        // Rectangle vertices
        float[] vertices = [
            -1f, -1f, 0f, 0f,
             1f, -1f, 1f, 0f,
             1f,  1f, 1f, 1f,
            -1f,  1f, 0f, 1f
        ];

        // Define shader layout
        BufferLayout layout = new BufferLayout([
            BufferElement("a_Position", LayoutType.ltFloat2),
            BufferElement("a_TexCoord", LayoutType.ltFloat2)
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
        _shader = new Shader("image.glsl");

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

    // @TODO create empty texture manually if texture not passed
    // Also to be used if 3D model has no texture
    // Use fetch!Resource pattern to avoid loading too many textures in memory

    /// Render the rectangle
    void drawFilledRect(vec2 origin, vec2 size, Color color = Color.white, float alpha = 1f) {
        Transform transform = Transform(vec3(origin, 0), vec3(size, 0));
        setupShader(transform.model, color, alpha);
        drawIndexed(_vertexArray);
    }

    /// Render a sprite @TODO handle rotation, alpha, color
    void drawTexture(Texture texture, vec2 position, vec2 size,
                     vec4i clip = vec4i.zero, Flip flip = Flip.none, Blend blend = Blend.alpha,
                     Color color = Color.white, float alpha = 1f) {
        // Express size as ratio of size and screen size
        size = size / screenSize;

        // Express position as ratio of position and screen size
        position = _coordinates.origin + position / screenSize * 2 * _coordinates.axis + size * _coordinates.axis;

        // Set transform
        Transform transform = Transform(vec3(position, 0), vec3(size, 0));

        // Default clip has x, y = 0 and w, h = 1
        vec4 clipf = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != vec4i.zero) {
            clipf.x = cast(float) clip.x / cast(float) texture.width;
            clipf.y = cast(float) clip.y / cast(float) texture.height;
            clipf.z = clipf.x + (cast(float) clip.z / cast(float) texture.width);
            clipf.w = clipf.y + (cast(float) clip.w / cast(float) texture.height);
        }

        texture.bind();
        _shader.uploadUniformInt("u_Texture", 0);
        _shader.uploadUniformVec4("u_Clip", clipf);

        // Set flip
        vec2 flipf;
        final switch (flip) with (Flip) {
            case none:
                flipf = vec2(0f, 0f);
                break;
            case horizontal:
                flipf = vec2(1f, 0f);
                break;
            case vertical:
                flipf = vec2(0f, 1f);
                break;
            case both:
                flipf = vec2(1f, 1f);
                break;
        }

        _shader.uploadUniformVec2("u_Flip", flipf);

        setupShader(transform.model, color, alpha);
        drawIndexed(_vertexArray);
    }

    private void setupShader(mat4 transform = mat4.identity, Color color = Color.white, float alpha = 1f, Blend blend = Blend.alpha) {
        // Activate shader
        _shader.activate();

        // Set color
        _shader.uploadUniformVec4("u_Color", vec4(color.r, color.g, color.b, alpha));

        // Set camera
        _shader.uploadUniformMat4("u_CamMatrix", camera.matrix);

        // Set transform
        _shader.uploadUniformMat4("u_Transform", transform);

        // Set blend
        /*final switch (blend) with (Blend) {
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