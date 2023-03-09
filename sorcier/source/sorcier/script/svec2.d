module sorcier.script.svec2;

import magia;
import grimoire;

import sorcier.script.common;

package void loadAlchimieLibVec2(GrLibDefinition library) {
    GrType vec2Type = library.addNative("vec2", ["T"]);

    GrType vec2FloatType = library.addAlias("vec2f", grGetNativeType("vec2", [
                grFloat
            ]));
    GrType vec2IntType = library.addAlias("vec2i", grGetNativeType("vec2", [
                grInt
            ]));
    GrType vec2UIntType = library.addAlias("vec2u", grGetNativeType("vec2", [
                grUInt
            ]));

    static foreach (type; ["Float", "Int", "UInt"]) {
        mixin(
            "library.addConstructor(&_ctor!type, vec2" ~ type ~ "Type, [gr" ~
                type ~ ", gr" ~ type ~ "]);");

        mixin("library.addProperty(
            &_property!(\"x\", \"get\", type),
            &_property!(\"x\", \"set\", type),
            \"x\", vec2" ~ type ~ "Type, gr" ~ type ~ ");");
        mixin("library.addProperty(
            &_property!(\"y\", \"get\", type),
            &_property!(\"y\", \"set\", type),
            \"y\", vec2" ~ type ~ "Type, gr" ~ type ~ ");");
    }
}

private void _ctor(string type)(GrCall call) {
    mixin("SVec2!Gr" ~ type ~ " vec2 = new SVec2!Gr" ~ type ~ ";");
    mixin("vec2.x = call.get" ~ type ~ "(0);");
    mixin("vec2.y = call.get" ~ type ~ "(1);");
    mixin("call.setNative!(SVec2!Gr" ~ type ~ ")(vec2);");
}

private void _property(string field, string op, string type)(GrCall call) {
    mixin("SVec2!Gr" ~ type ~ " vec2 = call.getNative!(SVec2!Gr" ~ type ~ ")(0);");
    static if (op == "set") {
        mixin("vec2." ~ field ~ " = call.get" ~ type ~ "(1);");
    }
    mixin("call.set" ~ type ~ "(vec2." ~ field ~ ");");
}
