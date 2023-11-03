module magia.main.loader;

import std.conv : to;
import std.exception : enforce;

import magia.core;
import magia.render;
import magia.audio;
import magia.main.application;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    res.setLoader("shader", &_compileShader, &_loadShader);
    res.setLoader("diffuse", &_compileDiffuse, &_loadDiffuse);
    res.setLoader("skybox", &_compileSkybox, &_loadSkybox);
    res.setLoader("sprite", &_compileSprite, &_loadSprite);
    res.setLoader("model", &_compileModel, &_loadModel);
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

    Shader shader = new Shader(file);
    Magia.res.store(name, shader);
}

/// Crée une texture diffuse
private void _compileDiffuse(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
}

private void _loadDiffuse(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();

    Texture texture = new Texture(file, TextureType.diffuse);
    Magia.res.store(name, texture);
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

    Skybox skybox = new Skybox(filePaths);
    Magia.res.store(name, skybox);
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

    uint nbSprites = stream.read!uint();
    for (int i; i < nbSprites; ++i) {
        string name = stream.read!string();
        vec4i clip;

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

        Sprite sprite = new Sprite(texture, clip);
        Magia.res.store(name, sprite);
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

    Model model = new Model(file);
    Magia.res.store(name, model);
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

    Sound sound = new Sound(file);
    sound.volume = stream.read!float();
    Magia.res.store(name, sound);
}
