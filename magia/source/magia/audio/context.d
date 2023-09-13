module magia.audio.context;

import std.exception : enforce;

import bindbc.openal;

import magia.core;
import magia.render;

import magia.audio.device;
import magia.audio.sound;
import magia.audio.voice;

/*
/// Contexte audio
abstract class AudioContext {
    private {
        ALCcontext* _context;
    }

    /// Met à jour les propriétés du contexte
    void update();
}

/// Contexte audio 2D
final class AudioContext2D : AudioContext {
    private {
        Voice2D[] _voices;
    }

    /// Init
    this() {

    }

    override void update() {
        alListener3f(AL_POSITION, 0, 0, 1.0f);
        alListener3f(AL_VELOCITY, 0, 0, 0);
        alListenerfv(AL_ORIENTATION, listenerOri.ptr);
    }
}*/

/// Contexte audio 3D
final class AudioContext(uint Dim = 3u) {
    private {
        ALCcontext* _context;
        Array!(Voice!Dim) _voices;
        PerspectiveCamera _camera;

        vec3 _lastPosition;
    }

    @property {
        /// Get position
        vec3 position() const {
            return _camera ? _camera.transform.position : vec3.zero;
        }
    }

    /// Init
    this(AudioDevice device, PerspectiveCamera camera) {
        _voices = new Array!(Voice!Dim);
        _camera = camera;
        _lastPosition = _camera.transform.position;

        _context = alcCreateContext(device.handle, null);
        _assertAlc();
        enforce(_context, "[Audio] impossible de créer le contexte");
    }

    static if (Dim == 3u) {
        /// Update
        void update() {
            enforce(alcMakeContextCurrent(_context) == ALC_TRUE,
                "[Audio] impossible de mettre à jour le contexte");
            _assertAlc();

            alListener3f(AL_POSITION, _camera.transform.position.x,
                _camera.transform.position.y, _camera.transform.position.y);
            vec3 deltaPosition = (_camera.transform.position - _lastPosition) * 60f;
            _lastPosition = _camera.transform.position;

            const vec3 forward = _camera.forward.normalized();
            const vec3 up = _camera.up.normalized();

            float[] listenerOri = [
                forward.x, forward.y, forward.z, up.x, up.y, up.z
            ];

            alListener3f(AL_VELOCITY, deltaPosition.x, deltaPosition.y, deltaPosition.z);
            alListenerfv(AL_ORIENTATION, listenerOri.ptr);

            //import std.stdio;writeln("forward: ", forward, "\t up: ", up, "\t pos: ", _camera.transform.position, "\t vit: ", deltaPosition);

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
    }
    else {
        /// Update
        void update() {}
    }

    /// Joue le son
    Voice!Dim play(Sound sound) {
        Voice!Dim voice = new Voice!Dim(sound);
        _voices.push(voice);
        _assertAlc();
        return voice;
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

alias AudioContext3D = AudioContext!3u;
alias AudioContext2D = AudioContext!2u;
