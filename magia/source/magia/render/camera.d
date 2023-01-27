module magia.render.camera;

import bindbc.sdl;
import bindbc.opengl;

import std.math;
import std.stdio;

import magia.core;
import magia.render.entity;
import magia.render.shader;
import magia.render.window;

/// Global camera class
abstract class Camera : Instance {
    protected {
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

        /// Get view matrix
        mat4 view() const {
            return _view;
        }

        /// Get projection matrix
        mat4 projection() const {
            return _projection;
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
}

/// Orthographic camera class
class OrthographicCamera : Camera {
    @property {
        override void position(vec3 position_) {
            transform.position = position_;
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
        mat4 transform = mat4.translation(transform.position) * mat4.zrotation(_zRotation);
        _view = transform.inverse();
        _matrix = _projection * _view;
    }
}

/// Perspective camera class
class PerspectiveCamera : Camera {
    private {
        /// Where the camera looks (by default towards the Z axis away from the screen)
        vec3 _orientation = vec3.back;

        /// Where is up? (by default the Y axis)
        vec3 _up = vec3.up;

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
    this() {
        _width = screenWidth;
        _height = screenHeight;
    }

    /// Setting up camera matrices operations
    void updateMatrix(float FOVdeg, float nearPlane, float farPlane) {
        _view = mat4.look_at(position, position + _orientation, _up);
        _projection = mat4.perspective(_width, _height, FOVdeg, nearPlane, farPlane);
        _matrix = _projection * _view;
    }

    /// Update the camera @TODO only recomputed when needed
    override void update(TimeStep timeStep) {
        updateMatrix(45f, 0.1f, 1000f);
    }
}