module magia.render.vao;

import bindbc.opengl;

import magia.render.vbo;
import magia.render.ebo;

/// Class holding a Vertex Array Object
class VAO {
    /// Index
    GLuint id;

    /// Constructor
    this() {
        glGenVertexArrays(1, &id);
    }

    /// Link VAO to VBO
    void linkAttributes(VBO vbo, GLuint layout, GLint nbComponents, GLenum type, GLint stride, void * offset) const {
        vbo.bind();
        glVertexAttribPointer(layout, nbComponents, type, GL_FALSE, stride, offset);
        glEnableVertexAttribArray(layout);
        vbo.unbind();
    }

    /// Bind VAO
    void bind() const {
        glBindVertexArray(id);
    }

    /// Unbind VAO
    static void unbind() {
        glBindVertexArray(0);
    }

    /// Delete VAO
    void remove() const {
        glDeleteBuffers(1, &id);
    }
}