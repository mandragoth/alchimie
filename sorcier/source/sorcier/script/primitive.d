module sorcier.script.primitive;

import magia, grimoire;

import sorcier.script.util;

void loadMagiaLibPrimitive(GrLibrary library) {
    rectPrototype = new RectPrototype();
    circlePrototype = new CirclePrototype();

    GrType colorType = grGetClassType("Color");
    library.addFunction(&_rectangle1, "rectangle", [
            grFloat, grFloat, grFloat, grFloat
        ]);
    library.addFunction(&_rectangle2, "rectangle", [
            grFloat, grFloat, grFloat, grFloat, colorType
        ]);
    library.addFunction(&_rectangle3, "rectangle", [
            grFloat, grFloat, grFloat, grFloat, colorType, grFloat
        ]);
}

private void _rectangle1(GrCall call) {
    rectPrototype.drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
                                 Vec2f(call.getFloat(2), call.getFloat(3)));
}

private void _rectangle2(GrCall call) {
    rectPrototype.drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
                                 Vec2f(call.getFloat(2), call.getFloat(3)),
                                 toColor(call.getObject(4)));
}

private void _rectangle3(GrCall call) {
    rectPrototype.drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
                                 Vec2f(call.getFloat(2), call.getFloat(3)),
                                 toColor(call.getObject(4)),
                                 call.getFloat(5));
}
