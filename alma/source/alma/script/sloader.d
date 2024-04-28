module alma.script.sloader;

import grimoire;
import alma.script.saudio;
import alma.script.sbullet;
import alma.script.scamera;
import alma.script.scolor;
import alma.script.scommon;
import alma.script.sdrawable;
import alma.script.sgraphics;
import alma.script.sinput;
import alma.script.smath;
import alma.script.common;
import alma.script.sscene;
import alma.script.sui;
import alma.script.svec;

GrLibrary loadAlchimieLibrary() {
    GrLibrary library = new GrLibrary(0);

    foreach (loader; getAlchimieLibraryLoaders()) {
        library.addModule(loader);
    }

    return library;
}

private GrModuleLoader[] getAlchimieLibraryLoaders() {
    GrModuleLoader[] loaders;

    static foreach (pack; [
            &loadAlchimieLibCommon, &loadAlchimieLibMath, &loadAlchimieLibVec,
            &loadAlchimieLibColor, &loadAlchimieLibGraphics,
            &loadAlchimieLibScene, &loadAlchimieLibBullet,
            &loadAlchimieLibDrawable, &loadAlchimieLibAudio,
            &loadAlchimieLibCamera, &loadAlchimieLibInput, &loadAlchimieLibUI
        ]) {
        loaders ~= pack();
    }

    return loaders;
}
