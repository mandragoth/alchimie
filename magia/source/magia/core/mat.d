module magia.core.mat;

import magia.core.tuple;
import magia.core.vec;

import std.conv;
import std.format;
import std.math;
import std.traits;
import std.stdio;

/// Generic matrix type
struct Matrix(type, uint rows_, uint columns_) {
    /// Number of rows
    static const uint rows = rows_;

    /// Number of columns
    static const uint columns = columns_;

    /// Matrix data 
    type[columns][rows] data;
    alias data this;

    @property {
        /// Returns pointer to data in memory
        auto value_ptr() const {
            return data[0].ptr;
        }

        /// Format internal data as string for debug purposes
        string as_string() const {
            return format("%s", data);
        }
        alias toString = as_string;

        /// Returns a transposed copy of the matrix
        Matrix!(type, columns, rows) transposed() const {
            typeof(return) toReturn;

            foreach(r; TupleRange!(0, rows)) {
                foreach(c; TupleRange!(0, columns)) {
                    toReturn.data[c][r] = data[r][c];
                }
            }

            return toReturn;
        }
    }

    /// Internal generic function in charge of building a matrix
    private void construct(int i, T, Tail...)(T head, Tail tail) {
        static if (i >= rows * columns) {
            static assert(false, "Too many arguments passed to constructor");
        } else static if (is(T : type)) {
            data[i / columns][i % columns] = head;
            construct!(i + 1)(tail);
        } else static if(isDynamicArray!T) {
            foreach (j; 0..columns * rows) {
                data[j / columns][j % columns] = head[j];
            }
        } else {
            static assert(false, "Matrix constructor argument must be of type " ~ type.stringof ~ " or vector, not " ~ T.stringof);
        }
    }

    /// Termination for recursive matrix construct
    private void construct(int i)() {
        static assert(i == rows * columns, "Not enough arguments passed to constructor");
    }

    /// Sets all values of the matrix to value (each column in each row will contain this value)
    private void clear(type value) {
        foreach(row; TupleRange!(0, rows)) {
            foreach(column; TupleRange!(0, columns)) {
                data[row][column] = value;
            }
        }
    }

    /// Main constructor, given either a single value, matrix or vectors
    this(Args...)(Args args) {
        construct!(0)(args);
    }

    /// Copy constructor (for matrix of bigger or same dimensions)
    this(T)(T mat) if(is_matrix!T && (T.columns >= columns) && (T.rows >= rows)) {
        foreach (r; TupleRange!(0, rows)) {
            foreach (c; TupleRange!(0, columns)) {
                data[r][c] = mat.data[r][c];
            }
        }
    }

    /// Copy constructor (for matrix of smaller dimensions)
    this(T)(T mat) if(is_matrix!T && (T.columns < columns) && (T.rows < rows)) {
        make_identity();

        foreach(r; TupleRange!(0, T.rows)) {
            foreach(c; TupleRange!(0, T.columns)) {
                data[r][c] = mat.data[r][c];
            }
        }
    }

    /// Matrix multiplication with scalar
    Matrix!(type, rows, columns) opBinary(string op : "*")(type scalar) const {
        Matrix!(type, rows, columns) toReturn;

        foreach(r; TupleRange!(0, rows)) {
            foreach(c; TupleRange!(0, columns)) {
                toReturn.data[r][c] = data[r][c] * scalar;
            }
        }

        return toReturn;
    }

    /// Matrix addition
    Matrix opBinary(string op)(Matrix other) const if((op == "+") || (op == "-")) {
        Matrix toReturn;

        foreach(r; TupleRange!(0, rows)) {
            foreach(c; TupleRange!(0, columns)) {
                toReturn.data[r][c] = mixin("data[r][c]" ~ op ~ "other.data[r][c]");
            }
        }

        return toReturn;
    }

    /// Multiplication operation
    Matrix!(type, rows, T.columns) opBinary(string op : "*", T)(T other) const {
        Matrix!(type, rows, T.columns) toReturn;

        foreach(r; TupleRange!(0, rows)) {
            foreach(c; TupleRange!(0, T.columns)) {
                toReturn.data[r][c] = 0;

                foreach(c2; TupleRange!(0, columns)) {
                    toReturn.data[r][c] += data[r][c2] * other.data[c2][c];
                }
            }
        }

        return toReturn;
    }

