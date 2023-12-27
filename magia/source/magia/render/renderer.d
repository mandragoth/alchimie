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
        // @TODO clear frame buffer
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

        /// Render a texture
        void drawMaterial(Material material, mat4 model) {
            // Default clip has x, y = 0 and w, h = 1
            vec4 clipf = vec4(0f, 0f, 1f, 1f);

            // Cut texture depending on clip parameters
            // @TODO set in material instead
            if (material.clip != vec4i.zero) {
                clipf.x = cast(float) material.clip.x / cast(float) material.textures[0].width;
                clipf.y = cast(float) material.clip.y / cast(float) material.textures[0].height;
                clipf.z = clipf.x + (cast(float) material.clip.z / cast(float) material.textures[0].width);
                clipf.w = clipf.y + (cast(float) material.clip.w / cast(float) material.textures[0].height);
            }

            // Bind shader and uploaded dedicated uniforms
            quadShader.activate();
            quadShader.uploadUniformVec4("u_Clip", clipf);

            // Set flip
            vec2 flipf;
            final switch (material.flip) with (Flip) {
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

            quadShader.uploadUniformVec2("u_Flip", flipf);

            setupQuadShader(material);
            drawIndexed(rectMesh, quadShader, material, model);
        }
    } else static if (dimension_ == 3) {
        /// Prepare to render 3D items
        void setup() {
            glDisable(GL_BLEND);
            glEnable(GL_CULL_FACE);
            glEnable(GL_DEPTH_TEST);
            glCullFace(GL_FRONT);
        }

        /// Render line @TODO factorize mesh and use transform to parametrize line?
        /*void drawLine(vec3 start, vec3 end, Color color = Color.white, float alpha = 1f) {
            Mesh3D lineMesh = new Mesh3D(new VertexBuffer([
                start.x, start.y, start.z,
                end.x, end.y, end.z    
            ], layout3D));
            setupLineShader(color, alpha);
            drawIndexed(lineMesh, lineShader, defaultMaterial);
        }*/
    }

    /// Update
    void update() {
        foreach (Camera camera; cameras) {
            camera.update();
        }
    }

    private void setupLineShader(Color color = Color.white, float alpha = 1f) {
        // Activate shader
        lineShader.activate();

        // Set color
        // @TODO set in material instead
        lineShader.uploadUniformVec4("u_Color", vec4(color.rgb, alpha));
    }

    private void setupQuadShader(Material material) {
        // Activate shader
        quadShader.activate();

        // Set color
        quadShader.uploadUniformVec4("u_Color", vec4(material.color.rgb, material.alpha));

        // Set blend
        final switch (material.blend) with (Blend) {
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
        circleShader.uploadUniformVec4("u_Color", vec4(color.r, color.g, color.b, alpha));

        // Set position
        circleShader.uploadUniformVec2("u_Position", position);

        // Set position
        circleShader.uploadUniformFloat("u_Size", size);

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
    private void drawIndexed(Mesh!(dimension_) mesh, Shader shader, Material material, mat4 model) {
        // One draw call per camera
        foreach (Camera camera; cameras) {
            shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            mesh.draw(shader, material, model);
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
