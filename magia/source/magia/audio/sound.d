/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.sound;

import std.file;
import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;

/// Représente les données d’un son
final class Sound : Resource!Sound {
    private {
        float[] _buffer;
        ubyte _channels;
        ulong _samples;
        int _sampleRate;
        float _volume = 1f;
    }

    @property {
        /// Volume entre 0 et 1
        float volume() const {
            return _volume;
        }

        /// Ditto
        float volume(float volume_) {
            return _volume = clamp(volume_, 0f, 1f);
        }

        const(float[]) buffer() const {
            return _buffer;
        }

        ubyte channels() const {
            return _channels;
        }

        ulong samples() const {
            return _samples;
        }

        int sampleRate() const {
            return _sampleRate;
        }
    }

    static Sound fromMemory(const(ubyte)[] data) {
        return new Sound(data);
    }

    static Sound fromFile(string filePath) {
        return new Sound(cast(const(ubyte)[]) std.file.read(filePath));
    }
    
    static Sound fromResource(string filePath) {
        return new Sound(Magia.res.read(filePath));
    }

    /// Charge depuis un fichier
    private this(const(ubyte)[] data) {
        AudioStream stream;
        stream.openFromMemory(data);

        _channels = cast(ubyte) stream.getNumChannels();
        _samples = stream.getLengthInFrames();
        assert(_samples != audiostreamUnknownLength);

        _buffer = new float[cast(size_t)(_samples * _channels)];

        const int framesRead = stream.readSamplesFloat(_buffer);
        assert(framesRead == stream.getLengthInFrames());
        _sampleRate = cast(int) stream.getSamplerate();

        toStereo();
    }

    /// Copie
    this(Sound sound) {
        _buffer = sound._buffer;
        _channels = sound._channels;
        _samples = sound._samples;
        _sampleRate = sound._sampleRate;
        _volume = sound._volume;
    }

    /// Accès à la ressource
    Sound fetch() {
        return this;
    }

    /// Convertir en mono
    void toMono() {
        if (_channels != 2)
            return;
        _channels = 1;

        float[] buffer = new float[cast(size_t) _samples];
        for (size_t i; i < _samples; ++i) {
            buffer[i] = (_buffer[i << 1] + _buffer[(i << 1) + 1]) / 2f;
        }
        _buffer = buffer;
    }

    /// Convertir en stereo
    void toStereo() {
        if (_channels != 1)
            return;
        _channels = 2;

        float[] buffer = new float[cast(size_t)(_samples << 1)];
        for (size_t i; i < _samples; ++i) {
            buffer[i << 1] = buffer[(i << 1) + 1] = _buffer[i];
        }
        _buffer = buffer;
    }
}
