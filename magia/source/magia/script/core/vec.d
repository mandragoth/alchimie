module magia.script.core.vec;

import std.conv;
import grimoire;
import magia.core;
import magia.script.common;

package void loadLibCore_vec(GrModule mod) {
    static foreach (dimension; [2, 3, 4]) {
        _loadVec!dimension(mod);
    }
}

private void _loadVec(int dimension)(GrModule mod) {
    mixin("GrType vecType = mod.addNative(\"vec", dimension, "\", [\"T\"]);");

    mixin("GrType vecFloatType = mod.addAlias(\"vec", dimension,
        "f\", grGetNativeType(\"vec", dimension, "\", [grFloat]));");
    mixin("GrType vecIntType = mod.addAlias(\"vec", dimension,
        "i\", grGetNativeType(\"vec", dimension, "\", [grInt]));");
    mixin("GrType vecUIntType = mod.addAlias(\"vec", dimension,
        "u\", grGetNativeType(\"vec", dimension, "\", [grUInt]));");

    static if (dimension == 4) {
        static immutable fields = ["x", "y", "z", "w"];
    } else static if (dimension == 3) {
        static immutable fields = ["x", "y", "z"];
    } else static if (dimension == 2) {
        static immutable fields = ["x", "y"];
    } else {
        assert(false, "unsupported vec dimension: " ~ to!string(dimension));
    }

    static foreach (type; ["Float", "Int", "UInt"]) {
        // Constructeurs
        static if (dimension == 4) {
            mixin("mod.addConstructor(&_ctor!(dimension, type, fields), vec", type,
                "Type, [gr", type, ", gr", type, ", gr", type, ", gr", type, "]);");
        } else static if (dimension == 3) {
            mixin("mod.addConstructor(&_ctor!(dimension, type, fields), vec",
                type, "Type, [gr", type, ", gr", type, ", gr", type, "]);");
        } else static if (dimension == 2) {
            mixin("mod.addConstructor(&_ctor!(dimension, type, fields), vec",
                type, "Type, [gr", type, ", gr", type, "]);");
        }

        // Champs
        static foreach (field; fields) {
            mixin("mod.addProperty(
                &_property!(dimension, \"", field, "\", \"get\", type),
                &_property!(dimension, \"", field, "\", \"set\", type),
                \"", field, "\", vec", type, "Type, gr", type, ");");
        }

        // Opérateurs unaires
        static foreach (op; ["+", "-"]) {
            mixin("mod.addOperator(&_unaryOp!(dimension, op, type), op, [vec",
                type, "Type], vec", type, "Type);");
        }

        // Opérateurs binaires
        static foreach (op; ["+", "-", "*", "/", "%"]) {
            // Vectoriels
            mixin("mod.addOperator(&_binaryOp!(dimension, op, type), op, [vec",
                type, "Type, vec", type, "Type], vec", type, "Type);");

            // Scalaires
            mixin("mod.addOperator(&_scalarRightOp!(dimension, op, type), op, [vec",
                type, "Type, gr", type, "], vec", type, "Type);");
            mixin("mod.addOperator(&_scalarLeftOp!(dimension, op, type), op, [gr",
                type, ", vec", type, "Type], vec", type, "Type);");
        }

        // Angle
        static if (dimension == 2 || dimension == 3) {
            mixin("mod.addFunction(&_angleBetween!(dimension, type), \"angleBetween\", [vec",
                type, "Type, vec", type, "Type], [grFloat]);");
        }

        // Rotate
        static if (dimension == 2) {
            /*mixin("mod.addFunction(&_rotate2!(type), \"rotate\", [vec",
                type, "Type, "Type, grFloat], [grFloat]);");*/
        } else static if (dimension == 3) {
            mixin("mod.addFunction(&_rotate3!(type), \"rotate\", [vec",
                type, "Type, vec", type, "Type, grFloat], [vecFloatType]);");
        }

        // Conversion to string
        mixin("mod.addCast(&_toString!(dimension, type), vec", type, "Type, grString);");
    }
}

private void _ctor(int dimension, string type, string[] fields)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    static foreach (idx, field; fields) {
        mixin("vec.", field, " = call.get", type, "(", idx, ");");
    }
    call.setNative(vec);
}

private void _property(int dimension, string field, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " vec = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    static if (op == "set") {
        mixin("vec.", field, " = call.get", type, "(1);");
    }
    mixin("call.set", type, "(vec.", field, ");");
}

private void _unaryOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vectorData = ", op, " veca._vectorData;");
    call.setNative(vec);
}

private void _binaryOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("SVec", dimension, "!Gr", type, " vecb = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vectorData = veca._vectorData ", op, " vecb._vectorData;");
    call.setNative(vec);
}

private void _scalarRightOp(int dimension, string op, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");
    mixin("Gr", type, " scalar = call.get", type, "(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vectorData = veca._vectorData ", op, " scalar;");
    call.setNative(vec);
}

private void _scalarLeftOp(int dimension, string op, string type)(GrCall call) {
    mixin("Gr", type, " scalar = call.get", type, "(0);");
    mixin("SVec", dimension, "!Gr", type, " veca = call.getNative!(SVec",
        dimension, "!Gr", type, ")(1);");
    mixin("SVec", dimension, "!Gr", type, " vec = new SVec", dimension, "!Gr", type, ";");
    mixin("vec._vectorData = scalar ", op, " veca._vectorData;");
    call.setNative(vec);
}

private void _angleBetween(int dimension, string type)(GrCall call) {
    mixin("vec", dimension, "f v1 = cast(vec", dimension,
        "f) call.getNative!(SVec", dimension, "!Gr", type, ")(0);");
    mixin("vec", dimension, "f v2 = cast(vec", dimension,
        "f) call.getNative!(SVec", dimension, "!Gr", type, ")(1);");
    call.setFloat(angle(v1, v2));
}

private void _rotate3(string type)(GrCall call) {
    mixin("vec3f v1 = cast(vec3f) call.getNative!(SVec3!Gr", type, ")(0);");
    mixin("vec3f v2 = cast(vec3f) call.getNative!(SVec3!Gr", type, ")(1);");
    call.setNative(svec3(rotate(v1, v2, call.getFloat(2))));
}

private void _toString(int dimension, string type)(GrCall call) {
    mixin("SVec", dimension, "!Gr", type, " v = call.getNative!(SVec",
        dimension, "!Gr", type, ")(0);");

    string str = "{";
    for (int i = 0; i < dimension; ++i) {
        str ~= to!string(v[i]);

        if (i + 1 < dimension) {
            str ~= ", ";
        }
    }
    str ~= "}";

    call.setString(str);
}
