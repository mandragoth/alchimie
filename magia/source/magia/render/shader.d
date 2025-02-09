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
import magia.render.texture;
import magia.render.window;

/// Class holding a shader
class Shader : Resource!Shader {
    private {
        enum Type {
            VERTEX,
            FRAGMENT,
            COMPUTE,
            NONE
        }

        GLuint _id;
        GLuint _computeId;
        GLuint _vertexShader;
        GLuint _fragmentShader;
        GLuint _computeShader;
        vec3u  _computeGroups;
    }

    /// Constructor given 1 file
    this(string filePath) {
        string text = Magia.res.readText(filePath);
        string vertexData;
        string fragmentData;
        string computeData;

        Type readingType = Type.NONE;
        foreach (string line; text.splitLines(KeepTerminator.yes)) {
            if (startsWith(line, "#type")) {
                line = strip(line);

                if (endsWith(line, "vert")) {
                    readingType = Type.VERTEX;
                } else if (endsWith(line, "frag")) {
                    readingType = Type.FRAGMENT;
                } else if (endsWith(line, "comp")) {
                    readingType = Type.COMPUTE;
                }
            } else if (readingType == Type.VERTEX) {
                vertexData ~= line;
            } else if (readingType == Type.FRAGMENT) {
                fragmentData ~= line;
            } else if (readingType == Type.COMPUTE) {
                computeData ~= line;
            }
        }

        setupShaders(filePath, vertexData, fragmentData, computeData);
    }

    /// Copy constructor
    this(Shader other) {
        _vertexShader = other._vertexShader;
        _fragmentShader = other._fragmentShader;
    }

    /// Accès à la ressource
    Shader fetch() {
        return this;
    }

    /// Shader turned on
    void activate() const {
        if (_computeShader) {
            glUseProgram(_computeId);
            glDispatchCompute(_computeGroups.x, _computeGroups.y, _computeGroups.z);
            // @TODO parametrize barrier
            glMemoryBarrier(GL_ALL_BARRIER_BITS);
        }

        if (_vertexShader || _fragmentShader) {
            glUseProgram(_id);
        }
    }

    void setComputeDispatch(uint numGroupsX, uint numGroupsY, uint numGroupsZ) {
        _computeGroups = vec3u(numGroupsX, numGroupsY, numGroupsZ);
    }

    /// Shader turned off
    void remove() {
        glDeleteProgram(_id);
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
        //writeln("label: ", to!string(label));
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
        void setupShaders(string filePath,
                          string vertexData,
                          string fragmentData,
                          string computeData) {
            const bool hasVertex = !vertexData.empty();
            const bool hasFragment = !fragmentData.empty();
            const bool hasCompute = !computeData.empty();

            if (hasVertex) {
                const char* vertexSource = toStringz(vertexData);
                _vertexShader = glCreateShader(GL_VERTEX_SHADER);
                glShaderSource(_vertexShader, 1, &vertexSource, null);
                glCompileShader(_vertexShader);
                compileErrors(_vertexShader, filePath, "Vertex");
            }

            if (hasFragment) { 
                const char* fragmentSource = toStringz(fragmentData);
                _fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
                glShaderSource(_fragmentShader, 1, &fragmentSource, null);
                glCompileShader(_fragmentShader);
                compileErrors(_fragmentShader, filePath, "Fragment");
            }

            if (hasCompute) {  
                const char* computeSource = toStringz(computeData);
                _computeShader = glCreateShader(GL_COMPUTE_SHADER);
                glShaderSource(_computeShader, 1, &computeSource, null);
                glCompileShader(_computeShader);
                compileErrors(_computeShader, filePath, "Compute");
            }

            _id = glCreateProgram();
            
            if (hasVertex) {
                glAttachShader(_id, _vertexShader);
            }

            if (hasFragment) {
                glAttachShader(_id, _fragmentShader);
            }

            glLinkProgram(_id);

            if (hasCompute) {
                _computeId = glCreateProgram();
                glAttachShader(_computeId, _computeShader);
                glLinkProgram(_computeId);
            }
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
                writeln(type, " shader error for ", path, ": ", infoLog);

                // Delete shader as we don't need it anymore
                glDeleteShader(shaderId);
            }
        }

        GLint getShaderLocation(const char* label) {
            GLint labelId = glGetUniformLocation(_id, label);

            if (labelId == GL_INVALID_VALUE || labelId == GL_INVALID_OPERATION) {
                throw new Exception("Error " ~ to!string(labelId,
                        16) ~ ": unable to get location of uniform " ~ to!string(label));
            }

            return labelId;
        }
    }
}
