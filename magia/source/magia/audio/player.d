/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.player;

import std.stdio;
import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.audio.effect;
import magia.audio.config;
import magia.audio.music;
import magia.audio.sound;

abstract class AudioPlayer {
    private {
        Array!AudioEffect _effects;
        bool _isAlive = true;

    }

    @property {
        final bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
        _effects = new Array!AudioEffect;
    }

    final void addEffect(AudioEffect effect) {
        _effects ~= effect;
    }

    final void remove() {
        _isAlive = false;
    }

    package final void processEffects(ref float[Alchimie_Audio_BufferSize] buffer) {
        foreach (i, effect; _effects) {
            effect.process(buffer);

            if (!effect.isAlive)
                _effects.mark(i);
        }
        _effects.sweep();
    }

    abstract size_t process(out float[Alchimie_Audio_BufferSize]);
}
