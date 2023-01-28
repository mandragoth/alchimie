module sorcier.loader.loader;

import magia;

import std.file;
import std.path;
import std.stdio;

private {
    bool s_Trace = false;
}

void loadResources() {
    loadImages();
    loadShaders();
    loadModels();
    loadShapes();
}

// Load images (sprite textures)
private void loadImages() {
    auto files = dirEntries(buildNormalizedPath("assets", "img"), "{*.png}", SpanMode.depth);

    foreach (file; files) {
        string name = baseName(file, ".png");

        if (s_Trace) {
            writeln("Loading texture: ", name);
        }

        storePrototype!Texture(name, new Texture(file, TextureType.sprite));
    }
}

// Load shaders
private void loadShaders() {
    auto files = dirEntries(buildNormalizedPath("assets", "shader"), "{*.glsl}", SpanMode.depth);

    foreach (file; files) {
        string name = baseName(file, ".glsl");

        if (s_Trace) {
            writeln("Loading shader: ", name);
        }

        storePrototype!Shader(name, new Shader(file));
    }
}

// Load models
private void loadModels() {
    auto files = dirEntries(buildNormalizedPath("assets", "model"), "{*.gltf}", SpanMode.depth);

    foreach (file; files) {
        string name = baseName(buildNormalizedPath(file, ".."));

        if (s_Trace) {
            writeln("Loading model: ", name);
        }

        storePrototype!Model(name, new Model(file));
    }
}