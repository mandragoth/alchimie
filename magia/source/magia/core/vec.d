module magia.core.vec;

import magia.core.mat;
import magia.core.quat;
import magia.core.tuple;
import std.format;
import std.math;
import std.traits;

/// Generic vector class
struct Vector(type, uint dimension_) {
    static assert(dimension > 0, "0 dimensional vectors don't exist.");

    /// Vector dimension
    static const uint dimension = dimension_;

    /// Vector data
    type[dimension] data;

    /// All dimensions set to 0 (origin)
    enum zero = Vector(0);

    /// All dimensions set to 1
    enum one = Vector(1);

    /// Expose vector type
    alias vectorType = type;

    @property {
        /// Returns pointer to data in memory
        auto value_ptr() {
            return data.ptr;
        }

        /// Format internal data as string for debug purposes
        string as_string() const {
            return format("%s", data);
        }
        alias toString = as_string;

        /// Get/Set vector data
        ref inout(type) at(uint coord)() inout {
            return data[coord];
        }

        alias x = at!0;
        alias r = x;

        static if (dimension >= 2) {
            alias y = at!1;
            alias g = y;
        }

        static if (dimension >= 3) {
            alias z = at!2;
            alias b = z;
        }

        static if (dimension >= 4) {
            alias w = at!3;
            alias a = w;
        }

        /// Returns the squared magnitude of the vector
        real magnitude_squared() const {
            real toReturn = 0;

            foreach(i; TupleRange!(0, dimension)) {
                toReturn += data[i] ^^ 2;
            }

            return toReturn;
        }

        /// Returns the magnitude of the vector
        real magnitude() const {
            return sqrt(magnitude_squared);
        }

        alias length = magnitude;

        /// Returns a normalized copy of the current vector
        Vector normalized() const {
            Vector toReturn;
            toReturn.data = this.data;
            toReturn.normalize();
            return toReturn;
        }
    }

    static void isCompatibleVectorImpl(int d)(Vector!(type, d) vec) if(d <= dimension) {}

    template isCompatibleVector(T) {
        enum isCompatibleVector = is(typeof(isCompatibleVectorImpl(T.init)));
    }

    /// Internal generic function in charge of building a vector
    private void construct(uint i, T, Tail...)(T head, Tail tail) {
        static if(i >= dimension) {
            static assert(false, "Too many arguments passed to constructor");
        } else static if(is(T : type)) {
            data[i] = head;
            construct!(i + 1)(tail);
        } else static if(isDynamicArray!T) {
            static assert((Tail.length == 0) && (i == 0), "Dynamic array can't be passed together with other arguments");
            data[] = head[];
        } else static if(isStaticArray!T) {
            data[i .. i + T.length] = head[];
            construct!(i + T.length)(tail);
        } else static if(isCompatibleVector!T) {
            data[i .. i + T.dimension] = head.data[];
            construct!(i + T.dimension)(tail);
        } else {
            static assert(false, "Vector constructor argument must be of type " ~ type.stringof ~ " or Vector, not " ~ T.stringof);
        }
    }

    /// Termination condition for construct
    private void construct(int i)() {
        static assert(i == dimension, "Not enough arguments passed to constructor");
    }

    /// Main constructor, given either a scalar, vector or mixed types
    this(Args...)(Args args) {
        construct!(0)(args);
    }

    /// Copy constructor
    this(T)(T other) if(is_vector!T && is(T.type : type) && (T.dimension >= dimension)) {
        foreach(i; TupleRange!(0, dimension)) {
            data[i] = other.data[i];
        }
    }

    /// Scalar constructor
    this()(type scalar) {
        foreach(i; TupleRange!(0, dimension)) {
            data[i] = scalar;
        }
    }
    
    /// Normalizes the vector.
    void normalize() {
        const real len = length;

        if(len != 0) {
            foreach(i; TupleRange!(0, dimension)) {
                data[i] = cast(type)(data[i] / len);
            }
        }
    }

