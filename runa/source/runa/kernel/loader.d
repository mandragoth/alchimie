module runa.kernel.loader;

import std.conv : to;
import std.exception : enforce;

import runa.core;
import runa.render;
import runa.audio;
import runa.kernel.application;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    res.setLoader("sprite", &_compileSprite, &_loadSprite);
    res.setLoader("sound", &_compileSound, &_loadSound);
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
    Texture texture = new Texture(file);

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

        Runa.res.store(name, { return new Sprite(texture, clip); });
    }
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

    Runa.res.store(name, {
        Sound sound = new Sound(file);
        sound.volume = volume;
        return sound;
    });
}
