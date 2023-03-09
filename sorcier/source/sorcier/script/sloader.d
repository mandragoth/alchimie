module sorcier.script.sloader;

import grimoire;
import sorcier.script.scamera;
import sorcier.script.scommon;
import sorcier.script.sdrawable;
import sorcier.script.sinput;
import sorcier.script.smath;
import sorcier.script.common;
import sorcier.script.sui;
import sorcier.script.svec2;

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
        &loadAlchimieLibCommon, &loadAlchimieLibMath, &loadAlchimieLibVec2, &loadAlchimieLibDrawable, 
        &loadAlchimieLibCamera, &loadAlchimieLibInput, &loadAlchimieLibUI
    ];
}
