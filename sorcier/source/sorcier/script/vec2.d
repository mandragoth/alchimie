module sorcier.script.vec2;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.common;
import sorcier.script.util;

package void loadMagiaLibVec2(GrLibrary library) {
    GrType vec2Type = library.addClass("vec2", ["x", "y"], [grFloat, grFloat]);

    // Ctors
    library.addFunction(&_vec2_zero, "vec2", [], [vec2Type]);
    library.addFunction(&_vec2_1, "vec2", [grFloat], [vec2Type]);
    library.addFunction(&_vec2_2, "vec2", [grFloat, grFloat], [vec2Type]);

    // Print
    library.addFunction(&_print, "print", [vec2Type]);

    // Operators
    static foreach (op; ["+", "-"]) {
        library.addOperator(&_opUnaryVec2!op, op, [vec2Type], vec2Type);
    }
    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryVec2!op, op, [vec2Type, vec2Type], vec2Type);
        library.addOperator(&_opBinaryScalarVec2!op, op, [vec2Type, grFloat], vec2Type);
        library.addOperator(&_opBinaryScalarRightVec2!op, op, [
                grFloat, vec2Type
            ], vec2Type);
    }
    static foreach (op; ["==", "!=", ">=", "<=", ">", "<"]) {
        library.addOperator(&_opBinaryCompareVec2!op, op, [vec2Type, vec2Type], grBool);
    }

    // Utility
    library.addFunction(&_vec2_zero, "vec2_zero", [], [vec2Type]);
    library.addFunction(&_vec2_half, "vec2_half", [], [vec2Type]);
    library.addFunction(&_vec2_one, "vec2_one", [], [vec2Type]);
    library.addFunction(&_vec2_up, "vec2_up", [], [vec2Type]);
    library.addFunction(&_vec2_down, "vec2_down", [], [vec2Type]);
    library.addFunction(&_vec2_left, "vec2_left", [], [vec2Type]);
    library.addFunction(&_vec2_right, "vec2_right", [], [vec2Type]);

    library.addFunction(&_unpack, "unpack", [vec2Type], [grFloat, grFloat]);

    library.addFunction(&_abs, "abs", [vec2Type], [vec2Type]);
    library.addFunction(&_ceil, "abs", [vec2Type], [vec2Type]);
    library.addFunction(&_floor, "floor", [vec2Type], [vec2Type]);
    library.addFunction(&_round, "round", [vec2Type], [vec2Type]);

    library.addFunction(&_isZero, "zero?", [vec2Type], [grBool]);

    // Operations
    library.addFunction(&_sum, "sum", [vec2Type], [grFloat]);
    library.addFunction(&_sign, "sign", [vec2Type], [vec2Type]);

    library.addFunction(&_lerp, "lerp", [vec2Type, vec2Type, grFloat], [
            vec2Type
        ]);
    library.addFunction(&_approach, "approach", [vec2Type, vec2Type, grFloat], [
            vec2Type
        ]);

    library.addFunction(&_reflect, "reflect", [vec2Type, vec2Type], [vec2Type]);
    library.addFunction(&_refract, "refract", [vec2Type, vec2Type, grFloat], [
            vec2Type
        ]);

    library.addFunction(&_distance, "distance", [vec2Type, vec2Type], [grFloat]);
    library.addFunction(&_distanceSquared, "distance2", [vec2Type, vec2Type], [
            grFloat
        ]);
    library.addFunction(&_dot, "dot", [vec2Type, vec2Type], [grFloat]);
    library.addFunction(&_cross, "cross", [vec2Type, vec2Type], [grFloat]);
    library.addFunction(&_normal, "normal", [vec2Type], [vec2Type]);
    library.addFunction(&_angle, "angle", [vec2Type], [grFloat]);
    library.addFunction(&_rotate, "rotate", [vec2Type, grFloat], [vec2Type]);
    library.addFunction(&_rotated, "rotated", [vec2Type, grFloat], [vec2Type]);
    library.addFunction(&_angled, "vec2_angled", [grFloat], [vec2Type]);
    library.addFunction(&_magnitude, "magnitude", [vec2Type], [grFloat]);
    library.addFunction(&_magnitudeSquared, "magnitude2", [vec2Type], [grFloat]);
    library.addFunction(&_normalize, "normalize", [vec2Type], [vec2Type]);
    library.addFunction(&_normalized, "normalized", [vec2Type], [vec2Type]);

    library.addCast(&_fromList, grList(grFloat), vec2Type);
    library.addCast(&_toString, vec2Type, grString);
}

