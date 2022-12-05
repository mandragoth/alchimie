module sorcier.script.color;

import std.conv : to;
import std.algorithm.comparison : clamp;
import grimoire;
import magia.common;
import sorcier.script.util;

package void loadMagiaLibColor(GrLibrary library) {
    auto colorType = library.addClass("color", ["r", "g", "b"], [
            grFloat, grFloat, grFloat
        ]);

    library.addFunction(&_color, "color", [], [colorType]);
    library.addFunction(&_color_3r, "color", [grFloat, grFloat, grFloat], [
            colorType
        ]);

    library.addFunction(&_color_3i, "color", [grInt, grInt, grInt], [colorType]);

    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryColor!op, op, [colorType, colorType], colorType);
        library.addOperator(&_opBinaryScalarColor!op, op, [colorType, grFloat], colorType);
        library.addOperator(&_opBinaryScalarRightColor!op, op, [
                grFloat, colorType
            ], colorType);
    }

    library.addFunction(&_lerp, "lerp", [colorType, colorType, grFloat], [
            colorType
        ]);

    library.addCast(&_fromList, grList(grInt), colorType);
    library.addCast(&_toString, colorType, grString);

    library.addFunction(&_unpack, "unpack", [colorType], [
            grFloat, grFloat, grFloat
        ]);

    library.addFunction(&_print, "print", [colorType]);
}

private void _color(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("r", 0f);
    self.setFloat("g", 0f);
    self.setFloat("b", 0f);
    call.setObject(self);
}

private void _color_3r(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("r", call.getFloat(0));
    self.setFloat("g", call.getFloat(1));
    self.setFloat("b", call.getFloat(2));
    call.setObject(self);
}

private void _color_3i(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setFloat("r", clamp(call.getInt(0) / 255f, 0f, 1f));
    self.setFloat("g", clamp(call.getInt(1) / 255f, 0f, 1f));
    self.setFloat("b", clamp(call.getInt(2) / 255f, 0f, 1f));
    call.setObject(self);
}

private void _opBinaryColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c1 = call.getObject(0);
    GrObject c2 = call.getObject(1);
    if (!c1 || !c2) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"r\", c1.getFloat(\"r\")" ~ op ~ "c2.getFloat(\"r\"));");
    mixin("self.setFloat(\"g\", c1.getFloat(\"g\")" ~ op ~ "c2.getFloat(\"g\"));");
    mixin("self.setFloat(\"b\", c1.getFloat(\"b\")" ~ op ~ "c2.getFloat(\"b\"));");
    call.setObject(self);
}

private void _opBinaryScalarColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c = call.getObject(0);
    const GrFloat s = call.getFloat(1);
    if (!c) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"r\", c.getFloat(\"r\")" ~ op ~ "s);");
    mixin("self.setFloat(\"g\", c.getFloat(\"g\")" ~ op ~ "s);");
    mixin("self.setFloat(\"b\", c.getFloat(\"b\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c = call.getObject(0);
    const GrFloat s = call.getFloat(1);
    if (!c) {
        call.raise("NullError");
        return;
    }
    mixin("self.setFloat(\"r\", s" ~ op ~ "c.getFloat(\"r\"));");
    mixin("self.setFloat(\"g\", s" ~ op ~ "c.getFloat(\"g\"));");
    mixin("self.setFloat(\"b\", s" ~ op ~ "c.getFloat(\"b\"));");
    call.setObject(self);
}

private void _lerp(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c1 = call.getObject(0);
    GrObject c2 = call.getObject(1);
    const GrFloat t = call.getFloat(2);
    if (!c1 || !c2) {
        call.raise("NullError");
        return;
    }
    self.setFloat("r", (t * c2.getFloat("r")) + ((1f - t) * c1.getFloat("r")));
    self.setFloat("g", (t * c2.getFloat("g")) + ((1f - t) * c1.getFloat("g")));
    self.setFloat("b", (t * c2.getFloat("b")) + ((1f - t) * c1.getFloat("b")));
    call.setObject(self);
}

private void _fromList(GrCall call) {
    GrList list = call.getList(0);
    if (list.size == 3) {
        GrObject self = call.createObject("color");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setValue("r", list[0]);
        self.setValue("g", list[1]);
        self.setValue("b", list[2]);
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
    call.setString("color(" ~ to!string(self.getFloat("r")) ~ ", " ~ to!string(
            self.getFloat("g")) ~ ", " ~ to!string(self.getFloat("b")) ~ ")");
}

private void _unpack(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setFloat(self.getFloat("r"));
    call.setFloat(self.getFloat("g"));
    call.setFloat(self.getFloat("b"));
}

private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(color)");
        return;
    }
    print("color(" ~ to!string(self.getFloat("r")) ~ ", " ~ to!string(
            self.getFloat("g")) ~ ", " ~ to!string(self.getFloat("b")) ~ ")");
}
