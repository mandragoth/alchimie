module magia.render.camera;

import bindbc.sdl;
import bindbc.opengl;

import std.math;
import std.stdio;

import magia.core.mat;
import magia.core.timestep;
import magia.core.util;
import magia.core.vec;
import magia.render.shader;
import magia.render.window;

/// Global camera class
abstract class Camera {
    protected {
        /// Position
        vec3 _position = vec3.zero;

        /// Rotation around Z axis
        float _zRotation = 0f;

        /// Aspect ratio
        float _aspectRatio = 1f;

        /// Zoom level
        float _zoomLevel = 1f;

        /// Camera matrices
        mat4 _matrix = mat4.identity;
        mat4 _projection = mat4.identity;
        mat4 _view = mat4.identity;
    }

    @property {
        /// Get model matrix
        mat4 matrix() const {
            return _matrix;
        }

        /// Get position
        vec3 position() const {
            return _position;
        }

        /// Set position
        void position(vec3 position_) {
            _position = position_;
        }

        /// Get rotation along Z axis
        float zRotation() {
            return _zRotation;
        }

        /// Set rotation along Z axis
        void zRotation(float zRotation_) {
            _zRotation = zRotation_;
        }

        /// Set aspect ratio
        void aspectRatio(float aspectRatio_) {
            _aspectRatio = aspectRatio_;
        }

        /// Get zoom level
        float zoomLevel() {
            return _zoomLevel;
        }

        /// Set zoom level
        void zoomLevel(float zoomLevel_) {
            _zoomLevel = zoomLevel_;
        }
    }

    /// Update
    void update(TimeStep) {}

    /// Pass camera to object rendering shader
    void passToShader(Shader) {}

    /// Pass camera to skybox shader
    void passToSkyboxShader(Shader) {}
}

/// Orthographic camera class
class OrthographicCamera : Camera {
    @property {
        override void position(vec3 position_) {
            _position = position_;
            computeViewMatrix();
        }

        override void zRotation(float zRotation_) {
            _zRotation = zRotation_;
            computeViewMatrix();
        }

        override void aspectRatio(float aspectRatio_) {
            _aspectRatio = aspectRatio_;
            computeProjectionMatrix();
        }

        override void zoomLevel(float zoomLevel_) {
            _zoomLevel = zoomLevel_;
            computeProjectionMatrix();
        }
    }

    /// Constructor
    this() {
        _aspectRatio = getAspectRatio();
        computeProjectionMatrix();
    }

    /// Recompute projection and model matrices
    void computeProjectionMatrix() {
        computeProjectionMatrix(-_aspectRatio * _zoomLevel,
                                 _aspectRatio * _zoomLevel,
                                -_zoomLevel,
                                 _zoomLevel);
    } 

    /// Recompute projection and model matrices
    void computeProjectionMatrix(float left, float right, float bottom, float top) {
        _projection = mat4.orthographic(left, right, bottom, top, -1f, 1f);
        _matrix = _projection * _view;
    }

    /// Recompute view and model matrices
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
    override void update(TimeStep timeStep) {
        updateMatrix(45f, 0.1f, 1000f);
    }
}