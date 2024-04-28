module alma.script.scolor;

import magia;
import grimoire;

import alma.script.common;

package void loadAlchimieLibColor(GrModule library) {
    GrType colorType = library.addNative("color");

    library.addConstructor(&_ctor, colorType, [grFloat, grFloat, grFloat]);

    static foreach (field; ["r", "g", "b"]) {
        library.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, colorType, grFloat);
    }
}

private void _ctor(GrCall call) {
    SColor color = new SColor;
    static foreach (int idx, field; ["r", "g", "b"]) {
        mixin("color.", field, " = call.getFloat(", idx, ");");
    }
    call.setNative(color);
}

private void _property(string field, string op)(GrCall call) {
    SColor color = call.getNative!(SColor)(0);
    static if (op == "set") {
        mixin("color.", field, " = call.getFloat(1);");
    }
    mixin("call.setFloat(color.", field, ");");
}
