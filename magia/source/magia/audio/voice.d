module magia.audio.voice;

import bindbc.openal;

import magia.core;
import magia.main;

import magia.audio.context;
import magia.audio.sound;
import magia.audio.source;

/// Instance d’un son
final class Voice {
    private {
        ALuint _id;
        Sound _sound;
        vec3 _position, _lastPosition;
        ulong _tick;
        bool _hasPlayed;
    }

    @property {
        bool isPlaying() {
            int value = void;
            alGetSourcei(_id, AL_SOURCE_STATE, &value);
            return value != AL_STOPPED;
        }

        vec3 position() const {
            return _position;
        }

        vec3 position(vec3 position_) {
            _lastPosition = _position;
            _position = position_;
            alSource3f(_id, AL_POSITION, _position.x, _position.y, _position.z);
            return _position;
        }
    }

    /// Init
    this(Sound sound) {
        alGenSources(cast(ALuint) 1, &_id);
        _tick = currentApplication.currentTick;

        alSourcef(_id, AL_PITCH, 1);
        alSourcef(_id, AL_GAIN, 1);
        alSource3f(_id, AL_POSITION, 0, 0, 0);
        alSource3f(_id, AL_VELOCITY, 0, 0, 0);
        alSourcei(_id, AL_LOOPING, AL_FALSE);

        alSourcei(_id, AL_BUFFER, sound.id);
    }

    void update(AudioContext context) {
        if (!_hasPlayed) {
            double deltaTime = (cast(double) currentApplication.currentTick - cast(double) _tick) / cast(
                double) currentApplication.ticksPerSecond;

            double speedOfSound = 340.3;

            double dist = (context.position - _position).length;

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
