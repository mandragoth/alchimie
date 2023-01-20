module sorcier.loader;

import magia;

void loadResources() {
    import std.path, std.file;

    auto files = dirEntries(buildNormalizedPath("assets", "texture"), "{*.png}", SpanMode.depth);
    foreach (file; files) {
        string name = baseName(file, ".png");
        storePrototype!Texture(name, new Texture(file, "sprite"));
    }
}