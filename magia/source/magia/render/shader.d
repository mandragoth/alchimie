module magia.render.shader;

import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.typecons : Flag;

import bindbc.opengl;

import magia.core;
import magia.main;
import magia.render.window;

/// Class holding a shader
class Shader : Resource {
    /// Index
    GLuint id;

    private {
        GLuint _vertexShader;
        GLuint _fragmentShader;
    }

    /// Constructor given 1 file
    this(string filePath) {
        string text = Magia.res.readText(filePath);
        string vertexData;
        string fragmentData;

        bool readingVertex = false;
        bool readingFragment = false;
        foreach (string line; text.splitLines(KeepTerminator.yes)) {
            if (startsWith(line, "#type")) {
                line = strip(line);

                if (endsWith(line, "vert")) {
                    readingVertex = true;
                    readingFragment = false;
                } else if (endsWith(line, "frag")) {
                    readingVertex = false;
                    readingFragment = true;
                }
            } else if (readingVertex) {
                vertexData ~= line;
            } else if (readingFragment) {
                fragmentData ~= line;
            }
        }

        setupShaders(filePath, filePath, vertexData, fragmentData);
    }

    /// Constructor given 2 files
    this(string vertexFile, string fragmentFile) {
        string vertexData = Magia.res.readText(vertexFile);
        string fragmentData = Magia.res.readText(fragmentFile);
        setupShaders(vertexFile, fragmentFile, vertexData, fragmentData);
    }

    /// Copy constructor
    this(Shader other) {
        _vertexShader = other._vertexShader;
        _fragmentShader = other._fragmentShader;
    }

    /// Initialisation de la ressource
    void make() {
    }

    /// Accès à la ressource
    Resource fetch() {
        return this;
    }

    /// Shader turned on
    void activate() const {
        glUseProgram(id);
    }

    /// Shader turned off
    void remove() {
        glDeleteProgram(id);
        glDeleteShader(_vertexShader);
        glDeleteShader(_fragmentShader);
    }

    /// Upload an uniform of type bool to the shader
    void uploadUniformBool(const char* label, bool data) {
        GLint labelId = getShaderLocation(label);
        glUniform1i(labelId, data);
    }

    /// Upload an uniform of type int to the shader
    void uploadUniformInt(const char* label, int data) {
        GLint labelId = getShaderLocation(label);
        glUniform1i(labelId, data);
    }

    /// Upload an uniform of type float to the shader
    void uploadUniformFloat(const char* label, float data) {
        GLint labelId = getShaderLocation(label);
        glUniform1f(labelId, data);
    }

    /// Upload an uniform of type vec2 to the shader
    void uploadUniformVec2(const char* label, vec2 data) {
        GLint labelId = getShaderLocation(label);
        glUniform2f(labelId, data.x, data.y);
    }

    /// Upload an uniform of type vec3 to the shader
    void uploadUniformVec3(const char* label, vec3 data) {
        GLint labelId = getShaderLocation(label);
        glUniform3f(labelId, data.x, data.y, data.z);
    }

    /// Upload an uniform of type vec4 to the shader
    void uploadUniformVec4(const char* label, vec4 data) {
        GLint labelId = getShaderLocation(label);
        glUniform4f(labelId, data.x, data.y, data.z, data.w);
    }

    /// Upload an uniform of type mat4 to the shader
    void uploadUniformMat4(const char* label, mat4 data) {
        GLint labelId = getShaderLocation(label);
        glUniformMatrix4fv(labelId, 1, GL_TRUE, data.value_ptr);
    }

    private {
        void setupShaders(string vertexPath, string fragmentPath,
            string vertexData, string fragmentData) {
            const char* vertexSource = toStringz(vertexData);
            const char* fragmentSource = toStringz(fragmentData);

            _vertexShader = glCreateShader(GL_VERTEX_SHADER);
            glShaderSource(_vertexShader, 1, &vertexSource, null);
            glCompileShader(_vertexShader);
            compileErrors(_vertexShader, vertexPath, "Vertex");

            _fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
            glShaderSource(_fragmentShader, 1, &fragmentSource, null);
            glCompileShader(_fragmentShader);
            compileErrors(_fragmentShader, fragmentPath, "Fragment");

            id = glCreateProgram();
            glAttachShader(id, _vertexShader);
            glAttachShader(id, _fragmentShader);
            glLinkProgram(id);
        }

        void compileErrors(GLuint shaderId, string path, string type) {
            // Check if compilation OK
            GLint hasCompiled;
            glGetShaderiv(shaderId, GL_COMPILE_STATUS, &hasCompiled);

            if (hasCompiled == GL_FALSE) {
                // Get log size
                GLint maxSize = 0;
                glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &maxSize);

                // Create dynamic array and set its length to include NULL character
                GLchar[] infoLog;
                infoLog.length = maxSize;

                // Log type, source, error info
                glGetShaderInfoLog(shaderId, maxSize, &maxSize, infoLog.ptr);
                //write(type, " shader error for ", path, ": ", infoLog);
                assert(false, type ~ " shader error for " ~ path ~ ": " ~ infoLog);

                // Delete shader as we don't need it anymore
                //glDeleteShader(shaderId);
            }
        }

        GLint getShaderLocation(const char* label) {
            GLint labelId = glGetUniformLocation(id, label);

            if (labelId == GL_INVALID_VALUE || labelId == GL_INVALID_OPERATION) {
                throw new Exception("Error " ~ to!string(labelId,
                        16) ~ ": unable to get location of uniform " ~ to!string(label));
            }

            return labelId;
        }
    }
}
