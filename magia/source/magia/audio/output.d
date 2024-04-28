/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.output;

import core.thread;
import std.exception : enforce;
import std.stdio;
import std.string;
import bindbc.sdl;

import magia.audio.bus;
import magia.audio.config;

/// Représente un périphérique audio
final class AudioOutput {
    private {
        /// Représente le périphérique audio
        SDL_AudioDeviceID _deviceId;
        AudioBus _masterBus;
    }

    @property {
    }

    /// Init
    this(AudioBus masterBus, string deviceName = "") {
        _masterBus = masterBus;
        _openAudio(deviceName);
    }

    /// Déinit
    ~this() {
        _closeAudio();
    }

    /// Initialise le module audio
    private void _openAudio(string deviceName) {
        SDL_AudioSpec desired, obtained;

        desired.freq = Alchimie_Audio_SampleRate;
        desired.channels = Alchimie_Audio_Channels;
        desired.samples = Alchimie_Audio_FrameSize;
        desired.format = AUDIO_F32;
        desired.callback = &_callback;
        desired.userdata = cast(void*) _masterBus;

        if (deviceName.length) {
            const(char)* deviceCStr = toStringz(deviceName);
            _deviceId = SDL_OpenAudioDevice(deviceCStr, 0, &desired, &obtained, 0);
        }
        else {
            _deviceId = SDL_OpenAudioDevice(null, 0, &desired, &obtained, 0);
        }
        play();
    }

    /// Ferme le module audio
    private void _closeAudio() {
        SDL_CloseAudioDevice(_deviceId);
        _deviceId = 0;
    }

    void play() {
        SDL_PauseAudioDevice(_deviceId, 0);
    }

    void stop() {
        SDL_PauseAudioDevice(_deviceId, 1);
    }

    static private extern (C) void _callback(void* userData, ubyte* stream, int len) nothrow {
        len >>= 2; // 8 bit -> 32 bit

        AudioBus masterBus = cast(AudioBus) userData;

        float[Alchimie_Audio_BufferSize] masterBuffer;

        try {
            masterBus.process(masterBuffer);
        }
        catch (Exception e) {
        }

        float* buffer = cast(float*) stream;
        for (int i; i < len; i++) {
            buffer[i] = masterBuffer[i];
        }
    }
}
