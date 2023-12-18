module runa.audio.sound;

import audioformats;

import bindbc.openal;

import runa.audio.context;
import runa.audio.voice;
import runa.core;
import runa.kernel;

/// Représente les données d’un son
final class Sound : Resource!Sound {
    private {
        ALuint _id;
        float[] _buffer;
        int _channels;
        ulong _samples;
        int _sampleRate;
        float _volume = 1f;
    }

    @property {
        /// Indice du son
        ALuint id() const {
            return _id;
        }

        /// Volume entre 0 et 1
        float volume() const {
            return _volume;
        }

        /// Ditto
        float volume(float volume_) {
            return _volume = clamp(volume_, 0f, 1f);
        }
    }

    /// Charge depuis un fichier
    this(string filePath) {
        AudioStream stream;
        const(ubyte)[] data = Runa.res.read(filePath);
        stream.openFromMemory(data);

        _channels = stream.getNumChannels();
        _samples = stream.getLengthInFrames();
        assert(_samples != audiostreamUnknownLength);

        _buffer = new float[cast(size_t)(_samples * _channels)];

        const int framesRead = stream.readSamplesFloat(_buffer);
        assert(framesRead == stream.getLengthInFrames());
        _sampleRate = cast(int) stream.getSamplerate();

        alGenBuffers(cast(ALuint) 1, &_id);
        alBufferData(_id, AL_FORMAT_STEREO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);
    }

    /// Copie
    this(Sound sound) {
        _id = sound._id;
        _buffer = sound._buffer;
        _channels = sound._channels;
        _samples = sound._samples;
        _sampleRate = sound._sampleRate;
    }

    private this(AudioStream stream) {
    }

    /// Accès à la ressource
    Sound fetch() {
        return this;
    }

    /// Convertir en mono
    void toMono() {
        if (_channels != 2)
            return;

        float[] buffer = new float[cast(size_t) _samples];
        for (size_t i; i < _samples; ++i) {
            buffer[i] = (_buffer[i << 1] + _buffer[(i << 1) + 1]) / 2f;
        }
        _buffer = buffer;

        alBufferData(_id, AL_FORMAT_MONO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);
    }

    /// Convertir en stereo
    void toStereo() {
        if (_channels != 1)
            return;

        float[] buffer = new float[cast(size_t)(_samples << 1)];
        for (size_t i; i < _samples; ++i) {
            buffer[i << 1] = buffer[(i << 1) + 1] = _buffer[i];
        }
        _buffer = buffer;

        alBufferData(_id, AL_FORMAT_STEREO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);
    }
}
