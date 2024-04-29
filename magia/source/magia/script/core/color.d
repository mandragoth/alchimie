module magia.script.core.color;

import grimoire;
import magia.core;
import magia.script.common;

package void loadLibCore_color(GrModule mod) {
    mod.setModule("core.color");
    mod.setModuleInfo(GrLocale.fr_FR, "Représentation d’une couleur dans l’espace RVB");

    GrType colorType = mod.addNative("color");

    mod.addConstructor(&_ctor, colorType, [grFloat, grFloat, grFloat]);

    static foreach (field; ["r", "g", "b"]) {
        mod.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, colorType, grFloat);
    }

    static foreach (c; [
            "red", "lime", "blue", "white", "black", "yellow", "cyan", "magenta",
            "silver", "gray", "grey", "maroon", "olive", "green", "purple",
            "teal", "pink", "orange"
        ]) {
        mod.addStatic(&_color!c, colorType, c, [], [colorType]);
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

private void _color(string c)(GrCall call) {
    SColor color = new SColor;
    mixin("color = Color.", c, ";");
    call.setNative(color);
}