    // Operation for square matrices
    static if(rows == columns) {
        @property {
            /// Returns identity matrix
            static Matrix identity() {
                Matrix toReturn;
                toReturn.clear(0);

                foreach (i; TupleRange!(0, rows)) {
                    toReturn.data[i][i] = 1;
                }

                return toReturn;
            }
        }

        /// Makes the current matrix an identity matrix
        void make_identity() {
            clear(0);
            foreach(r; TupleRange!(0, rows)) {
                data[r][r] = 1;
            }
        }

        /// Transposes the current matrix
        void transpose() {
            data = transposed().data;
        }

        /// Operation for square matrices of size bigger than 3
        static if (rows >= 3) {
            /// Returns an identity matrix with an applied rotation around the z-axis
            static Matrix zrotation(real alpha) {
                Matrix toReturn = Matrix.identity;

                const type cosamt = to!type(cos(alpha));
                const type sinamt = to!type(sin(alpha));

                toReturn.data[0][0] =  cosamt;
                toReturn.data[0][1] = -sinamt;
                toReturn.data[1][0] =  sinamt;
                toReturn.data[1][1] =  cosamt;

                return toReturn;
            }

            /// Floating point type
            static if(isFloatingPoint!type) {
                /// Rotates the current matrix around the z-axis by alpha
                Matrix rotatez(real alpha) {
                    this = zrotation(alpha) * this;
                    return this;
                }
            }
        }

        /// Operation for square matrices of size 3 or 4
        static if((rows >= 3) && (rows <= 4)) {
            /// Returns a translation matrix
            static Matrix translation(type x, type y, type z) {
                Matrix toReturn = Matrix.identity;

                toReturn.data[0][columns-1] = x;
                toReturn.data[1][columns-1] = y;
                toReturn.data[2][columns-1] = z;

                return toReturn;
            }

            /// Override for vec3
            static Matrix translation(vec3 v) {
                return translation(v.x, v.y, v.z);
            }

            /// Applys a translation on the current matrix and returns it
            Matrix translate(type x, type y, type z) {
                this = Matrix.translation(x, y, z) * this;
                return this;
            }

            /// Override for vec3
            Matrix translate(vec3 v) {
                this = Matrix.translation(v.x, v.y, v.z) * this;
                return this;
            }

            /// Returns a scaling matrix
            static Matrix scaling(type x, type y, type z) {
                Matrix toReturn = Matrix.identity;

                toReturn.data[0][0] = x;
                toReturn.data[1][1] = y;
                toReturn.data[2][2] = z;

                return toReturn;
            }

            /// Applys a scale to the current matrix
            Matrix scale(type x, type y, type z) {
                this = Matrix.scaling(x, y, z) * this;
                return this;
            }

            /// Override for vec3
            Matrix scale(vec3 v) {
                this = Matrix.scaling(v.x, v.y, v.z) * this;
                return this;
            }
        }

        /// 4x4 matrices
        static if(rows == 4) {
            /// Determinant
            @property type det() const {
                return (data[0][3] * data[1][2] * data[2][1] * data[3][0] - data[0][2] * data[1][3] * data[2][1] * data[3][0]
                      - data[0][3] * data[1][1] * data[2][2] * data[3][0] + data[0][1] * data[1][3] * data[2][2] * data[3][0]
                      + data[0][2] * data[1][1] * data[2][3] * data[3][0] - data[0][1] * data[1][2] * data[2][3] * data[3][0]
                      - data[0][3] * data[1][2] * data[2][0] * data[3][1] + data[0][2] * data[1][3] * data[2][0] * data[3][1]
                      + data[0][3] * data[1][0] * data[2][2] * data[3][1] - data[0][0] * data[1][3] * data[2][2] * data[3][1]
                      - data[0][2] * data[1][0] * data[2][3] * data[3][1] + data[0][0] * data[1][2] * data[2][3] * data[3][1]
                      + data[0][3] * data[1][1] * data[2][0] * data[3][2] - data[0][1] * data[1][3] * data[2][0] * data[3][2]
                      - data[0][3] * data[1][0] * data[2][1] * data[3][2] + data[0][0] * data[1][3] * data[2][1] * data[3][2]
                      + data[0][1] * data[1][0] * data[2][3] * data[3][2] - data[0][0] * data[1][1] * data[2][3] * data[3][2]
                      - data[0][2] * data[1][1] * data[2][0] * data[3][3] + data[0][1] * data[1][2] * data[2][0] * data[3][3]
                      + data[0][2] * data[1][0] * data[2][1] * data[3][3] - data[0][0] * data[1][2] * data[2][1] * data[3][3]
                      - data[0][1] * data[1][0] * data[2][2] * data[3][3] + data[0][0] * data[1][1] * data[2][2] * data[3][3]);
            }

            /// Inverse
            @property Matrix inverse() const {
                Matrix toReturn;
                invert(toReturn);
                return toReturn;
            }

            /// Invert mat4
            private Matrix invert(ref Matrix mat) const {
                const type d = 1 / det;

                mat.data = [[(data[1][1] * data[2][2] * data[3][3] + data[1][2] * data[2][3] * data[3][1] + data[1][3] * data[2][1] * data[3][2]
                            - data[1][1] * data[2][3] * data[3][2] - data[1][2] * data[2][1] * data[3][3] - data[1][3] * data[2][2] * data[3][1]) * d,
                             (data[0][1] * data[2][3] * data[3][2] + data[0][2] * data[2][1] * data[3][3] + data[0][3] * data[2][2] * data[3][1]
                            - data[0][1] * data[2][2] * data[3][3] - data[0][2] * data[2][3] * data[3][1] - data[0][3] * data[2][1] * data[3][2]) * d,
                             (data[0][1] * data[1][2] * data[3][3] + data[0][2] * data[1][3] * data[3][1] + data[0][3] * data[1][1] * data[3][2]
                            - data[0][1] * data[1][3] * data[3][2] - data[0][2] * data[1][1] * data[3][3] - data[0][3] * data[1][2] * data[3][1]) * d,
                             (data[0][1] * data[1][3] * data[2][2] + data[0][2] * data[1][1] * data[2][3] + data[0][3] * data[1][2] * data[2][1]
                            - data[0][1] * data[1][2] * data[2][3] - data[0][2] * data[1][3] * data[2][1] - data[0][3] * data[1][1] * data[2][2]) * d],
                            [(data[1][0] * data[2][3] * data[3][2] + data[1][2] * data[2][0] * data[3][3] + data[1][3] * data[2][2] * data[3][0]
                            - data[1][0] * data[2][2] * data[3][3] - data[1][2] * data[2][3] * data[3][0] - data[1][3] * data[2][0] * data[3][2]) * d,
                             (data[0][0] * data[2][2] * data[3][3] + data[0][2] * data[2][3] * data[3][0] + data[0][3] * data[2][0] * data[3][2]
                            - data[0][0] * data[2][3] * data[3][2] - data[0][2] * data[2][0] * data[3][3] - data[0][3] * data[2][2] * data[3][0]) * d,
                             (data[0][0] * data[1][3] * data[3][2] + data[0][2] * data[1][0] * data[3][3] + data[0][3] * data[1][2] * data[3][0]
                            - data[0][0] * data[1][2] * data[3][3] - data[0][2] * data[1][3] * data[3][0] - data[0][3] * data[1][0] * data[3][2]) * d,
                             (data[0][0] * data[1][2] * data[2][3] + data[0][2] * data[1][3] * data[2][0] + data[0][3] * data[1][0] * data[2][2]
                            - data[0][0] * data[1][3] * data[2][2] - data[0][2] * data[1][0] * data[2][3] - data[0][3] * data[1][2] * data[2][0]) * d],
                            [(data[1][0] * data[2][1] * data[3][3] + data[1][1] * data[2][3] * data[3][0] + data[1][3] * data[2][0] * data[3][1]
                            - data[1][0] * data[2][3] * data[3][1] - data[1][1] * data[2][0] * data[3][3] - data[1][3] * data[2][1] * data[3][0]) * d,
                             (data[0][0] * data[2][3] * data[3][1] + data[0][1] * data[2][0] * data[3][3] + data[0][3] * data[2][1] * data[3][0]
                            - data[0][0] * data[2][1] * data[3][3] - data[0][1] * data[2][3] * data[3][0] - data[0][3] * data[2][0] * data[3][1]) * d,
                             (data[0][0] * data[1][1] * data[3][3] + data[0][1] * data[1][3] * data[3][0] + data[0][3] * data[1][0] * data[3][1]
                            - data[0][0] * data[1][3] * data[3][1] - data[0][1] * data[1][0] * data[3][3] - data[0][3] * data[1][1] * data[3][0]) * d,
                             (data[0][0] * data[1][3] * data[2][1] + data[0][1] * data[1][0] * data[2][3] + data[0][3] * data[1][1] * data[2][0]
                            - data[0][0] * data[1][1] * data[2][3] - data[0][1] * data[1][3] * data[2][0] - data[0][3] * data[1][0] * data[2][1]) * d],
                            [(data[1][0] * data[2][2] * data[3][1] + data[1][1] * data[2][0] * data[3][2] + data[1][2] * data[2][1] * data[3][0]
                            - data[1][0] * data[2][1] * data[3][2] - data[1][1] * data[2][2] * data[3][0] - data[1][2] * data[2][0] * data[3][1]) * d,
                             (data[0][0] * data[2][1] * data[3][2] + data[0][1] * data[2][2] * data[3][0] + data[0][2] * data[2][0] * data[3][1]
                            - data[0][0] * data[2][2] * data[3][1] - data[0][1] * data[2][0] * data[3][2] - data[0][2] * data[2][1] * data[3][0]) * d,
                             (data[0][0] * data[1][2] * data[3][1] + data[0][1] * data[1][0] * data[3][2] + data[0][2] * data[1][1] * data[3][0]
                            - data[0][0] * data[1][1] * data[3][2] - data[0][1] * data[1][2] * data[3][0] - data[0][2] * data[1][0] * data[3][1]) * d,
                             (data[0][0] * data[1][1] * data[2][2] + data[0][1] * data[1][2] * data[2][0] + data[0][2] * data[1][0] * data[2][1]
                            - data[0][0] * data[1][2] * data[2][1] - data[0][1] * data[1][0] * data[2][2] - data[0][2] * data[1][1] * data[2][0]) * d]];
                
                return mat;
            }

            /// Print normalized mat4 (with specified precision)
            void print() {
                foreach (r; TupleRange!(0, rows)) {
                    foreach (c; TupleRange!(0, columns)) {
                        writef("%12.2f ", data[r][c]);
                    }
                    write("\n");
                }
            }

            /// Floating point type
            static if(isFloatingPoint!type) {
                alias vec3mt = Vector!(type, 3);

                static private type[6] cperspective(type width, type height, type fov, type near, type far) 
                    in { assert(height != 0); }
                    do {
                        const type aspect = width / height;
                        const type top = near * tan(fov * (PI / 360.0));
                        const type bottom = -top;
                        const type right = top * aspect;
                        const type left = -right;

                        return [left, right, bottom, top, near, far];
                    }

                /// Returns a perspective matrix
                static Matrix perspective(type width, type height, type fov, type near, type far) {
                    type[6] cdata = cperspective(width, height, fov, near, far);
                    return perspective(cdata[0], cdata[1], cdata[2], cdata[3], cdata[4], cdata[5]);
                }

                /// Returns a perspective matrix given its bounds and near/far planes
                static Matrix perspective(type left, type right, type bottom, type top, type near, type far)
                    in {
                        assert(right-left != 0);
                        assert(top-bottom != 0);
                        assert(far-near != 0);
                    }
                    do {
                        Matrix toReturn;
                        toReturn.clear(0);

                        toReturn.data[0][0] = (2 * near) / (right - left);
                        toReturn.data[0][2] = (right + left) / (right - left);
                        toReturn.data[1][1] = (2 * near) / (top - bottom);
                        toReturn.data[1][2] = (top + bottom) / (top - bottom);
                        toReturn.data[2][2] = -(far + near) / (far - near);
                        toReturn.data[2][3] = -(2 * far * near) / (far - near);
                        toReturn.data[3][2] = -1;

                        return toReturn;
                    }

                /// Returns an orthographic matrix
                static Matrix orthographic(type left, type right, type bottom, type top, type near, type far)
                in {
                    assert(right-left != 0);
                    assert(top-bottom != 0);
                    assert(far-near != 0);
                }
                do {
                    Matrix toReturn;
                    toReturn.clear(0);

                    toReturn.data[0][0] =  2 / (right - left);
                    toReturn.data[0][3] = -(right + left) / (right - left);
                    toReturn.data[1][1] =  2 / (top - bottom);
                    toReturn.data[1][3] = -(top + bottom) / (top - bottom);
                    toReturn.data[2][2] = -2 / (far - near);
                    toReturn.data[2][3] = -(far + near) / (far - near);
                    toReturn.data[3][3] = 1;

                    return toReturn;
                }

                /// Returns a look at matrix
                static Matrix look_at(vec3mt eye, vec3mt target, vec3mt up) {    
                    vec3mt look_dir = (target - eye).normalized;
                    vec3mt up_dir = up.normalized;

                    vec3mt right_dir = cross(look_dir, up_dir).normalized;
                    vec3mt perp_up_dir = cross(right_dir, look_dir);

                    Matrix toReturn = Matrix.identity;
                    toReturn.data[0][0..3] = right_dir.data[];
                    toReturn.data[1][0..3] = perp_up_dir.data[];
                    toReturn.data[2][0..3] = (-look_dir).data[];

                    toReturn.data[0][3] = -dot(eye, right_dir);
                    toReturn.data[1][3] = -dot(eye, perp_up_dir);
                    toReturn.data[2][3] = dot(eye, look_dir);

                    return toReturn;
                }
            }
        }
    }
}

/// Predefined matrix types
alias mat2 = Matrix!(float, 2, 2);
alias mat3 = Matrix!(float, 3, 3);
alias mat4 = Matrix!(float, 4, 4);

/// If T is a matrix, this evaluates to true, otherwise false
template is_matrix(T) {
    enum is_matrix = is(typeof(is_matrix_impl(T.init)));
}

/// Implementation
private void is_matrix_impl(T, int r, int c)(Matrix!(T, r, c)) {}