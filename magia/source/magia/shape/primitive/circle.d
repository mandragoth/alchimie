module magia.shape.primitive.circle;

import bindbc.opengl;

import magia.core.color;
import magia.core.vec;

import magia.render.mesh;
import magia.render.scene;
import magia.render.shader;
import magia.render.vertex;
import magia.render.window;
import magia.render.camera;
import magia.render.vao;
import magia.render.vbo;

import std.string;
import std.stdio;

/// Singletong instance
CirclePrototype circlePrototype;

/// Factory to create circles
class CirclePrototype {
    private {
        VAO _VAO;
        VBO _VBO;
        Shader _shader;

        GLint _resolutionUniform;
        GLint _positionUniform;
        GLint _sizeUniform;
        GLint _colorUniform;
    }

    /// Constructor
    this() {
        // Circle vertices
        vec2[] vertices = [
	        vec2( 1.0f,  1.0f),
	        vec2(-1.0f,  1.0f),
	        vec2( 1.0f, -1.0f),
	        vec2(-1.0f, -1.0f)
        ];

        _VAO = new VAO();
        _VAO.bind();

        _VBO = new VBO(vertices);
        _VAO.linkAttributes(_VBO, 0, 2, GL_FLOAT, vec2.sizeof, null);

        _shader = new Shader("circle.vert", "circle.frag");
        _resolutionUniform = glGetUniformLocation(_shader.id, "resolution");
        _sizeUniform = glGetUniformLocation(_shader.id, "size");
        _positionUniform = glGetUniformLocation(_shader.id, "position");
        _colorUniform = glGetUniformLocation(_shader.id, "color");
    }

    /// Render a circle
    void drawFilledCircle(vec2 center, float radius, Color color = Color.white, float alpha = 1f) {
        _shader.activate();

        vec2i resolution = getWindowSize();

        glUniform2f(_resolutionUniform, resolution.x, resolution.y);
        glUniform1f(_sizeUniform, radius);
        glUniform2f(_positionUniform, center.x, center.y);
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        _VAO.bind();
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}