module magia.render.shader;

import std.file, std.string, std.stdio;

import bindbc.opengl;

import magia.core.mat;
import magia.render.window;

/// Class holding a shader
class Shader {
    /// Index
    GLuint id;

    private {
        GLuint _vertexShader;
        GLuint _fragmentShader;
    }

    /// Constructor
    this(string vertexFile, string fragmentFile) {
        const char* vertexSource = toStringz(readText("../assets/shader/" ~ vertexFile));
        const char* fragmentSource = toStringz(readText("../assets/shader/" ~ fragmentFile));

        // Setup shader program
        _vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(_vertexShader, 1, &vertexSource, null);
        glCompileShader(_vertexShader);
        compileErrors(_vertexShader, vertexFile, "VERTEX");

        _fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(_fragmentShader, 1, &fragmentSource, null);
        glCompileShader(_fragmentShader);
        compileErrors(_fragmentShader, fragmentFile, "FRAGMENT");

        id = glCreateProgram();
        glAttachShader(id, _vertexShader);
        glAttachShader(id, _fragmentShader);
        glLinkProgram(id);
    }

    /// Shader turned on
    void activate() const {
        setShaderProgram(id);
    }

    /// Shader turned off
    void remove() {
        glDeleteProgram(id);
        glDeleteShader(_vertexShader);
        glDeleteShader(_fragmentShader);
    }

    /// Upload an uniform of type mat4 to the shader
    void uploadUniformMat4(const char* label, mat4 matrix) {
        GLint labelId = glGetUniformLocation(id, label);
        glUniformMatrix4fv(labelId, 1, GL_TRUE, matrix.value_ptr);
    }

    private {
        void compileErrors(GLuint shaderId, string source, string type) {
            GLint hasCompiled;
            char[1024] infoLog;

            if (type != "PROGRAM") {
                glGetShaderiv(shaderId, GL_COMPILE_STATUS, &hasCompiled);

                if (hasCompiled == GL_FALSE) {
                    glGetShaderInfoLog(shaderId, 1024, null, infoLog.ptr);
                    writeln("SHADER COMPILER ERROR FOR ", type, ": ", source);
                }
            } else {
                glGetProgramiv(shaderId, GL_COMPILE_STATUS, &hasCompiled);

                if (hasCompiled == GL_FALSE) {
                    glGetProgramInfoLog(shaderId, 1024, null, infoLog.ptr);
                    writeln("SHADER LINKING ERROR FOR ", type, ": ", source);
                }
            }
        }
    }
}