/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.fader;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;

final class AudioFader : AudioEffect {
    private {
        Spline _spline = Spline.linear;
        SplineFunc _splineFunc;
        float _duration = 1f, _delay = 0f;
        int _currentFrame, _startFrame, _endFrame;
        bool _isFadeIn;
    }

    @property {
        bool isFadeIn() const {
            return _isFadeIn;
        }

        bool isFadeIn(bool isFadeIn_) {
            return _isFadeIn = isFadeIn_;
        }

        Spline spline() const {
            return _spline;
        }

        Spline spline(Spline spline_) {
            _spline = spline_;
            _splineFunc = getSplineFunc(_spline);
            return _spline;
        }

        float duration() const {
            return _duration;
        }

        float duration(float duration_) {
            _duration = duration_;
            _reload();
            return _duration;
        }

        float delay() const {
            return _delay;
        }

        float delay(float delay_) {
            _delay = delay_;
            _reload();
            return _delay;
        }
    }

    this() {
        _currentFrame = 0;
        _splineFunc = getSplineFunc(_spline);
        _reload();
    }

    private void _reload() {
        _startFrame = cast(int)(_delay * Alchimie_Audio_SampleRate);
        _endFrame = cast(int)(_startFrame + (_duration * Alchimie_Audio_SampleRate));
    }

    override void process(ref float[Alchimie_Audio_BufferSize] buffer) {
        if (_currentFrame + Alchimie_Audio_FrameSize < _startFrame) {
            _currentFrame += Alchimie_Audio_FrameSize;
            if (_isFadeIn) {
                buffer[] = 0f;
            }
            return;
        }

        for (size_t i; i < Alchimie_Audio_BufferSize; i += 2) {
            if (_currentFrame > _startFrame) {
                if (_currentFrame >= _endFrame) {
                    remove();
                    triggerCallback();
                    return;
                }
                float t = rlerp(_startFrame, _endFrame, _currentFrame);
                t = _splineFunc(t);
                t = _isFadeIn ? t : 1f - t;
                buffer[i] *= t;
                buffer[i + 1] *= t;
            }
            else if (_isFadeIn) {
                buffer[i] = 0f;
                buffer[i + 1] = 0f;
            }
            _currentFrame++;
        }
    }
}
