module sorcier.script.loader;

import grimoire;
import sorcier.script.camscript;
import sorcier.script.common;
import sorcier.script.drawable;
import sorcier.script.input;
import sorcier.script.scriptutils;
import sorcier.script.uiscript;

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
        &loadAlchimieLibCamera, &loadAlchimieLibCommon, &loadAlchimieLibDrawable,
        &loadAlchimieLibInput, &loadAlchimieLibUI
    ];
}