    /// Vector minus sign
    Vector opUnary(string op : "-")() const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = -data[i];
        }

        return toReturn;
    }

    /// Vector scalar multiplication (v * s)
    Vector opBinary(string op : "*")(type scalar) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] * scalar);
        }

        return toReturn;
    }

    /// Vector scalar division
    Vector opBinary(string op : "/")(type scalar) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] / scalar);
        }

        return toReturn;
    }

    /// Vector addition
    Vector opBinary(string op : "+")(Vector other) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] + other.data[i]);
        }

        return toReturn;
    }

    /// Vector subtraction
    Vector opBinary(string op : "-")(Vector other) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] - other.data[i]);
        }

        return toReturn;
    }

    /// Vector multiplication (each members)
    Vector opBinary(string op : "*")(Vector other) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] * other.data[i]);
        }

        return toReturn;
    }

    /// Vector division (each members)
    Vector opBinary(string op : "/")(Vector other) const {
        Vector toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(type)(data[i] / other.data[i]);
        }

        return toReturn;
    }

    /// Commutative binary operations
    auto opBinaryRight(string op, T)(T inp) const if(!is_vector!T && !is_matrix!T && !is_quaternion!T) {
        return this.opBinary!(op)(inp);
    }

    /// Cast operation
    Vector!(newType, dimension) opCast(V : Vector!(newType, dimension), newType)() const {
        Vector!(newType, dimension) toReturn;

        foreach(i; TupleRange!(0, dimension)) {
            toReturn.data[i] = cast(newType)(data[i]);
        }

        return toReturn;
    }

    /// Vector of size 2
    static if(dimension == 2) {
        void set(type x_, type y_) {
            x = x_;
            y = y_;
        }
    }

    /// Vector of size 3
    static if(dimension == 3) {
        void set(type x_, type y_, type z_) {
            x = x_;
            y = y_;
            z = z_;
        }
    }

    /// Vector of size 4
    static if(dimension == 4) {
        void set(type x_, type y_, type z_, type w_) {
            x = x_;
            y = y_;
            z = z_;
            w = w_;
        }
    }
}

private void is_vector_impl(T, int d)(Vector!(T, d)) {}

/// If T is a vector, this evaluates to true, otherwise false.
template is_vector(T) {
    enum is_vector = is(typeof(is_vector_impl(T.init)));
}

/// Dot product between two vectors
T.vectorType dot(T)(const T veca, const T vecb) @safe pure nothrow if(is_vector!T) {
    T.vectorType toReturn = 0;

    foreach(i; TupleRange!(0, T.dimension)) {
        toReturn += veca.data[i] * vecb.data[i];
    }

    return toReturn;
}

/// Returns the angle between two vectors
T.vectorType angle(T)(const T veca, const T vecb) @safe pure nothrow if(is_vector!T) {
    return acos(dot(veca.normalized, vecb.normalized));
}

/// Calculates the cross product of two 3-dimensional vectors
T cross(T)(const T veca, const T vecb) @safe pure nothrow if(is_vector!T && (T.dimension == 3)) {
   return T(veca.y * vecb.z - vecb.y * veca.z,
            veca.z * vecb.x - vecb.z * veca.x,
            veca.x * vecb.y - vecb.x * veca.y);
}

/// Rotates p around axis r by angle
T rotate(T)(const T p, const T r, float angle) @safe pure nothrow if(is_vector!T && (T.dimension == 3)) {
    const float halfAngle = angle / 2;

    const float cosRot = cos(halfAngle);
    const float sinRot = sin(halfAngle);

    const quat q1 = quat(0f, p.x, p.y, p.z);
    const quat q2 = quat(cosRot, r.x * sinRot, r.y * sinRot, r.z * sinRot);
    const quat q3 = q2 * q1 * q2.conjugated;

    return vec3(q3.x, q3.y, q3.z);
}

alias vec2 = Vector!(float, 2);
alias vec3 = Vector!(float, 3);
alias vec4 = Vector!(float, 4);

alias vec2i = Vector!(int, 2);
alias vec3i = Vector!(int, 3);
alias vec4i = Vector!(int, 4);

alias vec2u = Vector!(uint, 2);
alias vec3u = Vector!(uint, 3);
alias vec4u = Vector!(uint, 4);