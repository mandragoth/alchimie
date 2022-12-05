module magia.shape.primitive.rect;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.vec2;
import magia.core.color;
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
RectPrototype rectPrototype;

/// Factory to create rectangles
class RectPrototype {
    private {
        VAO _VAO;
        Shader _shader;

        GLint _positionUniform;
        GLint _sizeUniform;
        GLint _colorUniform;
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

        _shader = new Shader("primitive.vert", "primitive.frag");
        _sizeUniform = glGetUniformLocation(_shader.id, "size");
        _positionUniform = glGetUniformLocation(_shader.id, "position");
        _colorUniform = glGetUniformLocation(_shader.id, "color");
    }

    /// Render the rectangle
    void drawFilledRect(Vec2f origin, Vec2f size, Color color = Color.white, float alpha = 1f) {
        origin = transformRenderSpace(origin) / screenSize();
        size = size * transformScale() / screenSize();

        _shader.activate();

        glUniform2f(_sizeUniform, size.x, size.y);
        glUniform2f(_positionUniform, origin.x, origin.y);
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        _VAO.bind();
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}