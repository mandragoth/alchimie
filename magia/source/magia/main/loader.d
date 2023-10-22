module magia.main.loader;

import std.conv : to;
import std.exception : enforce;

import magia.core;
import magia.render;
import magia.audio;
import magia.main.application;

/// Initialise les ressources
void setupDefaultResourceLoaders() {
    Magia.res.setLoader("shader", &_parseShader);
    Magia.res.setLoader("diffuse", &_parseDiffuse);
    Magia.res.setLoader("skybox", &_parseSkybox);
    Magia.res.setLoader("sprite", &_parseSprite);
    Magia.res.setLoader("model", &_parseModel);
    Magia.res.setLoader("sound", &_parseSound);
}

/// Crée une ressource shader
private void _parseShader(string path, Json json) {
    string name = json.getString("name");
    string file = path ~ Archive.Separator ~ json.getString("file");

    Shader shader = new Shader(file);
    Magia.res.store(name, shader);
}

/// Crée une texture diffuse
private void _parseDiffuse(string path, Json json) {
    string name = json.getString("name");
    string file = path ~ Archive.Separator ~ json.getString("file");

    Texture texture = new Texture(file, TextureType.diffuse);
    Magia.res.store(name, texture);
}

/// Crée une boîte à ciel
private void _parseSkybox(string path, Json json) {
    string name = json.getString("name");

    string[6] filePaths;
    string[] files = json.getStrings("files");

    enforce(files.length == 6, "une skybox doit avoir 6 côtés et non " ~ to!string(files.length));
    foreach (size_t i, string file; files) {
        filePaths[i] = path ~ Archive.Separator ~ file;
    }

    Skybox skybox = new Skybox(filePaths);
    Magia.res.store(name, skybox);
}

/// Crée des sprites
private void _parseSprite(string path, Json json) {
    string file = path ~ Archive.Separator ~ json.getString("file");
    Texture texture = new Texture(file, TextureType.sprite);

    Json[] atlas = json.getObjects("atlas");
    foreach (Json spriteNode; atlas) {
        string name = spriteNode.getString("name");
        vec4i clip = vec4i(0, 0, texture.width, texture.height);

        if (spriteNode.has("clip")) {
            Json clipNode = spriteNode.getObject("clip");
            clip.x = clipNode.getInt("x", clip.x);
            clip.y = clipNode.getInt("y", clip.y);
            clip.z = clipNode.getInt("w", clip.z);
            clip.w = clipNode.getInt("h", clip.w);
        }

        Sprite sprite = new Sprite(texture, clip);
        Magia.res.store(name, sprite);
    }
}

/// Crée un modèle
private void _parseModel(string path, Json json) {
    string name = json.getString("name");
    string file = path ~ Archive.Separator ~ json.getString("file");

    Model model = new Model(file);
    Magia.res.store(name, model);
}

/// Crée un son
private void _parseSound(string path, Json json) {
    string name = json.getString("name");
    string file = path ~ Archive.Separator ~ json.getString("file");

    Sound sound = new Sound(file);
    sound.volume = json.getFloat("volume", 1f);
    Magia.res.store(name, sound);
}
