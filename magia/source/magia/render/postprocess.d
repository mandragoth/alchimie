module magia.render.postprocess;

import std.math;
import bindbc.opengl;

import magia.core.color;
import magia.render.array;
import magia.render.buffer;
import magia.render.frame;
import magia.render.shader;
import magia.render.rbo;

/// Controls the gamma function
static float gamma = 2.2f;

/// Background color
static Color bgColor = Color(.08f, .10f, .13f);

/// Background alpha
static float bgAlpha = 1f;

/// Number of samples
static uint nbSamples = 8;

/// Post-processing handler
class PostProcess {
    private {
        uint _size;

        VertexArray _vertexArray;
        FrameBuffer _postProcessFBO;
        FrameBuffer _multiSampleFBO;
        Shader _shader;
    }

    /// Constructor
    this(uint size) {
        _size = size;

        float[] rectangleVertices = [
            // Coords     // Texture coords
             1.0f, -1.0f,    1.0f, 0.0f,
            -1.0f, -1.0f,    0.0f, 0.0f,
            -1.0f,  1.0f,    0.0f, 1.0f,

             1.0f,  1.0f,    1.0f, 1.0f,
             1.0f, -1.0f,    1.0f, 0.0f,
            -1.0f,  1.0f,    0.0f, 1.0f,
        ];

        _shader = new Shader("postprocess.vert", "postprocess.frag");
        _shader.activate();
        glUniform1i(glGetUniformLocation(_shader.id, "screenTexture"), 0);
        glUniform1f(glGetUniformLocation(_shader.id, "gamma"), gamma);

        _vertexArray = new VertexArray();
        _vertexArray.bind();

        VertexBuffer vertexBuffer = new VertexBuffer(rectangleVertices);

        _vertexArray.linkAttributes(vertexBuffer, 0, 2, GL_FLOAT, 4 * float.sizeof, null);
        _vertexArray.linkAttributes(vertexBuffer, 1, 2, GL_FLOAT, 4 * float.sizeof, cast(void*)(2 * float.sizeof));

        _multiSampleFBO = new FrameBuffer(FBOType.Multisample, _size, nbSamples);
        RBO RBO_ = new RBO(_size, nbSamples);
        RBO_.attachFBO();
        FrameBuffer.check("multisample");

        _postProcessFBO = new FrameBuffer(FBOType.Postprocess, _size);
        FrameBuffer.check("postprocess");

        FrameBuffer.unbind();
        RBO.unbind();
        VertexArray.unbind();
    }

    /// Prepare postprocess
    void prepare() {
        // Bind frame buffer
        _multiSampleFBO.bind();

        // Adjust clear color depending on gamma
	    glClearColor(pow(bgColor.r, gamma), pow(bgColor.g, gamma), pow(bgColor.b, gamma), 1.0f);

        // Clear back buffer and depth buffer
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Enable depth testing
        glEnable(GL_DEPTH_TEST);
    }

    /// Draw postprocess
    void draw() {
        // Make it so the multisampling FBO is read while the post-processing FBO is drawn
        _multiSampleFBO.bindRead();
        _postProcessFBO.bindDraw();

        // Conclude the multisampling and copy it to the post-processing FBO
        FrameBuffer.blit(_size, _size);

        // Unbind frame buffer
        FrameBuffer.unbind();

        // Draw the frame buffer rectangle
        _shader.activate();
        _vertexArray.bind();

        // Prevents the frame buffer from being discarded
        glDisable(GL_DEPTH_TEST);

        // Bind texture onto post process FBO and draw it onto the screen
        _postProcessFBO.bindTexture();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}