module magia.core.quat;

import std.conv : to;
import std.format;
import std.math;
import magia.core.mat;
import magia.core.vec;

/// Quaternion structure
struct Quaternion(type) {
    /// Holds x, w, y, z coordinates
    type[4] data;

    @property {
        /// Returns pointer to data in memory
        auto value_ptr() const {
            return data.ptr;
        }

        /// Format internal data as string for debug purposes
        string as_string() const {
            return format("%s", data);
        }
        alias toString = as_string;

        /// Get/Set quaternion data
        ref inout(type) at(uint coord)() inout {
            return data[coord];
        }

        alias w = at!0;
        alias x = at!1;
        alias y = at!2;
        alias z = at!3;

        /// Identity quaternion (w=1, x=0, y=0, z=0)
        static Quaternion identity() {
            return Quaternion(1, 0, 0, 0);
        }

        /// Returns the yaw
        real yaw() const {
            return atan2(to!real(2.0 * (w * z + x * y)), to!real(1.0 - 2.0 * (y * y + z * z)));
        }

        /// Returns the pitch
        real pitch() const {
            return asin(to!real(2.0 * (w * y - z * x)));
        }

        /// Returns the roll
        real roll() const {
            return atan2(to!real(2.0 * (w * x + y * z)), to!real(1.0 - 2.0 * (x * x + y * y)));
        }

        /// Returns an inverted copy of the current quaternion
        @property Quaternion inverse() const {
            return Quaternion(w, -x, -y, -z);
        }
        alias conjugated = inverse;
    }

    /// Constructor given 4 coordinates
    this(type w, type x, type y, type z) {
        data[0] = w;
        data[1] = x;
        data[2] = y;
        data[3] = z;
    }

    /// Instancing using euler angles
    static Quaternion euler_rotation(real roll, real pitch, real yaw) {
        Quaternion toReturn;

        const auto cr = cos(roll / 2.0);
        const auto cp = cos(pitch / 2.0);
        const auto cy = cos(yaw / 2.0);
        const auto sr = sin(roll / 2.0);
        const auto sp = sin(pitch / 2.0);
        const auto sy = sin(yaw / 2.0);

        toReturn.data[0] = cr * cp * cy + sr * sp * sy;
        toReturn.data[1] = sr * cp * cy - cr * sp * sy;
        toReturn.data[2] = cr * sp * cy + sr * cp * sy;
        toReturn.data[3] = cr * cp * sy - sr * sp * cy;

        return toReturn;
    }

    /// Instancing using euler angles
    static Quaternion euler_rotation(vec3 rotation) {
        return euler_rotation(rotation.x, rotation.y, rotation.z);
    }

    /// Return the quaternion as a matrix
    Matrix!(type, rows, cols) to_matrix(int rows, int cols)() const if((rows >= 3) && (cols >= 3)) {
        static if((rows == 3) && (cols == 3)) {
            Matrix!(type, rows, cols) toReturn;
        } else {
            Matrix!(type, rows, cols) toReturn = Matrix!(type, rows, cols).identity;
        }

        const type xx = x ^^ 2;
        const type xy = x * y;
        const type xz = x * z;
        const type xw = x * w;
        const type yy = y ^^ 2;
        const type yz = y * z;
        const type yw = y * w;
        const type zz = z ^^ 2;
        const type zw = z * w;

        toReturn.data[0][0] = 1 - 2 * (yy + zz);
        toReturn.data[0][1] = 2 * (xy - zw);
        toReturn.data[0][2] = 2 * (xz + yw);

        toReturn.data[1][0] = 2 * (xy + zw);
        toReturn.data[1][1] = 1 - 2 * (xx + zz);
        toReturn.data[1][2] = 2 * (yz - xw);

        toReturn.data[2][0] = 2 * (xz - yw);
        toReturn.data[2][1] = 2 * (yz + xw);
        toReturn.data[2][2] = 1 - 2 * (xx + yy);

        return toReturn;
    }

    /// Quaternion multiplication
    Quaternion opBinary(string op : "*")(Quaternion other) const {
        Quaternion toReturn;

        toReturn.w = -x * other.x - y * other.y - z * other.z + w * other.w;
        toReturn.x =  x * other.w + y * other.z - z * other.y + w * other.x;
        toReturn.y = -x * other.z + y * other.w + z * other.x + w * other.y;
        toReturn.z =  x * other.y - y * other.x + z * other.w + w * other.z;

        return toReturn;
    }

    /// Quaternion addition and subtraction
    Quaternion opBinary(string op)(Quaternion other) const  if((op == "+") || (op == "-")) {
        Quaternion toReturn;

        mixin("toReturn.w = w" ~ op ~ "other.w;");
        mixin("toReturn.x = x" ~ op ~ "other.x;");
        mixin("toReturn.y = y" ~ op ~ "other.y;");
        mixin("toReturn.z = z" ~ op ~ "other.z;");

        return toReturn;
    }

    /// Scalar multiplication
    Quaternion opBinary(string op : "*")(type scalar) const {
        return Quaternion(scalar * w, scalar * x, scalar * y, scalar * z);
    }

    /// Commutative binary operations
    auto opBinaryRight(string op, T)(T inp) const if(!is_quaternion!T) {
        return this.opBinary!(op)(inp);
    }

    /// Quaternion dot product
    type dot(Quaternion other) const {
        return x * other.x + y * other.y + z * other.z + w * other.w;
    }
}

/// Predefined quaternion for float type
alias quat = Quaternion!(float);

private void is_quaternion_impl(T)(Quaternion!(T)) {}

/// If T is a quaternion, this evaluates to true, otherwise false.
template is_quaternion(T) {
    enum is_quaternion = is(typeof(is_quaternion_impl(T.init)));
}