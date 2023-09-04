module magia.audio.sound;

import audioformats;

import bindbc.openal;

import magia.core;

import magia.audio.context;
import magia.audio.voice;

/// Représente les données d’un son
final class Sound {
    private {
        ALuint _id;
        float[] _buffer;
        int _channels;
        ulong _samples;
        int _sampleRate;
    }

    @property {
        ALuint id() const {
            return _id;
        }
    }

    /// Charge depuis un fichier
    this(string filePath) {
        AudioStream stream;
        stream.openFromFile(filePath);
        _channels = stream.getNumChannels();
        _samples = stream.getLengthInFrames();
        assert(_samples != audiostreamUnknownLength);

        _buffer = new float[_samples * _channels];

        int framesRead = stream.readSamplesFloat(_buffer);
        assert(framesRead == stream.getLengthInFrames());
        _sampleRate = cast(int) stream.getSamplerate();

        alGenBuffers(cast(ALuint) 1, &_id);
        alBufferData(_id, AL_FORMAT_STEREO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);

        toMono();
    }

    void toMono() {
        if(_channels != 2)
            return;

        float[] buffer = new float[_samples];
        for (size_t i; i < _samples; ++i) {
            buffer[i] = (_buffer[i << 1] + _buffer[(i << 1) + 1]) / 2f;
        }
        _buffer = buffer;
        
        alBufferData(_id, AL_FORMAT_MONO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);
    }

    void toStereo() {
        if(_channels != 1)
            return;

        float[] buffer = new float[_samples << 1];
        for (size_t i; i < _samples; ++i) {
            buffer[i << 1] = buffer[(i << 1) + 1] = _buffer[i];
        }
        _buffer = buffer;
        
        alBufferData(_id, AL_FORMAT_STEREO_FLOAT32, _buffer.ptr,
            cast(int)(_buffer.length * float.sizeof), _sampleRate);
    }

    /// Joue le son
    Voice play(vec3 position) {
        Voice voice = playSound(this);
        voice.position = position;
        return voice;
    }
}
