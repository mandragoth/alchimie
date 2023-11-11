module magia.audio.manager;

import std.exception : enforce;

import magia.audio.device;
import magia.audio.context;
import magia.audio.sound;
import magia.audio.source;
import magia.audio.voice;

/// Gestionnaire audio
final class AudioManager {
    private {
        AudioDevice _device;
        AudioContext _context;
    }

    /// Init
    this() {
        _device = new AudioDevice();
        _context = new AudioContext(_device);
    }

    /// Màj
    void update() {
        _context.update();
    }

    /// TODO: Temporaire
    void play(Sound sound) {
        Voice voice = new Voice(sound);
        _context.play(voice);
    }
/*
    void play2D(Sound sound, vec2 position) {
        Voice2D voice = new Voice2D(sound, position);
        _context.play(voice);
    }

    void play2D(Sound sound, Instance2D target) {
        VoiceTarget2D voice = new VoiceTarget2D(sound, target);
        _context.play(voice);
    }

    void play3D(Sound sound, vec3 position) {
        Voice3D voice = new Voice3D(sound, position);
        _context.play(voice);
    }

    void play3D(Sound sound, Instance3D target) {
        VoiceTarget3D voice = new VoiceTarget3D(sound, target);
        _context.play(voice);
    }*/
}