// Ctors ------------------------------------------
private void _vec2_zero(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", 0f);
    self.setFloat("y", 0f);
    call.setObject(self);
}

private void _vec2_1(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    const GrFloat value = call.getFloat(0);
    self.setFloat("x", value);
    self.setFloat("y", value);
    call.setObject(self);
}

private void _vec2_2(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", call.getFloat(0));
    self.setFloat("y", call.getFloat(1));
    call.setObject(self);
}

// Print ------------------------------------------
private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(vec2)");
        return;
    }
    print("vec2(" ~ to!string(self.getFloat("x")) ~ ", " ~ to!string(self.getFloat("y")) ~ ")");
}

/// Operators ------------------------------------------
private void _opUnaryVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"x\", " ~ op ~ "v.getFloat(\"x\"));");
    mixin("self.setFloat(\"y\", " ~ op ~ "v.getFloat(\"y\"));");
    call.setObject(self);
}

private void _opBinaryVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"x\", v1.getFloat(\"x\")" ~ op ~ "v2.getFloat(\"x\"));");
    mixin("self.setFloat(\"y\", v1.getFloat(\"y\")" ~ op ~ "v2.getFloat(\"y\"));");
    call.setObject(self);
}

private void _opBinaryScalarVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    const GrFloat s = call.getFloat(1);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"x\", v.getFloat(\"x\")" ~ op ~ "s);");
    mixin("self.setFloat(\"y\", v.getFloat(\"y\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    const GrFloat s = call.getFloat(1);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"x\", s" ~ op ~ "v.getFloat(\"x\"));");
    mixin("self.setFloat(\"y\", s" ~ op ~ "v.getFloat(\"y\"));");
    call.setObject(self);
}

