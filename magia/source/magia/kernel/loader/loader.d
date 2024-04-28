module magia.kernel.loader.loader;

import std.conv : to;
import std.exception : enforce;

import magia.core;
import magia.render;
import magia.audio;
import magia.kernel.runtime;
import magia.kernel.loader.diffuse;
import magia.kernel.loader.model;
import magia.kernel.loader.shader;
import magia.kernel.loader.skybox;
import magia.kernel.loader.sound;
import magia.kernel.loader.sprite;
import magia.kernel.loader.texture;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    res.setLoader("shader", &compileShader, &loadShader);
    res.setLoader("diffuse", &compileDiffuse, &loadDiffuse);
    res.setLoader("skybox", &compileSkybox, &loadSkybox);
    res.setLoader("sprite", &compileSprite, &loadSprite);
    res.setLoader("model", &compileModel, &loadModel);
    res.setLoader("texture", &compileTexture, &loadTexture);
    res.setLoader("sound", &compileSound, &loadSound);
}
