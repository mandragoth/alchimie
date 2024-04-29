module magia.script.audio;

import grimoire;
import magia.script.audio.bus;
import magia.script.audio.effect;
import magia.script.audio.fader;
import magia.script.audio.gain;
import magia.script.audio.music;
import magia.script.audio.musicplayer;
import magia.script.audio.panner;
import magia.script.audio.player;
import magia.script.audio.sound;
import magia.script.audio.soundplayer;

package(magia.script) GrModuleLoader[] getLibLoaders_audio() {
    return [
        &loadLibAudio_bus,
        &loadLibAudio_effect,
        &loadLibAudio_fader,
        &loadLibAudio_gain,
        &loadLibAudio_panner,
        &loadLibAudio_player,
        &loadLibAudio_music,
        &loadLibAudio_musicPlayer,
        &loadLibAudio_sound,
        &loadLibAudio_soundPlayer
    ];
}
