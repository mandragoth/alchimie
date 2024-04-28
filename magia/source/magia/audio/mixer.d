/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.mixer;

import std.stdio;
import std.conv : to;
import std.exception : enforce;
import std.string : fromStringz;
import bindbc.sdl;

import magia.core;
import magia.audio.bus;
import magia.audio.config;
import magia.audio.effect;
import magia.audio.fader;
import magia.audio.music;
import magia.audio.musicplayer;
import magia.audio.output;
import magia.audio.player;
import magia.audio.sound;
import magia.audio.soundplayer;

/// Gestionnaire audio
final class AudioMixer {
    private {
        AudioOutput _output;
        AudioBus _masterBus, _trackBus;
        MusicPlayer[] _tracks;
    }

    @property {
        AudioBus master() {
            return _masterBus;
        }
    }

    /// Init
    this() {
        _masterBus = AudioBus.getMaster();
        _trackBus = new AudioBus();
        _trackBus.connectTo(_masterBus);

        _output = new AudioOutput(_masterBus);
    }

    ~this() {
    }

    void clear() {
        _masterBus.clear();
        _trackBus.clear();
        _trackBus.connectTo(_masterBus);
    }

    string[] getDevices(bool capture) {
        string[] devices;
        int captureFlag = capture ? 1 : 0;
        const int count = SDL_GetNumAudioDevices(captureFlag);

        foreach (deviceId; 0 .. count) {
            string deviceName = to!string(fromStringz(SDL_GetAudioDeviceName(deviceId,
                    captureFlag)));
            devices ~= deviceName;
        }

        return devices;
    }

    /// Joue un son sur le bus maître
    void play(AudioPlayer player) {
        _masterBus.play(player);
    }

    void playTrack(Music music, float fadeOut) {
        if (_tracks.length) {
            MusicPlayer oldPlayer = _tracks[$ - 1];
            _tracks.length--;

            AudioFader fader = new AudioFader;
            fader.isFadeIn = false;
            fader.duration = fadeOut;
            fader.spline = Spline.linear;

            oldPlayer.addEffect(fader);
            oldPlayer.stop(fadeOut);
        }
        else {
            fadeOut = 0f;
        }
        MusicPlayer player = new MusicPlayer(music, fadeOut);
        _tracks ~= player;
        _trackBus.play(player);
    }

    void stopTrack(float fadeOut) {
        if (_tracks.length) {
            MusicPlayer oldPlayer = _tracks[$ - 1];
            _tracks.length--;

            AudioFader fader = new AudioFader;
            fader.isFadeIn = false;
            fader.duration = fadeOut;
            fader.spline = Spline.linear;

            oldPlayer.addEffect(fader);
            oldPlayer.stop(fadeOut);
        }
    }

    void pushTrack(Music music, float fadeOut) {
        pauseTrack(fadeOut);

        MusicPlayer player = new MusicPlayer(music, fadeOut);
        _tracks ~= player;
        _trackBus.play(player);
    }

    void popTrack(float fadeOut, float delay, float fadeIn) {
        stopTrack(fadeOut);

        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = true;
        fader.duration = fadeIn;
        fader.spline = Spline.linear;
        fader.delay = delay;

        player.addEffect(fader);
        player.resume(delay);
    }

    void pauseTrack(float fadeOut) {
        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = false;
        fader.duration = fadeOut;
        fader.spline = Spline.linear;

        player.addEffect(fader);
        player.pause(fadeOut);
    }

    void resumeTrack(float fadeIn) {
        if (!_tracks.length)
            return;

        MusicPlayer player = _tracks[$ - 1];

        AudioFader fader = new AudioFader;
        fader.isFadeIn = true;
        fader.duration = fadeIn;
        fader.spline = Spline.linear;

        player.addEffect(fader);
        player.resume();
    }

    void playTrackInBetween(Music music, float fadeOut = 2f) {
    }
}
