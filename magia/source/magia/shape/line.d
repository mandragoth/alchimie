module magia.shape.line;

import bindbc.opengl;

import magia.core;

import magia.render.array;
import magia.render.buffer;
import magia.render.entity;
import magia.render.shader;

/// Line instance
class Line : Entity {
    private {
        VertexArray _vertexArray;

        vec3 _start;
        vec3 _end;
        vec3 _color;
    }

    /// Constructor
    this(vec3 start, vec3 end, vec3 color) {
        transform = Transform.identity;

        vec3[] vertices;
        vertices ~= start;
        vertices ~= end;

        _color = color;

        _vertexArray = new VertexArray();
        _vertexArray.bind();

        VertexBuffer vertexBuffer = new VertexBuffer(vertices);
        _vertexArray.linkAttributes(vertexBuffer, 0, 3, GL_FLOAT, vec3.sizeof, null);
    }

    /// Draw call
    void draw(Shader shader) {
        shader.activate();
        _vertexArray.bind();

        glUniformMatrix4fv(glGetUniformLocation(shader.id, "model"), 1, GL_TRUE, transform.model.value_ptr);
        glUniform3fv(glGetUniformLocation(shader.id, "color"), 1, _color.value_ptr);
        glDrawArrays(GL_LINES, 0, 2);
    }
}