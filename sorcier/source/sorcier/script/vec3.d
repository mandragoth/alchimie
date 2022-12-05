module sorcier.script.vec3;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.common;
import sorcier.script.util;

package void loadMagiaLibVec3(GrLibrary library) {
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [
            grFloat, grFloat, grFloat
        ]);

    // Ctors
    library.addFunction(&_vec3_zero, "vec3", [], [vec3Type]);
    library.addFunction(&_vec3_3, "vec3", [grFloat, grFloat, grFloat], [
            vec3Type
        ]);

    // Print
    library.addFunction(&_print, "print", [vec3Type]);

    // Operators
    static foreach (op; ["+", "-"]) {
        library.addOperator(&_opUnaryVec3!op, op, [vec3Type], vec3Type);
    }
    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryVec3!op, op, [vec3Type, vec3Type], vec3Type);
        library.addOperator(&_opBinaryScalarVec3!op, op, [vec3Type, grFloat], vec3Type);
        library.addOperator(&_opBinaryScalarRightVec3!op, op, [
                grFloat, vec3Type
            ], vec3Type);
    }
    static foreach (op; ["==", "!=", ">=", "<=", ">", "<"]) {
        library.addOperator(&_opBinaryCompareVec3!op, op, [vec3Type, vec3Type], grBool);
    }

    // Utility
    library.addFunction(&_vec3_zero, "vec3_zero", [], [vec3Type]);
    library.addFunction(&_vec3_half, "vec3_half", [], [vec3Type]);
    library.addFunction(&_vec3_one, "vec3_one", [], [vec3Type]);
    library.addFunction(&_vec3_up, "vec3_up", [], [vec3Type]);
    library.addFunction(&_vec3_down, "vec3_down", [], [vec3Type]);
    library.addFunction(&_vec3_left, "vec3_left", [], [vec3Type]);
    library.addFunction(&_vec3_right, "vec3_right", [], [vec3Type]);

    library.addFunction(&_unpack, "unpack", [vec3Type], [
            grFloat, grFloat, grFloat
        ]);

    library.addFunction(&_abs, "abs", [vec3Type], [vec3Type]);
    library.addFunction(&_ceil, "abs", [vec3Type], [vec3Type]);
    library.addFunction(&_floor, "floor", [vec3Type], [vec3Type]);
    library.addFunction(&_round, "round", [vec3Type], [vec3Type]);

    library.addFunction(&_isZero, "zero?", [vec3Type], [grBool]);

    // Operations
    library.addFunction(&_sum, "sum", [vec3Type], [grFloat]);
    library.addFunction(&_sign, "sign", [vec3Type], [vec3Type]);

    library.addFunction(&_lerp, "lerp", [vec3Type, vec3Type, grFloat], [
            vec3Type
        ]);
    library.addFunction(&_approach, "approach", [vec3Type, vec3Type, grFloat], [
            vec3Type
        ]);

    library.addFunction(&_distance, "distance", [vec3Type, vec3Type], [grFloat]);
    library.addFunction(&_distanceSquared, "distance2", [vec3Type, vec3Type], [
            grFloat
        ]);
    library.addFunction(&_magnitude, "magnitude", [vec3Type], [grFloat]);
    library.addFunction(&_magnitudeSquared, "magnitude2", [vec3Type], [grFloat]);
    library.addFunction(&_normalize, "normalize", [vec3Type], [vec3Type]);
    library.addFunction(&_normalized, "normalized", [vec3Type], [vec3Type]);

    library.addCast(&_fromList, grList(grFloat), vec3Type);
    library.addCast(&_toString, vec3Type, grString);
}

// Ctors ------------------------------------------
private void _vec3_zero(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", 0f);
    self.setFloat("y", 0f);
    self.setFloat("z", 0f);
    call.setObject(self);
}

private void _vec3_3(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", call.getFloat(0));
    self.setFloat("y", call.getFloat(1));
    self.setFloat("z", call.getFloat(2));
    call.setObject(self);
}

// Print ------------------------------------------
private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(vec3)");
        return;
    }
    print("vec3(" ~ to!string(self.getFloat("x")) ~ ", " ~ to!string(
            self.getFloat("y")) ~ ", " ~ to!string(self.getFloat("z")) ~ ")");
}

/// Operators ------------------------------------------
private void _opUnaryVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setFloat(\"z\", " ~ op ~ "v.getFloat(\"z\"));");
    call.setObject(self);
}

private void _opBinaryVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setFloat(\"z\", v1.getFloat(\"z\")" ~ op ~ "v2.getFloat(\"z\"));");
    call.setObject(self);
}

private void _opBinaryScalarVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setFloat(\"z\", v.getFloat(\"z\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setFloat(\"z\", s" ~ op ~ "v.getFloat(\"z\"));");
    call.setObject(self);
}

