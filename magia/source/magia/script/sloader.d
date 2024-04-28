module magia.script.sloader;

import grimoire;
import magia.script.saudio;
import magia.script.sbullet;
import magia.script.scamera;
import magia.script.scolor;
import magia.script.scommon;
import magia.script.sdrawable;
import magia.script.sgraphics;
import magia.script.input;
import magia.script.smath;
import magia.script.common;
import magia.script.sscene;
import magia.script.sui;
import magia.script.svec;

GrLibrary getAlchimieLibrary() {
    GrLibrary library = new GrLibrary(0);

    foreach (loader; getAlchimieLibraryLoaders()) {
        library.addModule(loader);
    }

    return library;
}

private GrModuleLoader[] getAlchimieLibraryLoaders() {
    GrModuleLoader[] loaders;

    static foreach (pack; [&getLibLoaders_temp, &getLibLoaders_input]) {
        loaders ~= pack();
    }

    return loaders;
}

//Temp
GrModuleLoader[] getLibLoaders_temp() {
    return [
        &loadAlchimieLibCommon, &loadAlchimieLibMath, &loadAlchimieLibVec,
        &loadAlchimieLibColor, &loadAlchimieLibGraphics, &loadAlchimieLibScene,
        &loadAlchimieLibBullet, &loadAlchimieLibDrawable, &loadAlchimieLibAudio,
        &loadAlchimieLibCamera, &loadAlchimieLibUI
    ];
}
