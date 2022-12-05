module sorcier.script.loader;

import grimoire;

import sorcier.script.common;
import sorcier.script.window;
import sorcier.script.camera;
import sorcier.script.drawable;
import sorcier.script.texture;
import sorcier.script.primitive;
import sorcier.script.sprite;
import sorcier.script.text;
import sorcier.script.vec2;
import sorcier.script.vec3;
import sorcier.script.color;
import sorcier.script.ui;

/// Loads all sub libraries
GrLibrary loadMagiaLibrary() {
    GrLibrary library = new GrLibrary;
    loadMagiaLibCommon(library);
    loadMagiaLibWindow(library);
    loadMagiaLibCamera(library);
    loadMagiaLibDrawable(library);
    loadMagiaLibTexture(library);
    loadMagiaLibPrimitive(library);
    loadMagiaLibSprite(library);
    loadMagiaLibText(library);
    loadMagiaLibVec2(library);
    loadMagiaLibVec3(library);
    loadMagiaLibColor(library);
    loadMagiaLibUI(library);
    return library;
}