private void _opBinaryCompareVec2(string op)(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    mixin("call.setBool(
        v1.getFloat(\"x\")" ~ op ~ "v2.getFloat(\"x\") &&
        v1.getFloat(\"y\")" ~ op ~ "v2.getFloat(\"y\"));");
}

// Utility ------------------------------------------
private void _vec2_one(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", 1f);
    self.setFloat("y", 1f);
    call.setObject(self);
}

private void _vec2_half(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", .5f);
    self.setFloat("y", .5f);
    call.setObject(self);
}

private void _vec2_up(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("y", 1f);
    call.setObject(self);
}

private void _vec2_down(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("y", -1f);
    call.setObject(self);
}

private void _vec2_left(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", -1f);
    call.setObject(self);
}

private void _vec2_right(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", 1f);
    call.setObject(self);
}

private void _unpack(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setFloat(self.getFloat("x"));
    call.setFloat(self.getFloat("y"));
}

private void _isZero(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setBool(self.getFloat("x") == 0f && self.getFloat("y") == 0f);
}

// Operations ------------------------------------------
private void _abs(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", abs(self.getFloat("x")));
    v.setFloat("y", abs(self.getFloat("y")));
    call.setObject(v);
}

private void _ceil(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", ceil(self.getFloat("x")));
    v.setFloat("y", ceil(self.getFloat("y")));
    call.setObject(v);
}

private void _floor(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", floor(self.getFloat("x")));
    v.setFloat("y", floor(self.getFloat("y")));
    call.setObject(v);
}

private void _round(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", round(self.getFloat("x")));
    v.setFloat("y", round(self.getFloat("y")));
    call.setObject(v);
}

private void _sum(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setFloat(self.getFloat("x") + self.getFloat("y"));
}

private void _sign(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", self.getFloat("x") >= 0f ? 1f : -1f);
    v.setFloat("y", self.getFloat("y") >= 0f ? 1f : -1f);
    call.setObject(v);
}

private void _lerp(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrFloat weight = call.getFloat(2);
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", v2.getFloat("x") * weight + v1.getFloat("x") * (1f - weight));
    v.setFloat("y", v2.getFloat("y") * weight + v1.getFloat("y") * (1f - weight));
    call.setObject(v);
}

private void _approach(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrFloat x1 = v1.getFloat("x");
    const GrFloat y1 = v1.getFloat("y");
    const GrFloat x2 = v2.getFloat("x");
    const GrFloat y2 = v2.getFloat("y");
    const GrFloat step = call.getFloat(2);
    v.setFloat("x", x1 > x2 ? max(x1 - step, x2) : min(x1 + step, x2));
    v.setFloat("y", y1 > y2 ? max(y1 - step, y2) : min(y1 + step, y2));
    call.setObject(v);
}

private void _reflect(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrFloat x1 = v1.getFloat("x");
    const GrFloat y1 = v1.getFloat("y");
    const GrFloat x2 = v2.getFloat("x");
    const GrFloat y2 = v2.getFloat("y");
    const GrFloat dotNI2 = 2.0 * x1 * x2 + y1 * y2;
    v.setFloat("x", x1 - dotNI2 * x2);
    v.setFloat("y", y1 - dotNI2 * y2);
    call.setObject(v);
}

private void _refract(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrFloat x1 = v1.getFloat("x");
    const GrFloat y1 = v1.getFloat("y");
    const GrFloat x2 = v2.getFloat("x");
    const GrFloat y2 = v2.getFloat("y");
    const GrFloat eta = call.getFloat(2);

    const GrFloat dotNI = (x1 * x2 + y1 * y2);
    GrFloat k = 1.0 - eta * eta * (1.0 - dotNI * dotNI);
    if (k < .0) {
        v.setFloat("x", 0f);
        v.setFloat("y", 0f);
    }
    else {
        const GrFloat s = (eta * dotNI + sqrt(k));
        v.setFloat("x", eta * x1 - s * x2);
        v.setFloat("y", eta * y1 - s * y2);
    }
    call.setObject(v);
}

private void _distance(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrFloat px = v1.getFloat("x") - v2.getFloat("x");
    const GrFloat py = v1.getFloat("y") - v2.getFloat("y");
    call.setFloat(std.math.sqrt(px * px + py * py));
}

private void _distanceSquared(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrFloat px = v1.getFloat("x") - v2.getFloat("x");
    const GrFloat py = v1.getFloat("y") - v2.getFloat("y");
    call.setFloat(px * px + py * py);
}

private void _dot(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    call.setFloat(v1.getFloat("x") * v2.getFloat("x") + v1.getFloat("y") * v2.getFloat("y"));
}

private void _cross(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    call.setFloat(v1.getFloat("x") * v2.getFloat("y") - v1.getFloat("y") * v2.getFloat("x"));
}

private void _normal(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", -self.getFloat("y"));
    v.setFloat("y", self.getFloat("x"));
    call.setObject(v);
}

private void _angle(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setFloat(std.math.atan2(self.getFloat("y"), self.getFloat("x")));
}

private void _rotate(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat radians = call.getFloat(1);
    const GrFloat px = self.getFloat("x"), py = self.getFloat("y");
    const GrFloat c = std.math.cos(radians);
    const GrFloat s = std.math.sin(radians);
    self.setFloat("x", px * c - py * s);
    self.setFloat("y", px * s + py * c);
    call.setObject(self);
}

private void _rotated(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat radians = call.getFloat(1);
    const GrFloat px = self.getFloat("x"), py = self.getFloat("y");
    const GrFloat c = std.math.cos(radians);
    const GrFloat s = std.math.sin(radians);

    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", px * c - py * s);
    v.setFloat("y", px * s + py * c);
    call.setObject(v);
}

private void _angled(GrCall call) {
    const GrFloat radians = call.getFloat(0);
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", std.math.cos(radians));
    v.setFloat("y", std.math.sin(radians));
    call.setObject(v);
}

private void _magnitude(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    call.setFloat(std.math.sqrt(x * x + y * y));
}

private void _magnitudeSquared(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    call.setFloat(x * x + y * y);
}

private void _normalize(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    const GrFloat len = std.math.sqrt(x * x + y * y);
    if (len == 0) {
        self.setFloat("x", len);
        self.setFloat("y", len);
        return;
    }
    self.setFloat("x", x / len);
    self.setFloat("y", y / len);
    call.setObject(self);
}

private void _normalized(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrFloat x = self.getFloat("x");
    GrFloat y = self.getFloat("y");
    const GrFloat len = std.math.sqrt(x * x + y * y);

    if (len == 0) {
        x = len;
        y = len;
        return;
    }
    x /= len;
    y /= len;

    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", x);
    v.setFloat("y", y);
    call.setObject(v);
}

private void _fromList(GrCall call) {
    GrList list = call.getList(0);
    if (list.size == 2) {
        GrObject self = call.createObject("vec2");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setValue("x", list[0]);
        self.setValue("y", list[1]);
        call.setObject(self);
        return;
    }
    call.raise("ConvError");
}

private void _toString(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setString("vec2(" ~ to!string(self.getFloat("x")) ~ ", " ~ to!string(
            self.getFloat("y")) ~ ")");
}
