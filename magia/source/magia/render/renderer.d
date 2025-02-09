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
import magia.render.pool;
import magia.render.shader;
import magia.render.sprite;
import magia.render.texture;
import magia.render.window;
import magia.shape.rect;

import std.stdio;

/// Renderer
class Renderer(uint dimension_) {
    /// Active window
    Window window;

    /// Coordinate system
    Cartesian!(dimension_) cartesian;

    /// Active cameras
    Camera[] cameras;

    private {
        // Framebuffers for picking (@TODO pack?)
        FrameBuffer _pickingFrameBuffer;
    }

    @property {
        /// Set background color
        void backgroundColor(Color color) {
            bgColor = color;
            glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
        }
    }

    /// Constructor
    this(Window window_, Cartesian!(dimension_) cartesian_) {
        // Set window and screen origin
        window = window_;
        cartesian = cartesian_;

        // Load frame buffers for post process effects
        _pickingFrameBuffer = new FrameBuffer([TextureType.picking, TextureType.depth],
                                              window.screenWidth, window.screenHeight);

        // Enable multi sampling and setup clear color
        glEnable(GL_MULTISAMPLE);
        glClearColor(bgColor.r, bgColor.g, bgColor.b, 1f);
    }

    /// Clear rendered frame
    void clear() {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    /// Adjust a transform to render it
    Transform!(dimension_) toRenderSpace(Transform!(dimension_) transform) {
        return cartesian.toRenderSpace(transform);
    }

    static if (dimension_ == 2) {
        /// Prepare to render 2D items
        void setup() {
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glDisable(GL_DEPTH_TEST);
            glDisable(GL_CULL_FACE);
        }
    } else static if (dimension_ == 3) {
        /// Prepare to render 3D items
        void setup() {
            glDisable(GL_BLEND);
            glEnable(GL_CULL_FACE);
            glEnable(GL_DEPTH_TEST);
            glCullFace(GL_FRONT);
        }
    }

    // Set blend to alpha
    private void setBlendAlpha() {
        glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
        glBlendEquation(GL_FUNC_ADD);
    }

    /// Draw a mesh with a texture array
    void draw(type)(Mesh!(dimension_) mesh, Shader shader, Texture[] textures, type[] instanceData = []) {
        // Set per instance data
        if (instanceData) {
            mesh.setInstanceData(instanceData);
        }

        // Activate shader
        shader.activate();

        // Setup uniform data (@TODO handle)
        //shader.setupUniformData();

        // One draw call per camera
        foreach (Camera camera; cameras) {
            shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            mesh.draw(shader, textures);
        }
    }

    /// Draw a mesh with a compute shader texture
    void draw(type)(Mesh!(dimension_) mesh, Shader shader, ComputeShaderTexture texture, type[] instanceData = []) {
        // Set per instance data
        if (instanceData) {
            mesh.setInstanceData(instanceData);
        }

        // One draw call per camera
        foreach (Camera camera; cameras) {
            mesh.draw(shader, [texture], camera.matrix);
        }
    }

    /// Draw an indexed mesh
    void drawIndexed(Mesh!(dimension_) mesh, Shader shader, Texture[] textures) {
        // Activate shader
        shader.activate();

        // One draw call per camera
        foreach (Camera camera; cameras) {
            shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            mesh.draw(shader, textures);
        }
    }

    /// Draw an indexed mesh @TODO batching
    private void drawIndexed(Mesh!(dimension_) mesh, Shader shader, Texture[] textures, mat4 model) {
        // One draw call per camera
        foreach (Camera camera; cameras) {
            shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            mesh.draw(shader, textures, model);
        }
    }
}

/// Global renderer
alias Renderer2D = Renderer!(2);
alias Renderer3D = Renderer!(3);

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
