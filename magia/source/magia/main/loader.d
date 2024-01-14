module magia.main.loader;

import std.conv : to;
import std.exception : enforce;

import magia.core;
import magia.render;
import magia.audio;
import magia.main.application;

import std.stdio;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    res.setLoader("shader", &_compileShader, &_loadShader);
    res.setLoader("diffuse", &_compileDiffuse, &_loadDiffuse);
    res.setLoader("skybox", &_compileSkybox, &_loadSkybox);
    res.setLoader("sprite", &_compileSprite, &_loadSprite);
    res.setLoader("model", &_compileModel, &_loadModel);
    res.setLoader("texture", &_compileTexture, &_loadTexture);
    res.setLoader("sound", &_compileSound, &_loadSound);
}

/// Crée une ressource shader
private void _compileShader(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
}

/// Crée une ressource shader
private void _loadShader(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();

    Magia.res.store(name, { return new Shader(file); });
}

/// Crée une texture diffuse
private void _compileDiffuse(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
}

private void _loadDiffuse(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();

    Magia.res.store(name, { return new Texture(file, TextureType.diffuse); });
}

/// Crée une boîte à ciel
private void _compileSkybox(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    string[] files = json.getStrings("files");

    enforce(files.length == 6,
        "une skybox doit avoir 6 côtés et non pas " ~ to!string(files.length));
    foreach (size_t i, string file; files) {
        stream.write!string(path ~ Archive.Separator ~ file);
    }
}

private void _loadSkybox(InStream stream) {
    string name = stream.read!string();
    string[6] filePaths;

    static foreach (i; 0 .. 6) {
        filePaths[i] = stream.read!string();
    }

    Magia.res.store(name, { return new Skybox(filePaths); });
}

/// Crée des sprites
private void _compileSprite(string path, Json json, OutStream stream) {
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));

    Json[] atlas = json.getObjects("atlas");
    stream.write!uint(cast(uint) atlas.length);
    foreach (Json spriteNode; atlas) {
        stream.write!string(spriteNode.getString("name"));
        vec4i clip = vec4i(-1, -1, -1, -1);

        if (spriteNode.has("clip")) {
            Json clipNode = spriteNode.getObject("clip");
            clip.x = clipNode.getInt("x", clip.x);
            clip.y = clipNode.getInt("y", clip.y);
            clip.z = clipNode.getInt("w", clip.z);
            clip.w = clipNode.getInt("h", clip.w);
        }

        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
}

private void _loadSprite(InStream stream) {
    string file = stream.read!string();
    Texture texture = new Texture(file, TextureType.sprite);

    SpritePool spritePool = new SpritePool(texture);

    uint nbSprites = stream.read!uint();
    for (int i; i < nbSprites; ++i) {
        string name = stream.read!string();

        Clip clip;
        clip.x = stream.read!int();
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();

        if (clip.x == -1)
            clip.x = 0;
        if (clip.y == -1)
            clip.y = 0;
        if (clip.z == -1)
            clip.z = texture.width;
        if (clip.w == -1)
            clip.w = texture.height;

        Magia.res.store(name, { return new Sprite(texture, spritePool, clip); });
    }
}

/// Crée un modèle
private void _compileModel(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
}

private void _loadModel(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();

    Magia.res.store(name, { return new Model(file); });
}

/// Crée une texture
private void _compileTexture(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
}

private void _loadTexture(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();

    Magia.res.store(name, { return new Texture(file); });
}

/// Crée un son
private void _compileSound(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
    stream.write!float(json.getFloat("volume", 1f));
}

private void _loadSound(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();

    Magia.res.store(name, {
        Sound sound = new Sound(file);
        sound.volume = volume;
        return sound;
    });
}
