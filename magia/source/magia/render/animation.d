module magia.render.animation;

import std.stdio;

import magia.core;

/// Type of interpolation
enum Interpolation {
    linear_t = 0,
    step_t,
    cubicspline_t
}

/// Structure holding animation data
class Animation {
    private {
        // Start of the animation
        float _start;
        // End of the animation
        float _end;
        // Keyframes times in seconds
        float[] _keyTimes;
        // Array of translations to interpolate between
        vec3[] _translations;
        // Array of rotations to interpolate between
        quat[] _rotations;
        // Array of scales to intepolate between
        vec3[] _scales;
        // Interpolation function used
        Interpolation _interpolation;
        // Timer used to run the animation
        Timer timer;
        // Trace mechanism
        bool _trace;
    }
    
    /// Constructor
    this(float start, float end, float[] keyTimes, string interpolation, vec3[] translations, quat[] rotations, vec3[] scales, bool trace = false) {
        _start = start;
        _end = end;
        _keyTimes = keyTimes;
        _interpolation = buildInterpolation(interpolation);
        _translations = translations;
        _rotations = rotations;
        _scales = scales;
        _trace = trace;

        if (_trace) {
            writeln("  New animation");
            writeln("    Key times: ", _keyTimes);
            if (_translations) {
                writeln("    Translations: ", _translations);
            }
            if (_rotations) {
                writeln("    Rotations: ", _rotations);
            }
            if (_scales) {
                writeln("    Scales: ", _scales);
            }
        }
    }

    /// Update animation
    void update() {
        // Start timer if not yet done
        if (!timer.isRunning) {
            timer.mode = Timer.Mode.loop;
            timer.start(cast(int) _end); //@TODO: Flemme de changer ça maintenant, mais faut plus travailler avec des secondes, mais des ticks dorénavant
        } else {
            timer.update();
        }
    }

    /// Are we looking at a valid animation time?
    bool validTime() {
        return timer.value >= _start && timer.value <= _end;
    }

    /// Interpolate translations
    mat4 computeInterpolatedModel() {
        vec3 translation = vec3.zero;
        if (_translations) {
            translation = computeInterpolatedVec3(_translations);
        }

        quat rotation = quat.identity;
        if (_rotations) {
            rotation = computeInterpolatedQuat(_rotations);
        }

        vec3 scale = vec3.one;
        if (_scales) {
            scale = computeInterpolatedVec3(_scales);
        }

        return combineModel(translation, rotation, scale);
    }

    private {
        /// Build interpolation from gltf string value
        Interpolation buildInterpolation(string sInterpolation) {
            if (sInterpolation == "LINEAR") {
                return Interpolation.linear_t;
            } else if (sInterpolation == "STEP") {
                return Interpolation.step_t;
            } else if (sInterpolation == "CUBICSPLINE") {
                return Interpolation.cubicspline_t;
            }

            return Interpolation.linear_t;
        }

        vec3 computeInterpolatedVec3(vec3[] values) {
            // Compute current time
            const float currentTime = timer.value;

            // Times and values need to be aligned
            assert(values.length == _keyTimes.length);

            // We need at least two values to interpolate
            if (values.length == 1) {
                return values[0];
            }

            // Find range of times holding the current time value
            const uint startId = findAnimStart(currentTime);
            const uint endId  = startId + 1;
            assert(endId < values.length);

            // Get time parameters for interpolation
            const float t1 = _keyTimes[startId];
            const float t2 = _keyTimes[endId];
            const float dt = t2 - t1;
            const float f  = (currentTime - t1) / dt;
            assert(f >= 0f && f <= 1f);

            // Get value parameters for interpolation
            const vec3 vecStart = values[startId];
            const vec3 vecEnd = values[endId];
            const vec3 vecDelta = vecEnd - vecStart;

            // Perform linear interpolation (@TODO handle other types)
            return vecStart + f * vecDelta;
        }

        quat computeInterpolatedQuat(quat[] values) {
            // Compute current time
            const float currentTime = timer.value;

            // Times and values need to be aligned
            assert(values.length == _keyTimes.length);

            // We need at least two values to interpolate
            if (values.length == 1) {
                return values[0];
            }

            // Find range of times holding the current time value
            const uint startId = findAnimStart(currentTime);
            const uint endId  = startId + 1;
            assert(endId < values.length);

            // Get time parameters for interpolation
            const float t1 = _keyTimes[startId];
            const float t2 = _keyTimes[endId];
            const float dt = t2 - t1;
            const float f  = (currentTime - t1) / dt;
            assert(f >= 0f && f <= 1f);

            // Get value parameters for interpolation
            quat quatStart = values[startId];
            quat quatEnd = values[endId];
            float dotProduct = quatStart.dot(quatEnd);

            // Make sure we take the shortest path in case dot product is negative
            if (dotProduct < 0f) {
                quatEnd = quatEnd.inverse();
                dotProduct = -dotProduct;
            }

            // If both quaternions are too close (epsilon = 0.0005) to each other, use linear interpolation
            if (dotProduct > 0.9995) {
                quat delta = quatEnd - quatStart;
                return quatStart + f * delta;
            }

            // Perform spherical linear interpolation
            const float theta_0 = acos(dotProduct);
            const float theta = f * theta_0;
            const float sin_theta = sin(theta);
            const float sin_theta_0 = sin(theta_0);

            const float scaleStart = cos(theta) - dotProduct * sin_theta / sin_theta_0;
            const float scaleEnd = sin_theta / sin_theta_0;
            return quatStart * scaleStart + quatEnd * scaleEnd;
        }

        uint findAnimStart(float currentTime) {
            assert(_keyTimes.length > 0);

            for (uint timeId = 1; timeId < _keyTimes.length; ++timeId) {
                const float t = _keyTimes[timeId];
                if (currentTime < t) {
                    return timeId - 1;
                }
            }

            return 0;
        }
    }
}