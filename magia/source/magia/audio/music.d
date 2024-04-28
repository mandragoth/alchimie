/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.music;

import std.stdio;
import std.file;
import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.audio.musicplayer;

/// Représente les données d’un son
final class Music : Resource!Music {
    private {
        const(ubyte)[] _data;
        ubyte _channels;
        ulong _samples;
        int _sampleRate;
        float _volume = 1f;
        float _loopStart = -1f;
        float _loopEnd = -1f;
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

        /// Début de la boucle
        float loopStart() const {
            return _loopStart;
        }

        /// Ditto
        float loopStart(float loopStart_) {
            return _loopStart = loopStart_;
        }

        /// Fin de la boucle
        float loopEnd() const {
            return _loopEnd;
        }

        /// Ditto
        float loopEnd(float loopEnd_) {
            return _loopEnd = loopEnd_;
        }

        const(ubyte)[] data() const {
            return _data;
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

    static Music fromMemory(const(ubyte)[] data) {
        return new Music(data);
    }

    static Music fromFile(string filePath) {
        return new Music(cast(const(ubyte)[]) std.file.read(filePath));
    }

    static Music fromResource(string filePath) {
        return new Music(Magia.res.read(filePath));
    }

    /// Charge depuis un fichier
    this(const(ubyte)[] data) {
        AudioStream stream;
        _data = data;
        stream.openFromMemory(_data);

        _channels = cast(ubyte) stream.getNumChannels();
        _samples = stream.getLengthInFrames();
        assert(_samples != audiostreamUnknownLength);

        _sampleRate = cast(int) stream.getSamplerate();
    }

    /// Copie
    this(Music music) {
        _data = music._data;
        _channels = music._channels;
        _samples = music._samples;
        _sampleRate = music._sampleRate;
        _volume = music._volume;
        _loopStart = music._loopStart;
        _loopEnd = music._loopEnd;
    }

    /// Accès à la ressource
    Music fetch() {
        return this;
    }
}
