module magia.core.rot;

import magia.core.mat;
import magia.core.quat;
import magia.core.util;
import magia.core.vec;

/// Prototype for generic rotor class, today only handles 2D, 3D
struct Rotor(type, uint dimension_) {
    static assert(dimension_ == 2 || dimension_ == 3, "rotor only defined for ");

    static if(dimension_ == 2) {
        /// Rotation in 2D can be defined by a single angle
        float angle = 0f;

        /// Constructor
        this(float angle_) {
            // Keep it in [0; range
            while(angle_ < 0) {
                angle_ += pi2;
            }

            // Keep it in ;2π] range
            while(angle_ > pi2) {
                angle_ -= pi2;
            }

            angle = angle_;
        }

        /// Matrix conversion
        mat4 toMatrix() const {
            return mat4.zrotation(angle);
        }

        /// Composition of two rotations
        Rotor opBinary(string op : "*")(Rotor other) const {
            return Rotor(angle + other.angle);
        }
    } else static if(dimension_ == 3) {
        /// Quaternion
        quat rotation = quat.identity;

        /// If we manipulate euler angles, rot3 decays to euler mode
        vec3f eulerAngles() const {
            return vec3f(rotation.roll, rotation.pitch, rotation.yaw);
        }

        /// Constructor given a quaternion
        this(quat rotation_) {
            rotation = rotation_;
        }

        /// Constructor given euler angles
        this(vec3f eulerAngles) {
            rotation = quat.eulerRotation(eulerAngles);
        }

        /// Matrix conversion
        mat4 toMatrix() const {
            return rotation.to_matrix!(4, 4);
        }

        /// Composition of two rotations
        Rotor opBinary(string op : "*")(Rotor other) const {
            return Rotor(rotation * other.rotation);
        }
    }

    @property {
        /// No rotation
        static Rotor zero() {
            return Rotor();
        }
    }
}

alias rot2f = Rotor!(float, 2);
alias rot3f = Rotor!(float, 3);