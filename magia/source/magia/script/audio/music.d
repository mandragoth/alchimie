module magia.script.audio.music;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_music(GrModule mod) {
    mod.setModule("audio.music");
    mod.setModuleInfo(GrLocale.fr_FR, "Représente un fichier audio");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Music est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Music)).");

    GrType musicType = mod.addNative("Music");

    mod.addConstructor(&_ctor, musicType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Lance directement la lecture d’une musique.");
    mod.setParameters(["music"]);
    mod.addFunction(&_play, "play", [musicType]);

    mod.setDescription(GrLocale.fr_FR, "Joue une nouvelle piste musical.
À la différence de `play` les fonctions comme `playTrack` et `pushTrack` sont limitées à une seule musique en même temps.
Jouer une nouvelle musique remplacera celle en cours et s’occupera de faire la transition entre les deux musiques automatiquement durant `fadeOut` secondes (grace à `AudioFader`).
Si aucune piste n’est en cours, la musique se lancera directement.");
    mod.setParameters(["music", "fadeOut"]);
    mod.addFunction(&_playTrack, "playTrack", [musicType, grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Interromp la piste musicale en cours avec un fondu de `fadeOut` secondes.");
    mod.setParameters(["fadeOut"]);
    mod.addFunction(&_stopTrack, "stopTrack", [grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Met en pause la piste musicale en cours avec un fondu de `fadeOut` secondes.");
    mod.setParameters(["fadeOut"]);
    mod.addFunction(&_pauseTrack, "pauseTrack", [grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Redémarre la piste en cours là où elle s’était arrêtée avec un fondu de `fadeIn` secondes.");
    mod.setParameters(["fadeIn"]);
    mod.addFunction(&_resumeTrack, "resumeTrack", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Remplace temporairement la piste musicale en cours par une nouvelle musique avec un fondu de `fadeOut` secondes.
Pour redémarrer l’ancienne piste à l’endroit où elle a été interrompu, il suffit d’appeler la fonction `popTrack`.");
    mod.setParameters(["music", "fadeOut"]);
    mod.addFunction(&_pushTrack, "pushTrack", [musicType, grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Termine la piste musicale en cours et reprend la dernière piste musicale interrompu via `pushTrack`.");
    mod.setParameters(["fadeOut", "delay", "fadeIn"]);
    mod.addFunction(&_popTrack, "popTrack", [grFloat, grFloat, grFloat]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
}

private void _ctor(GrCall call) {
    Music music = Magia.res.get!Music(call.getString(0));
    call.setNative(music);
}

private void _play(GrCall call) {
    Music music = call.getNative!Music(0);
    Magia.audio.play(new MusicPlayer(music));
}

private void _playTrack(GrCall call) {
    Music music = call.getNative!Music(0);
    float fadeOut = call.getFloat(1);
    Magia.audio.playTrack(music, fadeOut);
}

private void _stopTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    Magia.audio.stopTrack(fadeOut);
}

private void _pauseTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    Magia.audio.pauseTrack(fadeOut);
}

private void _resumeTrack(GrCall call) {
    float fadeIn = call.getFloat(0);
    Magia.audio.resumeTrack(fadeIn);
}

private void _pushTrack(GrCall call) {
    Music music = call.getNative!Music(0);
    float fadeOut = call.getFloat(1);
    Magia.audio.pushTrack(music, fadeOut);
}

private void _popTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    float delay = call.getFloat(1);
    float fadeIn = call.getFloat(2);
    Magia.audio.popTrack(fadeOut, delay, fadeIn);
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
