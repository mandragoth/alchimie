module magia.render.bullet;

import magia.core.vec;
import magia.core.updatable;
import magia.render.drawable;
import magia.render.instance;
import magia.render.renderer;
import magia.render.sprite;

import std.numeric;
import std.algorithm;
import std.math;

/// Bullet physics
struct BulletPhysics {
    /// Speed in u/s
    float speed = 0f;

    /// Maximum speed (by default undefined)
    float maxSpeed = float.nan;

    /// Minimum speed (by default undefined)
    float minSpeed = float.nan;

    /// Acceleration
    float acceleration = 0f;

    private {
        /// Angle
        float _angle = 0f;

        /// Cartesian direction
        vec2 _direction = vec2.zero;
    }

    @property {
        /// Get angle
        float angle() {
            return _angle;
        }

        /// Set angle
        void angle(float angle_) {
            _angle = angle_;
            _direction = vec2.angled(angle_);
        }

        /// Get direction
        vec2 direction() {
            return _direction;
        }

        /// Set direction
        void direction(vec2 direction_) {
            _angle = direction_.angle();
            _direction = direction_;
        }
    }

    /// Angular speed
    float angularSpeed = 0f;

    /// Radius
    float radius = 0f;

    /// Update bullet physics
    void update(ref vec2 position) {
        speed = clamp(speed + acceleration, minSpeed, maxSpeed);
        position = position + speed * _direction;
        angle = angle + angularSpeed;
    }
}

/// Class representing a bullet
class Bullet : Drawable2D, Updatable {
    private {
        Sprite _sprite;
        BulletPhysics _physics;
    }

    /// Constructor
    this(Sprite sprite, vec2 position, float speed, float angle) {
        _sprite = sprite;
        _sprite.position = position;
        _physics.speed = speed;
        _physics.angle = angle;
    }

    /// Draw the bullet
    void draw(Renderer2D renderer) {
        _sprite.draw(renderer);
    }

    /// Update the bullet
    void update() {
        _physics.update(_sprite.localPosition);
    }
}