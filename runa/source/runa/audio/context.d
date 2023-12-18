module runa.audio.context;

import std.exception : enforce;

import bindbc.openal;

import runa.core;
import runa.render;

import runa.audio.device;
import runa.audio.sound;
import runa.audio.voice;

/// Contexte audio
final class AudioContext {
    private {
        ALCcontext* _context;
        Array!(VoiceBase) _voices;

        vec3 _position = vec3.zero, _lastPosition;
        vec3 _forward = vec3(0f, 0f, 1.0f);
        vec3 _up = vec3(0f, 0f, 0f);
    }

    @property {
        /// Get position
        vec3 position() const {
            return _position;
        }
    }

    /// Init
    this(AudioDevice device) {
        _voices = new Array!(VoiceBase);
        _lastPosition = _position;

        _context = alcCreateContext(device.handle, null);
        _assertAlc();
        enforce(_context, "[Audio] impossible de créer le contexte");
    }

    /// Update
    void update() {
        enforce(alcMakeContextCurrent(_context) == ALC_TRUE,
            "[Audio] impossible de mettre à jour le contexte");
        _assertAlc();

        alListener3f(AL_POSITION, _position.x, _position.y, _position.y);
        vec3 deltaPosition = (_position - _lastPosition) * 60f;
        _lastPosition = _position;

        const vec3 forward = _forward;
        const vec3 up = _up;

        float[] listenerOri = [
            forward.x, forward.y, forward.z, up.x, up.y, up.z
        ];

        alListener3f(AL_VELOCITY, deltaPosition.x, deltaPosition.y, deltaPosition.z);
        alListenerfv(AL_ORIENTATION, listenerOri.ptr);

        //import std.stdio;writeln("forward: ", forward, "\t up: ", up, "\t pos: ", _position, "\t vit: ", deltaPosition);

        foreach (i, voice; _voices) {
            if (!voice.isPlaying) {
                _voices.mark(i);
                continue;
            }
            voice.update(this);
        }
        _voices.sweep();
        _assertAlc();
    }

    /// Joue le son
    void play(VoiceBase voice) {
        _voices.push(voice);
        _assertAlc();
    }

    private void _assertAlc() {
        const ALCenum error = alcGetError(_context);
        switch (error) {
        case ALC_NO_ERROR:
            return;
        case ALC_INVALID_DEVICE:
            throw new Exception("ALC: matériel invalide");
        case ALC_INVALID_CONTEXT:
            throw new Exception("ALC: contexte invalide");
        case ALC_INVALID_ENUM:
            throw new Exception("ALC: énum invalide");
        case ALC_INVALID_VALUE:
            throw new Exception("ALC: valeur invalide");
        case ALC_OUT_OF_MEMORY:
            throw new Exception("ALC: mémoire manquante");
        default:
            throw new Exception("ALC: erreur inconnue");
        }
    }
}
