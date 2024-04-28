/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.spacializer;

import std.math;

import magia.core;
import magia.kernel;
import magia.audio.config;
import magia.audio.effect;
/*
final class AudioSpacializer : AudioEffect {
    private {
        Vec2f _position = Vec2f.zero;
        float _minDistance = 0f, _maxDistance = 1000f;
        float _minVolume = 0f, _maxVolume = 1f;
        Spline _attenuationSpline = Spline.linear;
        Spline _orientationSpline = Spline.linear;
        float _leftToLeftVolume = 1f;
        float _leftToRightVolume = 0f;
        float _rightToRightVolume = 1f;
        float _rightToLeftVolume = 0f;
        float _globalVolume = 1f;
    }

    @property {
        Vec2f position() const {
            return _position;
        }

        Vec2f position(Vec2f position_) {
            _position = position_;
            _reload();
            return _position;
        }

        Spline attenuationSpline() const {
            return _attenuationSpline;
        }

        Spline attenuationSpline(Spline attenuationSpline_) {
            _attenuationSpline = attenuationSpline_;
            _reload();
            return _attenuationSpline;
        }

        Spline orientationSpline() const {
            return _orientationSpline;
        }

        Spline orientationSpline(Spline orientationSpline_) {
            _orientationSpline = orientationSpline_;
            _reload();
            return _orientationSpline;
        }

        float minDistance() const {
            return _minDistance;
        }

        float minDistance(float minDistance_) {
            _minDistance = minDistance_;
            _reload();
            return _minDistance;
        }

        float maxDistance() const {
            return _maxDistance;
        }

        float maxDistance(float maxDistance_) {
            _maxDistance = maxDistance_;
            _reload();
            return _maxDistance;
        }

        float minVolume() const {
            return _minVolume;
        }

        float minVolume(float minVolume_) {
            _minVolume = minVolume_;
            _reload();
            return _minVolume;
        }

        float maxVolume() const {
            return _maxVolume;
        }

        float maxVolume(float maxVolume_) {
            _maxVolume = maxVolume_;
            _reload();
            return _maxVolume;
        }
    }

    private void _reload() {
        SplineFunc orientationSplineFunc = getSplineFunc(_orientationSpline);

        float orientation = rlerp(_minDistance, _maxDistance, abs(_position.x));
        orientation = clamp(orientation, 0f, 1f);
        if (_position.x < 0f)
            orientation = -orientation;

        if (orientation < 0f) {
            float t = orientationSplineFunc(-orientation);
            _leftToLeftVolume = _rightToRightVolume = 1f - t;
            _leftToRightVolume = 0f;
            _rightToLeftVolume = t;
        }
        else {
            float t = orientationSplineFunc(orientation);
            _leftToLeftVolume = _rightToRightVolume = 1f - t;
            _leftToRightVolume = t;
            _rightToLeftVolume = 0f;
        }

        float dist = _position.distance(Vec2f.zero);
        if (dist > _maxDistance) {
            _globalVolume = _minVolume;
        }
        else if (dist < _minDistance) {
            _globalVolume = _maxVolume;
        }
        else {
            SplineFunc attenuationSplineFunc = getSplineFunc(_attenuationSpline);
            float volume = rlerp(_minDistance, _maxDistance, dist);
            _globalVolume = lerp(_maxVolume, _minVolume, attenuationSplineFunc(volume));
        }
    }

    override void process(ref float[Alchimie_Audio_BufferSize] buffer) {
        for (size_t i; i < Alchimie_Audio_BufferSize; i += 2) {
            float leftSample = buffer[i];
            float rightSample = buffer[i + 1];
            buffer[i] = (leftSample * _leftToLeftVolume + rightSample * _rightToLeftVolume) *
                _globalVolume;
            buffer[i + 1] = (rightSample * _rightToRightVolume + leftSample * _leftToRightVolume) *
                _globalVolume;
        }
    }
}
*/