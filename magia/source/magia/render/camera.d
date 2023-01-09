module magia.render.camera;

import bindbc.sdl, bindbc.opengl;
import std.math;
import std.stdio;
import magia.common.event;
import magia.core.mat;
import magia.core.vec;
import magia.render.shader;
import magia.render.window;

/// Global camera class
abstract class Camera {
    protected {
        /// Position
        vec3 _position;

        /// Camera matrices
        mat4 _matrix = mat4.identity;
        mat4 _projection = mat4.identity;
        mat4 _view = mat4.identity;
    }

    @property {
        mat4 matrix() const {
            return _matrix;
        }

        void position(vec3 position_) {
            _position = position_;
        }

        vec3 position() {
            return _position;
        }
    }

    void update() {}
    void passToShader(Shader shader) {}
    void passToSkyboxShader(Shader shader) {}
}

/// Orthographic camera class
class OrthographicCamera : Camera {
    /// Rotation around Z axis
    protected {
        float _zRotation;
    }

    @property {
        override void position(vec3 position_) {
            _position = position_;
            computeViewMatrix();
        }

        void zRotation(float zRotation_) {
            _zRotation = zRotation_;
            computeViewMatrix();
        }
    }

    this(float left, float right, float bottom, float top) {
        _projection = mat4.orthographic(left, right, bottom, top, -1f, 1f);
        _view = mat4.identity;
        _matrix = _projection * _view;
    }

    void computeViewMatrix() {
        mat4 transform = mat4.translation(_position) * mat4.zrotation(_zRotation);
        _view = transform.inverse();
        _matrix = _projection * _view;
    }
}

/// Perspective camera class
class PerspectiveCamera : Camera {
    private {
        /// Where the camera looks (by default towards the Z axis away from the screen)
        vec3 _orientation = vec3(0.0f, 0.0f, -1.0f);

        /// Where is up? (by default the Y axis)
        vec3 _up = vec3(0.0f, 1.0f, 0.0f);

        /// Width of the camera viewport
        int _width;

        /// Height of the camera viewport
        int _height;
    }

    @property {
        /// Direction to the right of the camera
        vec3 right() const {
            return cross(_orientation, _up).normalized;
        }
        /// Direction to the left of the camera
        vec3 up() const {
            return _up;
        }

        /// Direction the camera is facing towards
        vec3 forward() const {
            return _orientation;
        }
        /// Ditto
        vec3 forward(vec3 forward_) {
            return _orientation = forward_;
        }
    }

    /// Constructor
    this(int width_, int height_, vec3 position_ = vec3(0f, 0f, 0f)) {
        _width = width_;
        _height = height_;
        _position = position_;
    }

    /// Setting up camera matrices operations
    void updateMatrix(float FOVdeg, float nearPlane, float farPlane) {
        _view = mat4.look_at(_position, _position + _orientation, _up);
        _projection = mat4.perspective(_width, _height, FOVdeg, nearPlane, farPlane);
        _matrix = _projection * _view;
    }

    /// Sets camera matrix in shader
    override void passToShader(Shader shader) {
        shader.activate();
        glUniform3f(glGetUniformLocation(shader.id, "camPos"), _position.x, _position.x, _position.z);
        glUniformMatrix4fv(glGetUniformLocation(shader.id, "camMatrix"), 1, GL_TRUE, _matrix.value_ptr);
    }

    /// Sets camera matrix in shader
    override void passToSkyboxShader(Shader shader) {
        mat4 view = mat4(mat3(_view));
        glUniformMatrix4fv(glGetUniformLocation(shader.id, "view"), 1, GL_TRUE, view.value_ptr);
        glUniformMatrix4fv(glGetUniformLocation(shader.id, "projection"), 1, GL_TRUE, _projection.value_ptr);
    }

    /// Update the camera
    override void update() {
        updateMatrix(45f, 0.1f, 1000f);
    }
}