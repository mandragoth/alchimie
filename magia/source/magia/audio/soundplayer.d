/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.soundplayer;

import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;
import magia.audio.player;
import magia.audio.sound;

final class SoundPlayer : AudioPlayer {
    private {
        Sound _sound;
        SDL_AudioStream* _stream;
    }

    this(Sound sound) {
        _sound = sound;
        _stream = SDL_NewAudioStream(AUDIO_F32, _sound.channels, _sound.sampleRate,
            AUDIO_F32, Alchimie_Audio_Channels, Alchimie_Audio_SampleRate);
        const int rc = SDL_AudioStreamPut(_stream, _sound.buffer.ptr,
            cast(int)(_sound.buffer.length * float.sizeof));
        if (rc < 0) {
            remove();
        }
    }

    override size_t process(out float[Alchimie_Audio_BufferSize] buffer) {
        int framesRead = SDL_AudioStreamGet(_stream, buffer.ptr,
            cast(int)(float.sizeof * Alchimie_Audio_BufferSize));
        framesRead >>= 2;

        const float volume = _sound.volume;
        for (int i; i < Alchimie_Audio_BufferSize; i += 2) {
            buffer[i] *= volume;
            buffer[i + 1] *= volume;
        }

        if (framesRead <= 0) {
            remove();
        }
        return framesRead;
    }
}
