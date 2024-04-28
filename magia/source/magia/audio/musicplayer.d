/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.musicplayer;

import audioformats;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;
import magia.audio.music;
import magia.audio.player;

final class MusicPlayer : AudioPlayer {
    private {
        Music _music;
        int _currentFrame, _startLoopFrame, _endLoopFrame;
        int _delayStartFrame, _delayPauseFrame, _delayStopFrame;
        SDL_AudioStream* _stream;
        AudioStream _decoder;
        float[] _decoderBuffer;
    }

    @property {
        float currentPosition() const {
            return cast(float) _currentFrame / cast(float) _music.sampleRate;
        }
    }

    this(Music music, float delay = 0f, float startPosition = 0f) {
        _music = music;
        _stream = SDL_NewAudioStream(AUDIO_F32, _music.channels, _music.sampleRate,
            AUDIO_F32, Alchimie_Audio_Channels, Alchimie_Audio_SampleRate);
        _decoderBuffer = new float[cast(size_t)(Alchimie_Audio_FrameSize * _music.channels)];

        _delayStartFrame = cast(int)(delay * _music.sampleRate);
        _delayStopFrame = -1;
        _delayPauseFrame = -1;

        _startLoopFrame = 0;
        _endLoopFrame = cast(int) _music.samples;

        if (_music.loopStart > 0f) {
            _startLoopFrame = clamp(cast(int)(_music.loopStart * _music.sampleRate),
                0, cast(int) _music.samples);
        }

        if (_music.loopEnd > 0f) {
            _endLoopFrame = clamp(cast(int)(_music.loopEnd * _music.sampleRate),
                _startLoopFrame, cast(int) _music.samples);
        }

        if (_startLoopFrame >= _endLoopFrame) {
            _startLoopFrame = 0;
        }

        _initDecoder();
        if (startPosition > 0f) {
            int startFrame = clamp(cast(int)(startPosition * _music.sampleRate),
                0, cast(int) _music.samples);
            _decoder.seekPosition(startFrame);
            _currentFrame = startFrame;
        }
    }

    void resume(float delay = 0f) {
        _delayStopFrame = -1;
        _delayPauseFrame = -1;

        if (delay == 0f) {
            _delayStartFrame = 0;
        }
        else {
            _delayStartFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    void pause(float delay = 0f) {
        _delayStopFrame = -1;

        if (delay == 0f) {
            _delayPauseFrame = 0;
        }
        else {
            _delayPauseFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    void stop(float delay = 0f) {
        _delayPauseFrame = -1;

        if (delay == 0f) {
            remove();
            _delayStopFrame = 0;
        }
        else {
            _delayStopFrame = cast(int)(delay * _music.sampleRate);
        }
    }

    private void _initDecoder() {
        _decoder.openFromMemory(_music.data);
    }

    private void _decode(int framesToRead = Alchimie_Audio_FrameSize) {
        int framesRead;

        for (;;) {
            if (_currentFrame >= _endLoopFrame) {
                _initDecoder();
                _decoder.seekPosition(_startLoopFrame);
                _currentFrame = _startLoopFrame;
            }
            else if (_currentFrame + framesToRead > _endLoopFrame) {
                framesToRead = _endLoopFrame - _currentFrame;
            }

            framesRead = _decoder.readSamplesFloat(_decoderBuffer.ptr, framesToRead);

            if (framesRead == 0) {
                _initDecoder();
                _decoder.seekPosition(_startLoopFrame);
                _currentFrame = _startLoopFrame;
                continue;
            }

            const int rc = SDL_AudioStreamPut(_stream, _decoderBuffer.ptr,
                cast(int)(framesRead * _music.channels * float.sizeof));
            if (rc < 0) {
                remove();
            }

            _currentFrame += framesRead;
            framesToRead -= framesRead;

            if (framesToRead <= 0)
                return;
        }
    }

    override size_t process(out float[Alchimie_Audio_BufferSize] buffer) {
        int framesToRead = Alchimie_Audio_FrameSize;

        if (_delayStopFrame >= 0) {
            if (_delayStopFrame >= framesToRead) {
                _delayStopFrame -= framesToRead;
            }
            else {
                framesToRead = _delayStopFrame;
                remove();

                if (framesToRead == 0)
                    return 0;
            }
        }

        if (_delayPauseFrame >= 0) {
            if (_delayPauseFrame >= framesToRead) {
                _delayPauseFrame -= framesToRead;
            }
            else {
                framesToRead = _delayPauseFrame;

                if (framesToRead == 0)
                    return 0;
            }
        }

        if (_delayStartFrame > 0) {
            if (_delayStartFrame >= framesToRead) {
                _delayStartFrame -= framesToRead;
                return 0;
            }
            framesToRead -= _delayStartFrame;
            _delayStartFrame = 0;
        }

        _decode(framesToRead);
        int framesRead = SDL_AudioStreamGet(_stream, buffer.ptr + (Alchimie_Audio_Channels * _delayStartFrame * (float*)
                .sizeof), cast(int)(float.sizeof * Alchimie_Audio_Channels * framesToRead));

        if (framesRead >= 0) {
            framesRead >>= 2;

            const float volume = _music.volume;
            for (int i = _delayStartFrame * Alchimie_Audio_Channels; i < (
                    (_delayStartFrame + framesToRead) * Alchimie_Audio_Channels); i += 2) {
                buffer[i] *= volume;
                buffer[i + 1] *= volume;
            }
        }
        else {
            remove();
        }

        return framesRead;
    }
}
