module magia.render.renderer;

import bindbc.opengl; /// @TODO remove (encapsulation should fix this)

import magia.core;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.data;
import magia.render.frame;
import magia.render.light;
import magia.render.material;
import magia.render.mesh;
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
    /// Active cameras
    Camera[] cameras;

    /// Lighting manager
    LightingManager lightingManager;

    private {
        // Coordinate system used for draws
        Coordinates _coordinates;

        // Shaders
        Shader _lineShader;
        Shader _quadShader;
        Shader _circleShader;
        Shader _modelShader;
        Shader _animatedShader;

        // Framebuffers for picking (@TODO pack?)
        FrameBuffer _pickingFrameBuffer;
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
        // Setup opengl debug
        glDebugMessageCallback(&openGLLogMessage, null);
        glEnable(GL_DEBUG_OUTPUT);
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

        // Set screen origin
        _coordinates = defaultCoordinates;

        // Setup lighing manager
        lightingManager = new LightingManager();

        // Load shaders for draw calls
        _lineShader = fetchPrototype!Shader("line");
        _quadShader = fetchPrototype!Shader("quad");
        _circleShader = fetchPrototype!Shader("circle");
        _modelShader = fetchPrototype!Shader("model");
        _animatedShader = fetchPrototype!Shader("animated");

        // Load frame buffers for post process effects
        _pickingFrameBuffer = new FrameBuffer([TextureType.picking, TextureType.depth],
                                              window.screenWidth, window.screenHeight);

        // Enable multi sampling and setup clear color
        glEnable(GL_MULTISAMPLE);
        glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
    }

    /// Clear rendered frame
    void clear() {
        // @TODO clear frame buffer
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
        glEnable(GL_DEPTH_TEST);
        glCullFace(GL_FRONT);
    }

    /// Update
    void update(TimeStep timeStep) {
        foreach (Camera camera; cameras) {
            camera.update(timeStep);
        }
    }
    
    /// Render line @TODO factorize mesh and use transform to parametrize line?
    void drawLine(vec3 start, vec3 end, Color color = Color.white, float alpha = 1f) {
        Mesh lineMesh = new Mesh(new VertexBuffer([
            start.x, start.y, start.z,
            end.x, end.y, end.z    
        ], layout3D));
        setupLineShader(color, alpha);
        drawIndexed(lineMesh, _lineShader, defaultMaterial, Transform.identity);
    }

    /// Render filled circle
    void drawFilledCircle(vec2 position, float size, Color color = Color.white, float alpha = 1f) {
        Transform transform = toScreenSpace(position, vec2(size, size));
        setupCircleShader(transform.position2D, transform.scale.x, color, alpha);
        drawIndexed(rectMesh, _circleShader, defaultMaterial, transform);
    }

    /// Render filled rectangle
    void drawFilledRect(vec2 position, vec2 size, Color color = Color.white, float alpha = 1f) {
        Transform transform = toScreenSpace(position, size);
        setupQuadShader(color, alpha);
        drawIndexed(rectMesh, _quadShader, defaultMaterial, transform);
    }

    /// Render a sprite @TODO handle rotation, alpha, color
    void drawTexture(Texture texture, vec2 position, vec2 size,
                     vec4i clip = vec4i.zero, Flip flip = Flip.none, Blend blend = Blend.alpha,
                     Color color = Color.white, float alpha = 1f) {
        // Create material
        Material material;
        material.textures ~= texture;

        // Set transform
        Transform transform = toScreenSpace(position, size);

        // Default clip has x, y = 0 and w, h = 1
        vec4 clipf = vec4(0f, 0f, 1f, 1f);

        // Cut texture depending on clip parameters
        // @TODO set in material instead
        if (clip != vec4i.zero) {
            clipf.x = cast(float) clip.x / cast(float) texture.width;
            clipf.y = cast(float) clip.y / cast(float) texture.height;
            clipf.z = clipf.x + (cast(float) clip.z / cast(float) texture.width);
            clipf.w = clipf.y + (cast(float) clip.w / cast(float) texture.height);
        }

        // Bind shader and uploaded dedicated uniforms
        _quadShader.activate();
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

        setupQuadShader(color, alpha);
        drawIndexed(rectMesh, _quadShader, material, transform);
    }

    /// Setup lights for all shaders that use them
    void setupLights() {
        lightingManager.setupInShader(_modelShader);
        lightingManager.setupInShader(_animatedShader);
    }

    private Transform toScreenSpace(vec2 position, vec2 size) {
        // Express size as ratio of size and screen size
        size = size / window.screenSize;

        // Express position as ratio of position and screen size
        position = _coordinates.origin + position / window.screenSize * 2 * _coordinates.axis + size * _coordinates.axis;

        // Set transform
        return Transform(vec3(position, 0), vec3(size, 0));
    }

    private void setupLineShader(Color color = Color.white, float alpha = 1f) {
        // Activate shader
        _lineShader.activate();

        // Set color
        // @TODO set in material instead
        _lineShader.uploadUniformVec4("u_Color", vec4(color.rgb, alpha));
    }

    private void setupQuadShader(Color color = Color.white, float alpha = 1f, Blend blend = Blend.alpha) {
        // Activate shader
        _quadShader.activate();

        // Set color
        // @TODO set in material instead
        _quadShader.uploadUniformVec4("u_Color", vec4(color.rgb, alpha));

        // Set blend
        // @TODO set in material instead
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

    private void setupCircleShader(vec2 position = vec2.zero, float size = 1f,
                                   Color color = Color.white, float alpha = 1f, Blend blend = Blend.alpha) {
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
    private void drawIndexed(Mesh mesh, Shader shader, Material material, Transform transform) {
        // One draw call per camera
        foreach (Camera camera; cameras) {
            shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            mesh.draw(shader, material, transform);
        }
    }
}

/// Debug messages thrown by openGL
version (linux) {
    extern (C) {
        void openGLLogMessage(GLenum, GLenum, GLuint, GLenum severity, GLsizei,
            const GLchar* message, void*) nothrow {
            switch (severity) {
            case GL_DEBUG_SEVERITY_HIGH:
                printf("[OPENGL][FATAL] %s\n", message);
                break;
            case GL_DEBUG_SEVERITY_MEDIUM:
                printf("[OPENGL][MEDIUM] %s\n", message);
                break;
            case GL_DEBUG_SEVERITY_LOW:
                printf("[OPENGL][MINOR] %s\n", message);
                break;
            case GL_DEBUG_SEVERITY_NOTIFICATION:
            default:
                printf("[OPENGL][INFO] %s\n", message);
                break;
            }
        }
    }
}
/// Ditto
version (Windows) {
    extern (Windows) {
        void openGLLogMessage(GLenum, GLenum, GLuint, GLenum severity, GLsizei,
            const GLchar* message, void*) nothrow {
            switch (severity) {
            case GL_DEBUG_SEVERITY_HIGH:
                printf("[OPENGL][FATAL] %s", message);
                break;
            case GL_DEBUG_SEVERITY_MEDIUM:
                printf("[OPENGL][MEDIUM] %s", message);
                break;
            case GL_DEBUG_SEVERITY_LOW:
                printf("[OPENGL][MINOR] %s", message);
                break;
            case GL_DEBUG_SEVERITY_NOTIFICATION:
            default:
                //printf("[OPENGL][INFO] %s", message);
                break;
            }
        }
    }
}
