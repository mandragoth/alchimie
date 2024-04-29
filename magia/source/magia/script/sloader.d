module magia.script.sloader;

import grimoire;
import magia.script.audio;
import magia.script.common;
import magia.script.core;
import magia.script.input;
import magia.script.kernel;
import magia.script.render;
import magia.script.ui;
import magia.script.sscene;

GrLibrary getAlchimieLibrary() {
    GrLibrary library = new GrLibrary(0);

    foreach (loader; getAlchimieLibraryLoaders()) {
        library.addModule(loader);
    }

    return library;
}

private GrModuleLoader[] getAlchimieLibraryLoaders() {
    GrModuleLoader[] loaders;

    static foreach (pack; [
            &getLibLoaders_temp,
            &getLibLoaders_audio,
            &getLibLoaders_core,
            &getLibLoaders_input,
            &getLibLoaders_kernel,
            &getLibLoaders_render,
            &getLibLoaders_ui,
        ]) {
        loaders ~= pack();
    }

    return loaders;
}

//Temp
GrModuleLoader[] getLibLoaders_temp() {
    return [
        &loadAlchimieLibScene,
    ];
}
