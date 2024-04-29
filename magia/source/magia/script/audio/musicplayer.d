module magia.script.audio.musicplayer;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_musicPlayer(GrModule mod) {
    mod.setModule("audio.musicplayer");
    mod.setModuleInfo(GrLocale.fr_FR, "Instance d’une musique.
Implicitement créé quand `Music` est passé à une fonction de type `play`.
Créer manuellement cet objet permet de lui appliquer des effets avant de lancer la musique.\n
**Note**: MusicPlayer ne peut être lancé qu’une seule fois, après il devient invalide.");

    GrType musicPlayerType = mod.addNative("MusicPlayer", [], "AudioPlayer");
    GrType musicType = grGetNativeType("Music");

    mod.setParameters(["music"]);
    mod.addConstructor(&_ctor, musicPlayerType, [musicType]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
}

private void _ctor(GrCall call) {
    Music music = call.getNative!Music(0);
    call.setNative(new MusicPlayer(music));
}
/*
private void _volume(string op)(GrCall call) {
    Music music = call.getNative!Music(0);

    static if (op == "set") {
        music.volume = call.getFloat(1);
    }
    call.setFloat(music.volume);
}

private void _music(string c)(GrCall call) {
    Music music = new SMusic;
    mixin("music = Music.", c, ";");
    call.setNative(music);
}*/
