/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.panner;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;

final class AudioPanner : AudioEffect {
    private {
        float _panning = 0f;
    }

    @property {
        float panning() const {
            return _panning;
        }

        float panning(float panning_) {
            return _panning = clamp(panning_, -1f, 1f);
        }
    }

    override void process(ref float[Alchimie_Audio_BufferSize] buffer) {
        float mix = (_panning + 1f) * 0.5f;
        float leftVolume = 1f - mix;
        float rightVolume = mix;

        for (size_t i; i < Alchimie_Audio_BufferSize; i += 2) {
            float leftSample = buffer[i];
            float rightSample = buffer[i + 1];
            buffer[i] = leftSample * leftVolume + rightSample * (1f - rightVolume);
            buffer[i + 1] = rightSample * rightVolume + leftSample * (1f - leftVolume);
        }
    }
}
