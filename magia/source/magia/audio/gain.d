/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.gain;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;

final class AudioGain : AudioEffect {
    private {
        float _volume = 1f;
    }

    @property {
        float volume() const {
            return _volume;
        }

        float volume(float volume_) {
            return _volume = volume_;
        }
    }

    override void process(ref float[Alchimie_Audio_BufferSize] buffer) {
        buffer[] *= _volume;
    }
}
