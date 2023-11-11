module magia.audio.voice;

import bindbc.openal;

import magia.core;
import magia.main;

import magia.audio.context;
import magia.audio.sound;
import magia.audio.source;

/// Instance d’un son
abstract class VoiceBase {
    private {
        ALuint _id;
        float _volume = 1f;
    }

    @property {
        protected ALuint id() const {
            return _id;
        }

        /// Le son est-il en train de se jouer ?
        bool isPlaying() const {
            int value = void;
            alGetSourcei(_id, AL_SOURCE_STATE, &value);
            return value != AL_STOPPED;
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
    this() {
        alGenSources(cast(ALuint) 1, &_id);

        alSourcef(_id, AL_PITCH, 1f);
        alSourcef(_id, AL_GAIN, 1f);
        alSource3f(_id, AL_POSITION, 0f, 0f, 0f);
        alSource3f(_id, AL_VELOCITY, 0f, 0f, 0f);
        alSourcei(_id, AL_LOOPING, AL_FALSE);
    }

    /// Màj
    void update(AudioContext);
}

/// Instance d’un son
final class Voice : VoiceBase {
    /// Init
    this(Sound sound) {
        alSourcei(_id, AL_BUFFER, sound.id);
        volume = sound.volume;

        alSourcePlay(_id);
    }

    /// Màj
    override void update(AudioContext context) {

    }
}

/// Instance d’un son
final class Voice3D : VoiceBase {
    private {
        vec3 _position, _lastPosition;
        ulong _tick;
        bool _hasPlayed;
    }

    @property {
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
    }

    /// Init
    this(Sound sound) {
        _tick = Magia.currentTick;

        alSourcei(_id, AL_BUFFER, sound.id);
        volume = sound.volume;
    }

    /// Update
    override void update(AudioContext context) {
        if (!_hasPlayed) {
            double deltaTime = (cast(double) Magia.currentTick - cast(double) _tick) / cast(double) Magia
                .ticksPerSecond;

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
