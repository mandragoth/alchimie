module alma.script.sloader;

import grimoire;
import alma.script.saudio;
import alma.script.scamera;
import alma.script.scommon;
import alma.script.sdrawable;
import alma.script.sgraphics;
import alma.script.sinput;
import alma.script.smath;
import alma.script.common;
import alma.script.sscene;
import alma.script.sui;
import alma.script.svec;
import alma.script.scolor;

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
        &loadAlchimieLibCommon, &loadAlchimieLibMath, &loadAlchimieLibVec,
        &loadAlchimieLibColor, &loadAlchimieLibGraphics, &loadAlchimieLibScene,
        &loadAlchimieLibDrawable, &loadAlchimieLibAudio, &loadAlchimieLibCamera,
        &loadAlchimieLibInput, &loadAlchimieLibUI
    ];
}
