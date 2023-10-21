module magia.audio.voice;

import bindbc.openal;

import magia.core;
import magia.main;

import magia.audio.context;
import magia.audio.sound;
import magia.audio.source;

/// Instance d’un son
final class Voice(uint Dim = 3u) {
    private {
        ALuint _id;
        Sound _sound;
        vec3 _position, _lastPosition;
        ulong _tick;
        bool _hasPlayed;
        float _volume = 1f;
    }

    @property {
        /// Le son est-il en train de se jouer ?
        bool isPlaying() {
            int value = void;
            alGetSourcei(_id, AL_SOURCE_STATE, &value);
            return value != AL_STOPPED;
        }

        /// Recuperer la position du son dans la scene
        vec3 position() const {
            return _position;
        }

        /// Ajuster la position du son dans la scene
        vec3 position(vec3 position_) {
            _lastPosition = _position;
            _position = position_;
            alSource3f(_id, AL_POSITION, _position.x, _position.y, _position.z);
        //import std.stdio;writeln("pos: ", _position);
            return _position;
        }

        /// Volume entre 0 et 1
        float volume() const {
            return _volume;
        }

        /// Ditto
        float volume(float volume_) {
            _volume = clamp(volume_, 0f, 1f);
            alSourcef(_id, AL_GAIN, _volume);
            return _volume;
        }
    }

    /// Init
    this(Sound sound) {
        alGenSources(cast(ALuint) 1, &_id);
        _tick = Magia.currentTick;

        alSourcef(_id, AL_PITCH, 1);
        alSourcef(_id, AL_GAIN, sound.volume);
        alSource3f(_id, AL_POSITION, 0, 0, 0);
        alSource3f(_id, AL_VELOCITY, 0, 0, 0);
        alSourcei(_id, AL_LOOPING, AL_FALSE);

        alSourcei(_id, AL_BUFFER, sound.id);
    }

    /// Update
    void update(AudioContext3D context) {
        if (!_hasPlayed) {
            double deltaTime = (cast(double) Magia.currentTick - cast(double) _tick) / cast(
                double) Magia.ticksPerSecond;

            const double speedOfSound = 340.3;

            const double dist = (context.position - _position).length;

            if (dist <= deltaTime * speedOfSound) {
                alSourcePlay(_id);
                _hasPlayed = true;
            }
        }

        vec3 velocity = (_position - _lastPosition) * 60f;
        alSource3f(_id, AL_VELOCITY, velocity.x, velocity.y, velocity.z);
        _lastPosition = _position;
    }
}

alias Voice3D = Voice!3u;
alias Voice2D = Voice!2u;