module sorcier.loader.loader;

import magia;

import std.path, std.file;

void loadResources() {
    auto files = dirEntries(buildNormalizedPath("assets", "img"), "{*.png}", SpanMode.depth);

    foreach (file; files) {
        string name = baseName(file, ".png");
        storePrototype!Texture(name, new Texture(file, TextureType.sprite));
    }
}