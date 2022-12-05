module sorcier.script.text;

import grimoire;
import gl3n.linalg;

import magia.render;

void loadMagiaLibText(GrLibrary library) {
    GrType fontType = library.addNative("Font");
    GrType trueTypeFontType = library.addNative("TrueTypeFont", [], "Font");
    GrType bitmapFontType = library.addNative("BitmapFont", [], "Font");

    library.addFunction(&_trueTypeFont, "TrueTypeFont", [
            grString, grInt, grInt
        ], [trueTypeFontType]);

    library.addFunction(&_setFont1, "setFont", []);
    library.addFunction(&_setFont2, "setFont", [fontType]);
    library.addFunction(&_getFont, "getFont", [], [fontType]);

    library.addFunction(&_print1, "print", [grString, grFloat, grFloat]);
    library.addFunction(&_print2, "print", [
            grString, grFloat, grFloat, fontType
        ]);
}

private void _trueTypeFont(GrCall call) {
    TrueTypeFont font = new TrueTypeFont(call.getString(0), call.getInt(1), call.getInt(2));
    call.setNative(font);
}

private void _setFont1(GrCall call) {
    setDefaultFont(null);
}

private void _setFont2(GrCall call) {
    setDefaultFont(call.getNative!Font(0));
}

private void _getFont(GrCall call) {
    call.setNative(getDefaultFont());
}

private void _print1(GrCall call) {
    drawText(mat4.identity, call.getString(0), call.getFloat(1), call.getFloat(2));
}

private void _print2(GrCall call) {
    drawText(mat4.identity, call.getString(0), call.getFloat(1), call.getFloat(2), call.getNative!Font(3));
}
