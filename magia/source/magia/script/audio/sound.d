module magia.script.audio.sound;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_sound(GrModule mod) {
    mod.setModule("audio.sound");
    mod.setModuleInfo(GrLocale.fr_FR, "Représente un fichier audio.
Le son est entièrement décodé en mémoire.
Il est recommandé de reserver cette classe pour des fichiers peu volumineux.");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Sound est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Sound)).");

    GrType soundType = mod.addNative("Sound");

    mod.addConstructor(&_ctor, soundType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    mod.setParameters(["sound"]);
    mod.addFunction(&_play, "play", [soundType]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = Magia.res.get!Sound(call.getString(0));
    call.setNative(sound);
}

private void _play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Magia.audio.play(new SoundPlayer(sound));
}
/*
private void _volume(string op)(GrCall call) {
    Sound sound = call.getNative!Sound(0);

    static if (op == "set") {
        sound.volume = call.getFloat(1);
    }
    call.setFloat(sound.volume);
}

private void _sound(string c)(GrCall call) {
    Sound sound = new SSound;
    mixin("sound = Sound.", c, ";");
    call.setNative(sound);
}*/
