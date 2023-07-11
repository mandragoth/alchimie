module magia.audio.audiomanager;

import std.exception : enforce;

import bindbc.sdl;
import magia.audio.mojoal;
import magia.audio.al;
import magia.audio.alc;

import std.stdio;
import std.conv;

/// Module audio
final class AudioManager {
    private {
    }

    /// Init
    this() {
        /*enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
                1024) != -1, "no audio device connected");
        enforce(Mix_AllocateChannels(16) != -1, "audio channels allocation failure");*/
        ALCenum error;

        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        ALCdevice* device = alcOpenDevice(null);
        assert(device);

        
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        ALCcontext* context;
        context = alcCreateContext(device, null);
        if (!alcMakeContextCurrent(context))
            assert(false);

            
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        float[] listenerOri = [0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f];

        alListener3f(AL_POSITION, 0, 0, 1.0f);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        alListener3f(AL_VELOCITY, 0, 0, 0);

        
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        // check for errors
        alListenerfv(AL_ORIENTATION, listenerOri);
        // check for errors

        
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        SDL_AudioSpec wav_spec;
        uint wav_length;
        ubyte* wav_buffer;
        if (!SDL_LoadWAV("assets/sound/wind.wav", &wav_spec, &wav_buffer, &wav_length)) {
            assert(false, to!string(SDL_GetError()));
        }
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        ALuint source;

        alGenSources(cast(ALuint) 1, &source);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        alSourcef(source, AL_PITCH, 1);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        alSourcef(source, AL_GAIN, 1);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        alSource3f(source, AL_POSITION, 0, 0, 0);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        alSource3f(source, AL_VELOCITY, 0, 0, 0);
        // check for errors
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        alSourcei(source, AL_LOOPING, AL_FALSE);
        // check for errros
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        ALuint buffer;

        alGenBuffers(cast(ALuint) 1, &buffer);
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        alBufferData(buffer, to_al_format(wav_spec.channels, wav_spec.format),
            wav_buffer, wav_length, wav_spec.freq);
            writeln(wav_length);
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        alSourcei(source, AL_BUFFER, buffer);
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));
        alSourcePlay(source);

        
        error = alGetError();
        assert(error == AL_NO_ERROR, to!string(error));

        writeln("Tout fini");
    }

    ~this() {
    }
}

private ALenum to_al_format(short channels, SDL_AudioFormat format) {
    bool stereo = (channels > 1);

    writeln(channels, ", ", cast(SDL_AudioFormat) format);

    switch (format) {
    case AUDIO_S16 :
        if (stereo)
            return AL_FORMAT_STEREO16;
        else
            return AL_FORMAT_MONO16;
    case AUDIO_S8:
        if (stereo)
            return AL_FORMAT_STEREO8;
        else
            return AL_FORMAT_MONO8;
    default:
        return -1;
    }
}
