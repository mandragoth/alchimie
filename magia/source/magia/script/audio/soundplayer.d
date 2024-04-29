module magia.script.audio.soundplayer;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_soundPlayer(GrModule mod) {
    mod.setModule("audio.soundplayer");
    mod.setModuleInfo(GrLocale.fr_FR, "Instance d’un son.
Implicitement créé quand `Sound` est passé à une fonction de type `play`.
Créer manuellement cet objet permet de lui appliquer des effets avant de lancer le son.\n
**Note**: SoundPlayer ne peut être lancé qu’une seule fois, après il devient invalide.");

    GrType soundPlayerType = mod.addNative("SoundPlayer", [], "AudioPlayer");
    GrType soundType = grGetNativeType("Sound");

    mod.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    mod.setParameters(["player"]);
    mod.addConstructor(&_ctor, soundPlayerType, [soundType]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    call.setNative(new SoundPlayer(sound));
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
