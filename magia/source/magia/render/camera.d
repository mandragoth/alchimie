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

        /// Get rotation along Z axis
        float zRotation() {
            return transform.rotation.eulerAngles.z;
        }

        /// Set rotation along Z axis
        void zRotation(float zRotation_) {
            vec3 oldAngles = transform.rotation.eulerAngles;
            vec3 newAngles = vec3(oldAngles.x, oldAngles.y, oldAngles.z);

            transform.rotation = rot3(newAngles);
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

/// Orthographic camera class
class OrthographicCamera : Camera {
    @property {
        override void position(vec3 position_) {
            transform.position = position_;
            computeViewMatrix();
        }

        override void zRotation(float zRotation_) {
            zRotation(zRotation_);
            computeViewMatrix();
        }

        override float zRotation() {
            return zRotation();
        }

        override void zoomLevel(float zoomLevel_) {
            _zoomLevel = zoomLevel_;
            computeProjectionMatrix();
        }
    }

    /// Default constructor
    this(uint width, uint height) {
        // Set aspect ratio and viewport
        _viewport = vec4i(0, 0, width, height);

        computeProjectionMatrix();
    }

    /// Recompute projection and model matrices
    void computeProjectionMatrix() {
        float halfWidth  = cast(float)_viewport.width / 2f; 
        float halfHeight = cast(float)_viewport.height / 2f;
        
        computeProjectionMatrix(-halfWidth, halfWidth, -halfHeight, halfHeight);
    } 

    /// Recompute projection and model matrices
    void computeProjectionMatrix(float left, float right, float bottom, float top) {
        _projection = mat4.orthographic(left, right, bottom, top, -1f, 1f);
        _matrix = _projection * _view;
    }

    /// Recompute view and model matrices
    void computeViewMatrix() {
        mat4 transform = mat4.translation(transform.position) * mat4.zrotation(zRotation);
        _view = transform.inverse();
        _matrix = _projection * _view;
    }
}

/// Perspective camera class
class PerspectiveCamera : Camera {
    private {
        /// Where the camera looks
        vec3 _target = vec3.back;

        /// Where is up?
        vec3 _up;
    }

    @property {
        /// Direction to the right of the camera
        vec3 right() const {
            return cross(_target, _up).normalized;
        }
        /// Direction to the left of the camera
        vec3 up() const {
            return _up;
        }

        /// Direction the camera is facing towards
        vec3 forward() const {
            return _target;
        }
        /// Ditto
        vec3 forward(vec3 forward_) {
            return _target = forward_;
        }
    }

    /// Default constructor (by default looks aways from screen along Z, and up is positive along Y axis)
    this(uint width, uint height, vec3 position = vec3.zero, vec3 target = vec3.back, vec3 up = vec3.up) {
        // Setup position
        transform.position = position;

        // Main axis for VP matrix
        _target = target;
        _up = up;

        // Set aspect ratio and viewport
        _viewport = vec4i(0, 0, width, height);
    }

    /// Setting up camera matrices operations
    void updateMatrix(float FOVdeg, float nearPlane, float farPlane) {
        _view = mat4.look_at(globalPosition, globalPosition + _target, _up);
        _projection = mat4.perspective(_viewport.width, _viewport.height, FOVdeg, nearPlane, farPlane);
        _matrix = _projection * _view;
    }

    /// Update the camera @TODO only recomputed when needed
    override void update() {
        updateMatrix(45f, 0.1f, 1000f);
    }
}