private void _opBinaryCompareVec3(string op)(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    mixin("call.setBool(
        v1.getFloat(\"x\")" ~ op ~ "v2.getFloat(\"x\") &&
        v1.getFloat(\"y\")" ~ op ~ "v2.getFloat(\"y\") &&
        v1.getFloat(\"z\")" ~ op ~ "v2.getFloat(\"z\"));");
}

// Utility ------------------------------------------
private void _vec3_one(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", 1f);
    self.setFloat("y", 1f);
    self.setFloat("z", 1f);
    call.setObject(self);
}

private void _vec3_half(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", .5f);
    self.setFloat("y", .5f);
    self.setFloat("z", .5f);
    call.setObject(self);
}

private void _vec3_up(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("y", 1f);
    call.setObject(self);
}

private void _vec3_down(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("y", -1f);
    call.setObject(self);
}

private void _vec3_left(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("x", -1f);
    call.setObject(self);
}

private void _vec3_right(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    call.setFloat(self.getFloat("z"));
}

private void _isZero(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setBool(self.getFloat("x") == 0f && self.getFloat("y") == 0f && self.getFloat("z") == 0f);
}

// Operations ------------------------------------------
private void _abs(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", abs(self.getFloat("x")));
    v.setFloat("y", abs(self.getFloat("y")));
    v.setFloat("z", abs(self.getFloat("z")));
    call.setObject(v);
}

private void _ceil(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", ceil(self.getFloat("x")));
    v.setFloat("y", ceil(self.getFloat("y")));
    v.setFloat("z", ceil(self.getFloat("z")));
    call.setObject(v);
}

private void _floor(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", floor(self.getFloat("x")));
    v.setFloat("y", floor(self.getFloat("y")));
    v.setFloat("z", floor(self.getFloat("z")));
    call.setObject(v);
}

private void _round(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", round(self.getFloat("x")));
    v.setFloat("y", round(self.getFloat("y")));
    v.setFloat("z", round(self.getFloat("z")));
    call.setObject(v);
}

private void _sum(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setFloat(self.getFloat("x") + self.getFloat("y") + self.getFloat("z"));
}

private void _sign(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", self.getFloat("x") >= 0f ? 1f : -1f);
    v.setFloat("y", self.getFloat("y") >= 0f ? 1f : -1f);
    v.setFloat("z", self.getFloat("z") >= 0f ? 1f : -1f);
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
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", v2.getFloat("x") * weight + v1.getFloat("x") * (1f - weight));
    v.setFloat("y", v2.getFloat("y") * weight + v1.getFloat("y") * (1f - weight));
    v.setFloat("z", v2.getFloat("z") * weight + v1.getFloat("z") * (1f - weight));
    call.setObject(v);
}

private void _approach(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrFloat x1 = v1.getFloat("x");
    const GrFloat y1 = v1.getFloat("y");
    const GrFloat z1 = v1.getFloat("z");
    const GrFloat x2 = v2.getFloat("x");
    const GrFloat y2 = v2.getFloat("y");
    const GrFloat z2 = v2.getFloat("z");
    const GrFloat step = call.getFloat(2);
    v.setFloat("x", x1 > x2 ? max(x1 - step, x2) : min(x1 + step, x2));
    v.setFloat("y", y1 > y2 ? max(y1 - step, y2) : min(y1 + step, y2));
    v.setFloat("z", z1 > z2 ? max(z1 - step, z2) : min(z1 + step, z2));
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
    const GrFloat pz = v1.getFloat("z") - v2.getFloat("z");
    call.setFloat(std.math.sqrt(px * px + py * py + pz * pz));
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
    const GrFloat pz = v1.getFloat("z") - v2.getFloat("z");
    call.setFloat(px * px + py * py + pz * pz);
}

private void _magnitude(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    const GrFloat z = self.getFloat("z");
    call.setFloat(std.math.sqrt(x * x + y * y + z * z));
}

private void _magnitudeSquared(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    const GrFloat z = self.getFloat("z");
    call.setFloat(x * x + y * y + z * z);
}

private void _normalize(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrFloat x = self.getFloat("x");
    const GrFloat y = self.getFloat("y");
    const GrFloat z = self.getFloat("z");
    const GrFloat len = std.math.sqrt(x * x + y * y + z * z);
    if (len == 0) {
        self.setFloat("x", len);
        self.setFloat("y", len);
        self.setFloat("z", len);
        return;
    }
    self.setFloat("x", x / len);
    self.setFloat("y", y / len);
    self.setFloat("z", y / len);
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
    GrFloat z = self.getFloat("z");
    const GrFloat len = std.math.sqrt(x * x + y * y + z * z);

    if (len == 0) {
        x = len;
        y = len;
        z = len;
        return;
    }
    x /= len;
    y /= len;
    z /= len;

    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setFloat("x", x);
    v.setFloat("y", y);
    v.setFloat("z", z);
    call.setObject(v);
}

private void _fromList(GrCall call) {
    GrList list = call.getList(0);
    if (list.size == 3) {
        GrObject self = call.createObject("vec3");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setValue("x", list[0]);
        self.setValue("y", list[1]);
        self.setValue("z", list[2]);
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
    call.setString("vec3(" ~ to!string(self.getFloat("x")) ~ ", " ~ to!string(
            self.getFloat("y")) ~ ", " ~ to!string(self.getFloat("z")) ~ ")");
}
