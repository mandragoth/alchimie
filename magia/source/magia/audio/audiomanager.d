module magia.audio.audiomanager;

import std.exception : enforce;

import bindbc.sdl;
import bindbc.openal;

import std.stdio;
import std.conv;

void checkAL() {
    ALenum error = alGetError();
    switch (error) {
    case AL_NO_ERROR:
        return;
    case AL_INVALID_NAME:
        throw new Exception("AL: nom invalide");
    case AL_INVALID_ENUM:
        throw new Exception("AL: énum invalide");
    case AL_INVALID_VALUE:
        throw new Exception("AL: valeur invalide");
    case AL_INVALID_OPERATION:
        throw new Exception("AL: opération invalide");
    case AL_OUT_OF_MEMORY:
        throw new Exception("AL: mémoire manquante");
    default:
        throw new Exception("AL: erreur inconnue");
    }
}

void checkALC(ALCcontext* context) {
    ALCenum error = alcGetError(context);
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

/// Module audio
final class AudioManager {
    private {
    }

    /// Init
    this() {
        ALSupport ret = loadOpenAL();
        if (ret != ALSupport.al11) {

            // Handle error. For most use cases, its reasonable to use the error handling API in
            // bindbc-loader to retrieve error messages and then abort. If necessary, it's  possible
            // to determine the root cause via the return value:

            if (ret == ALSupport.noLibrary) {
                assert(false);
                // GLFW shared library failed to load
            } else if (ALSupport.badLibrary) {
                // One or more symbols failed to load.
                assert(false);
            }
            assert(false);
        }

        /*enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
                1024) != -1, "no audio device connected");
        enforce(Mix_AllocateChannels(16) != -1, "audio channels allocation failure");*/

        //error = alGetError();
        //assert(error == AL_NO_ERROR, to!string(error));

        ALCdevice* device = alcOpenDevice(null);
        assert(device);

        ALCcontext* context;
        context = alcCreateContext(device, null);
        if (!alcMakeContextCurrent(context))
            assert(false);

        checkALC(context);
        float[] listenerOri = [0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f];

        alListener3f(AL_POSITION, 0, 0, 1.0f);
        checkAL();

        alListener3f(AL_VELOCITY, 0, 0, 0);
        checkAL();

        alListenerfv(AL_ORIENTATION, listenerOri.ptr);
        checkAL();

        SDL_AudioSpec wav_spec;
        uint wav_length;
        ubyte* wav_buffer;
        if (!SDL_LoadWAV("assets/sound/wind.wav", &wav_spec, &wav_buffer, &wav_length)) {
            assert(false, to!string(SDL_GetError()));
        }

        ALuint source;

        alGenSources(cast(ALuint) 1, &source);
        checkAL();

        alSourcef(source, AL_PITCH, 1);
        checkAL();

        alSourcef(source, AL_GAIN, 1);
        checkAL();

        alSource3f(source, AL_POSITION, 0, 0, 0);
        checkAL();

        alSource3f(source, AL_VELOCITY, 0, 0, 0);
        checkAL();

        alSourcei(source, AL_LOOPING, AL_FALSE);
        checkAL();

        ALuint buffer;

        alGenBuffers(cast(ALuint) 1, &buffer);
        checkAL();

        alBufferData(buffer, to_al_format(wav_spec.channels, wav_spec.format),
            wav_buffer, wav_length, wav_spec.freq);
        checkAL();

        alSourcei(source, AL_BUFFER, buffer);
        checkAL();

        alSourcePlay(source);
        checkAL();

        writeln("Tout fini");
    }

    ~this() {
    }
}

private ALenum to_al_format(short channels, SDL_AudioFormat format) {
    bool stereo = (channels > 1);

    writeln(channels, ", ", cast(SDL_AudioFormat) format);

    switch (format) {
    case AUDIO_S16:
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
