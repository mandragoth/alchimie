/**
    Vec4

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.core.vec4;

import bindbc.sdl;

import magia.core.vec2;

struct Vec4(T) {
    static assert(__traits(isArithmetic, T));

    static if (__traits(isUnsigned, T)) {
        /// {1, 1, 1, 1} vector. Its length is not one !
        enum one = Vec4!T(1u, 1u, 1u, 1u);
        /// Null vector.
        enum zero = Vec4!T(0u, 0u, 0u, 0u);
    }
    else {
        static if (__traits(isFloating, T)) {
            /// {1, 1, 1, 1} vector. Its length is not one !
            enum one = Vec4!T(1f, 1f, 1f, 1f);
            /// {0.5, 0.5, 0.5, 0.5} vector. Its length is not 0.5 !
            enum half = Vec4!T(.5f, .5f, .5f, .5f);
            /// Null vector.
            enum zero = Vec4!T(0f, 0f, 0f, 0f);
        }
        else {
            /// {1, 1, 1, 1} vector. Its length is not one !
            enum one = Vec4!T(1, 1, 1, 1);
            /// Null vector.
            enum zero = Vec4!T(0, 0, 0, 0);
        }
    }

    T x, y, z, w;

    @property {
        Vec2!T xy() const {
            return Vec2!T(x, y);
        }

        Vec2!T xy(Vec2!T v) {
            x = v.x;
            y = v.y;
            return v;
        }

        Vec2!T zw() const {
            return Vec2!T(z, w);
        }

        Vec2!T zw(Vec2!T v) {
            z = v.x;
            w = v.y;
            return v;
        }
    }

    this(T nx, T ny, T nz, T nw) {
        x = nx;
        y = ny;
        z = nz;
        w = nw;
    }

    this(Vec2!T nxy, Vec2!T nzw) {
        x = nxy.x;
        y = nxy.y;
        z = nzw.x;
        w = nzw.y;
    }

    void set(T nx, T ny, T nz, T nw) {
        x = nx;
        y = ny;
        z = nz;
        w = nw;
    }

    void set(Vec2!T nxy, Vec2!T nzw) {
        x = nxy.x;
        y = nxy.y;
        z = nzw.x;
        w = nzw.y;
    }

    bool opEquals(const Vec4!T v) const {
        return (x == v.x) && (y == v.y) && (z == v.z) && (w == v.w);
    }

    Vec4!T opUnary(string op)() const {
        return mixin("Vec4!T(" ~ op ~ " x, " ~ op ~ " y, " ~ op ~ " z, " ~ op ~ " w)");
    }

    Vec4!T opBinary(string op)(const Vec4!T v) const {
        return mixin("Vec4!T(x " ~ op ~ " v.x, y " ~ op ~ " v.y, z " ~ op ~ " v.z, w " ~ op
                ~ " v.w)");
    }

    Vec4!T opBinary(string op)(T s) const {
        return mixin("Vec4!T(x " ~ op ~ " s, y " ~ op ~ " s, z " ~ op ~ " s, w " ~ op ~ " s)");
    }

    Vec4!T opBinaryRight(string op)(T s) const {
        return mixin("Vec4!T(s " ~ op ~ " x, s " ~ op ~ " y, s " ~ op ~ " z, s " ~ op ~ "w)");
    }

    Vec4!T opOpAssign(string op)(Vec4!T v) {
        mixin("x = x" ~ op ~ "v.x;y = y" ~ op ~ "v.y;z = z" ~ op ~ "v.z;w = w" ~ op ~ "v.w;");
        return this;
    }

    Vec4!T opOpAssign(string op)(T s) {
        mixin("x = x" ~ op ~ "s;y = y" ~ op ~ "s;z = z" ~ op ~ "s;w = w" ~ op ~ "s;");
        return this;
    }

    Vec4!U opCast(V : Vec4!U, U)() const {
        return V(cast(U) x, cast(U) y, cast(U) z, cast(U) w);
    }

    static if (__traits(isIntegral, T)) {
        SDL_Rect toSdlRect() const {
            SDL_Rect sdlRect = {x, y, z, w};
            return sdlRect;
        }
    }
}

alias Vec4f = Vec4!(float);
alias Vec4i = Vec4!(int);
alias Vec4u = Vec4!(uint);
