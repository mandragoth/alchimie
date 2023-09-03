module magia.core.rot;

import magia.core.quat;

/// Prototype for generic rotor class, today only handles 2D, 3D
struct Rotor(type, uint dimension_) {
    static assert(dimension_ == 2 || dimension_ == 3, "rotor only defined for ");

    static if(dimension_ == 2) {
        /// Rotation in 2D can be defined by a single angle
        float rotation = 0f;

        /// Constructor
        this(float rotation_) {
            rotation = rotation_;
        }
    } else static if(dimension_ == 3) {
        /// Rotation in 3D can be defined by 3 euler angles or a quat
        quat rotation = quat.identity;

        /// Constructor
        this(quat rotation_) {
            rotation = rotation_;
        }
    }

    @property {
        /// No rotation
        static Rotor zero() {
            return Rotor();
        }
    }
}

alias rot2 = Rotor!(float, 2);
alias rot3 = Rotor!(float, 3);