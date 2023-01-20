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
import sorcier.script.input;

/// Charge la bibliothèque d’alchimie
GrLibrary loadAlchimieLibrary() {
    GrLibrary library = new GrLibrary;

    foreach (loader; getAlchimieLibraryLoaders()) {
        loader(library);
    }

    return library;
}

/// Retourne les fonctions de chargement de la bibliothèque d’alchimie
GrLibLoader[] getAlchimieLibraryLoaders() {
    return [
        &loadAlchimieLibCommon, &loadAlchimieLibWindow, &loadAlchimieLibCamera,
        &loadAlchimieLibDrawable, &loadAlchimieLibTexture,
        &loadAlchimieLibPrimitive, &loadAlchimieLibSprite,
        &loadAlchimieLibText, &loadAlchimieLibVec2, &loadAlchimieLibVec3,
        &loadAlchimieLibColor, &loadAlchimieLibUI, &loadAlchimieLibInput,
    ];
}
