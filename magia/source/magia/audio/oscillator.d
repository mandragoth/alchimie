/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.oscillator;

import std.math;
import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.player;

final class Oscillator : AudioPlayer {
    private {
        int _currentFrame;
        float _frequency;
    }

    this(float frequency) {
        _frequency = frequency;
    }

    override size_t process(out float[Alchimie_Audio_BufferSize] buffer) {
        float v = 2f * PI * _frequency / Alchimie_Audio_SampleRate;
        for (int i; i < Alchimie_Audio_BufferSize; i += 2) {
            float sample = 0.4 * sin(v * _currentFrame);
            buffer[i] = sample;
            buffer[i + 1] = sample;
            ++_currentFrame;
        }

        return Alchimie_Audio_BufferSize;
    }
}
