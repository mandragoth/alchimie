module sorcier.script.window;

import magia, grimoire;

import sorcier.script.util;

void loadMagiaLibWindow(GrLibrary library) {
    GrType colorType = grGetClassType("color");
    library.addFunction(&_setColor1, "setColor", []);
    library.addFunction(&_setColor2, "setColor", [colorType]);
    library.addFunction(&_getColor, "getColor", [], [colorType]);
    library.addFunction(&_setAlpha1, "setAlpha", []);
    library.addFunction(&_setAlpha2, "setAlpha", [grFloat]);
    library.addFunction(&_getAlpha, "getAlpha", [], [grFloat]);
}

private void _setColor1(GrCall) {
    setBaseColor(Color.white);
}

private void _setColor2(GrCall call) {
    setBaseColor(toColor(call.getObject(0)));
}

private void _getColor(GrCall call) {
    GrObject object = call.createObject("color");
    Color color = getBaseColor();
    object.setFloat("r", color.r);
    object.setFloat("g", color.g);
    object.setFloat("b", color.b);
    call.setObject(object);
}

private void _setAlpha1(GrCall) {
    setBaseAlpha(1f);
}

private void _setAlpha2(GrCall call) {
    setBaseAlpha(call.getFloat(0));
}

private void _getAlpha(GrCall call) {
    call.setFloat(getBaseAlpha());
}
