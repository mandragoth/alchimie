module magia.render.renderer;

import bindbc.opengl; /// @TODO remove (encapsulation should fix this)

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.light;
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

    /// Lighting manager
    LightingManager lightingManager;

    private {
        // Coordinate system used for draws
        Coordinates _coordinates;

        // Default texture
        Texture _defaultTexture;

        // Cached meshs (geomerty)
        VertexArray _quadVertexArray;

        // Shaders
        Shader _quadShader;
        Shader _circleShader;
        Shader _modelShader;
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
    this() {
        // Set screen origin
        _coordinates = defaultCoordinates;

        // Quad vertices
        float[] quadVertices = [
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

        // Create and bind vertex array for quad rendering
        _quadVertexArray = new VertexArray();
        _quadVertexArray.bind();

        // Create vertex buffer and attach layout, set it in the vertex array
        VertexBuffer quadVertexBuffer = new VertexBuffer(quadVertices);
        quadVertexBuffer.layout = layout;
        _quadVertexArray.addVertexBuffer(quadVertexBuffer);

        // Create index buffer and set it into vertex buffer
        uint[] indices = [0, 1, 2, 2, 3, 0];
        _quadVertexArray.setIndexBuffer(new IndexBuffer(indices));

        // Setup lighing manager
        lightingManager = new LightingManager();

        // Load shaders for draw calls
        _quadShader = fetchPrototype!Shader("quad");
        _circleShader = fetchPrototype!Shader("circle");
        _modelShader = fetchPrototype!Shader("model");

        // Default white pixel texture to be used if one is required and none provided
        _defaultTexture = new Texture(1, 1, 0xffffffff);

        glEnable(GL_MULTISAMPLE);
        glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
    }

    /// Clear rendered frame
    void clear() {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    /// Prepare to render 2D items
    void setup2DRender() {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
    }

    /// Prepare to render 3D items
    void setup3DRender() {
        glDisable(GL_BLEND);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_FRONT);
    }

    /// Update
    void update(TimeStep timeStep) {
        if (camera) {
            camera.update(timeStep);
        }
    }

    // Also to be used if 3D model has no texture
    // Use fetch!Resource pattern to avoid loading too many textures in memory

    /// Render filled circle
    void drawFilledCircle(vec2 position, float size, Color color = Color.white, float alpha = 1f) {
        _defaultTexture.bind();

        _circleShader.activate();
        _circleShader.uploadUniformInt("u_Texture", 0);

        Transform transform = toScreenSpace(position, vec2(size, size));
        setupCircleShader(transform.model, transform.position2D, transform.scale.x, color, alpha);
        drawIndexed(_quadVertexArray);
    }

    /// Render filled rectangle
    void drawFilledRect(vec2 position, vec2 size, Color color = Color.white, float alpha = 1f) {
        _defaultTexture.bind();

        _quadShader.activate();
        _quadShader.uploadUniformInt("u_Texture", 0);

        Transform transform = toScreenSpace(position, size);
        setupQuadShader(transform.model, color, alpha);
        drawIndexed(_quadVertexArray);
    }

    /// Render a sprite @TODO handle rotation, alpha, color
    void drawTexture(Texture texture, vec2 position, vec2 size,
                     vec4i clip = vec4i.zero, Flip flip = Flip.none, Blend blend = Blend.alpha,
                     Color color = Color.white, float alpha = 1f) {
        // Set transform
        Transform transform = toScreenSpace(position, size);

        // Default clip has x, y = 0 and w, h = 1
        vec4 clipf = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        if (clip != vec4i.zero) {
            clipf.x = cast(float) clip.x / cast(float) texture.width;
            clipf.y = cast(float) clip.y / cast(float) texture.height;
            clipf.z = clipf.x + (cast(float) clip.z / cast(float) texture.width);
            clipf.w = clipf.y + (cast(float) clip.w / cast(float) texture.height);
        }

        // Bind texture and shader
        texture.bind();
        _quadShader.activate();

        _quadShader.uploadUniformInt("u_Texture", 0);
        _quadShader.uploadUniformVec4("u_Clip", clipf);

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

        _quadShader.uploadUniformVec2("u_Flip", flipf);

        setupQuadShader(transform.model, color, alpha);
        drawIndexed(_quadVertexArray);
    }

    /// Setup lights for all shaders that use them
    void setupLights() {
        lightingManager.setupInShader(_modelShader);
    }

    private Transform toScreenSpace(vec2 position, vec2 size) {
        // Express size as ratio of size and screen size
        size = size / screenSize;

        // Express position as ratio of position and screen size
        position = _coordinates.origin + position / screenSize * 2 * _coordinates.axis + size * _coordinates.axis;

        // Set transform
        return Transform(vec3(position, 0), vec3(size, 0));
    }

    private void setupQuadShader(mat4 transform = mat4.identity,
                                 Color color = Color.white, float alpha = 1f, Blend blend = Blend.alpha) {
        // Set camera
        _quadShader.uploadUniformMat4("u_CamMatrix", camera.matrix);

        // Set transform
        _quadShader.uploadUniformMat4("u_Transform", transform);

        // Set color
        _quadShader.uploadUniformVec4("u_Color", vec4(color.rgb, alpha));

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

    private void setupCircleShader(mat4 transform = mat4.identity, vec2 position = vec2.zero, float size = 1f,
                                   Color color = Color.white, float alpha = 1f, Blend blend = Blend.alpha) {
        // Set camera
        _circleShader.uploadUniformMat4("u_CamMatrix", camera.matrix);

        // Set transform
        _circleShader.uploadUniformMat4("u_Transform", transform);

        // Set color
        _circleShader.uploadUniformVec4("u_Color", vec4(color.r, color.g, color.b, alpha));

        // Set position
        _circleShader.uploadUniformVec2("u_Position", position);

        // Set position
        _circleShader.uploadUniformFloat("u_Size", size);

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
    private void drawIndexed(const ref VertexArray vertexArray) {
        vertexArray.bind();
        glDrawElements(GL_TRIANGLES, vertexArray.indexBuffer.count, GL_UNSIGNED_INT, null);
    }
}