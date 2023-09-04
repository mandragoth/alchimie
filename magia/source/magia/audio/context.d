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

private {
    AudioContext _currentContext;
}

void setCurrentAudioContext(AudioContext context) {
    _currentContext = context;
}

/// Joue le son
Voice playSound(Sound sound) {
    if (!_currentContext)
        return null;

    return _currentContext.play(sound);
}

/// Contexte audio 3D
final class AudioContext {
    private {
        ALCcontext* _context;
        Array!Voice _voices;
        Camera _camera;

        vec3 _lastPosition;
    }

    @property {
        vec3 position() const {
            return _camera ? _camera.transform.position : vec3.zero;
        }
    }

    /// Init
    this(Camera camera) {
        _voices = new Array!Voice;
        _camera = camera;
        _context = alcCreateContext(_device, null);
        _lastPosition = _camera.transform.position;
        check();
    }

    private void check() {
        ALCenum error = alcGetError(_context);
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

    void update() {
        enforce(alcMakeContextCurrent(_context), "[Audio] impossible de mettre à jour le contexte");

        alListener3f(AL_POSITION, _camera.transform.position.x,
            _camera.transform.position.y, _camera.transform.position.y);
        vec3 deltaPosition = (_camera.transform.position - _lastPosition) * 60f;
        _lastPosition = _camera.transform.position;

        vec3 forward = TMP_AUDIO_CAMFORWARD;
        vec3 up = TMP_AUDIO_CAMFORWARD;

        float[] listenerOri = [forward.x, forward.y, forward.z, up.x, up.y, up.z];

        alListener3f(AL_VELOCITY, deltaPosition.x, deltaPosition.y, deltaPosition.z);
        alListenerfv(AL_ORIENTATION, listenerOri.ptr);

        foreach (i, voice; _voices) {
            if (!voice.isPlaying) {
                _voices.mark(i);
                continue;
            }
            voice.update(this);
        }
        _voices.sweep();
        check();
    }

    /// Joue le son
    Voice play(Sound sound) {
        Voice voice = new Voice(sound);
        _voices.push(voice);
        check();
        return voice;
    }
}
