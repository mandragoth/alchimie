module magia.render.camera;

import bindbc.sdl;
import bindbc.opengl;

import std.math;

import magia.core;
import magia.render.instance;
import magia.render.shader;

/// Global camera class
abstract class Camera : Instance3D {
    protected {
        /// Zoom level
        float _zoomLevel = 1f;

        /// Camera matrices
        mat4 _matrix = mat4.identity;
        mat4 _projection = mat4.identity;
        mat4 _view = mat4.identity;

        /// Zone on screen for camera draw
        vec4i _viewport;
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

        /// Get zoom level
        float zoomLevel() {
            return _zoomLevel;
        }

        /// Set zoom level
        void zoomLevel(float zoomLevel_) {
            _zoomLevel = zoomLevel_;
        }

        /// Get viewport
        vec4i viewport() const {
            return _viewport;
        }

        /// Set viewport
        void viewport(vec4i viewport_) {
            _viewport = viewport_;
        }
    }
}

import std.stdio;

/// Orthographic camera class
class OrthographicCamera : Camera {
    @property {
        override void position(vec3f position_) {
            transform.position = position_;
            computeViewMatrix();
            computeMVP();
        }

        override void rotation(rot3f rotation_) {
            transform.rotation = rotation_;
            computeViewMatrix();
            computeMVP();
        }

        override void zoomLevel(float zoomLevel_) {
            _zoomLevel = zoomLevel_;
            computeProjectionMatrix();
            computeMVP();
        }
    }

    /// Default constructor
    this(uint width, uint height) {
        // Set aspect ratio and viewport
        _viewport = vec4i(0, 0, width, height);

        // Compute view and projection matrix
        computeViewMatrix();
        computeProjectionMatrix();
        computeMVP();
    }

    /// Recompute camera MVP matrix
    private void computeMVP() {
        _matrix = _projection * _view;
    }

    /// Recompute projection matrix
    private void computeProjectionMatrix() {
        float halfWidth  = cast(float)_viewport.width / 2f; 
        float halfHeight = cast(float)_viewport.height / 2f;
        computeProjectionMatrix(-halfWidth, halfWidth, -halfHeight, halfHeight);
    } 

    /// Recompute projection matrix
    private void computeProjectionMatrix(float left, float right, float bottom, float top) {
        _projection = mat4.orthographic(left, right, bottom, top, -1f, 1f);
    }

    /// Recompute view matrix
    private void computeViewMatrix() {
        _view = transform.combineModel().inverse();
    }
}

/// Perspective camera class
class PerspectiveCamera : Camera {
    private {
        /// Where the camera looks
        vec3f _target = vec3f.back;

        /// Where is up?
        vec3f _up;

        /// Field of view
        float _FOVdeg = 45f;

        /// Near plane
        float _nearPlane = 0.1f;

        /// Far plane
        float _farPlane = 1000f;
    }

    @property {
        /// Direction to the right of the camera
        vec3f right() const {
            return cross(_target, _up).normalized;
        }
        /// Direction to the left of the camera
        vec3f up() const {
            return _up;
        }

        /// Direction the camera is facing towards
        vec3f forward() const {
            return _target;
        }
        /// Ditto
        vec3f forward(vec3f forward_) {
            return _target = forward_;
        }

        override void position(vec3f position_) {
            transform.position = position_;
            computeViewMatrix();
            computeMVP();
        }

        override void rotation(rot3f rotation_) {
            transform.rotation = rotation_;
            computeViewMatrix();
            computeMVP();
        }
    }

    /// Default constructor (by default looks aways from screen along Z, and up is positive along Y axis)
    this(uint width, uint height, vec3f position = vec3f.zero, vec3f target = vec3f.back, vec3f up = vec3f.up) {
        // Setup position
        transform.position = position;

        // Main axis for VP matrix
        _target = target;
        _up = up;

        // Set aspect ratio and viewport
        _viewport = vec4i(0, 0, width, height);

        // Compute view and projection matrix
        computeViewMatrix();
        computeProjectionMatrix();
        computeMVP();
    }

    /// Recompute camera MVP matrix
    private void computeMVP() {
        _matrix = _projection * _view;
    }

    void computeProjectionMatrix() {
        _projection = mat4.perspective(_viewport.width, _viewport.height, _FOVdeg, _nearPlane, _farPlane);
    }

    void computeViewMatrix() {
        _view = mat4.look_at(globalPosition, globalPosition + _target, _up);
    }
}