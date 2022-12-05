/**
    Tweening

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.core.spline;

import std.math;

import magia.common;
import magia.core.util;

alias SplineFunc = float function(float);

/// Courbes d’interpolation
enum Spline {
    linear,
    sineIn,
    sineOut,
    sineInOut,
    quadIn,
    quadOut,
    quadInOut,
    cubicIn,
    cubicOut,
    cubicInOut,
    quartIn,
    quartOut,
    quartInOut,
    quintIn,
    quintOut,
    quintInOut,
    expIn,
    expOut,
    expInOut,
    circIn,
    circOut,
    circInOut,
    backIn,
    backOut,
    backInOut,
    elasticIn,
    elasticOut,
    elasticInOut,
    bounceIn,
    bounceOut,
    bounceInOut,
}

/// Returns an easing function.
SplineFunc getSplineFunc(Spline ease = Spline.linear) {
    final switch (ease) with (Spline) {
    case linear:
        return &easeLinear;
    case sineIn:
        return &easeInSine;
    case sineOut:
        return &easeOutSine;
    case sineInOut:
        return &easeInOutSine;
    case quadIn:
        return &easeInQuad;
    case quadOut:
        return &easeOutQuad;
    case quadInOut:
        return &easeInOutQuad;
    case cubicIn:
        return &easeInCubic;
    case cubicOut:
        return &easeOutCubic;
    case cubicInOut:
        return &easeInOutCubic;
    case quartIn:
        return &easeInQuart;
    case quartOut:
        return &easeOutQuart;
    case quartInOut:
        return &easeInOutQuart;
    case quintIn:
        return &easeInQuint;
    case quintOut:
        return &easeOutQuint;
    case quintInOut:
        return &easeInOutQuint;
    case expIn:
        return &easeInExp;
    case expOut:
        return &easeOutExp;
    case expInOut:
        return &easeInOutExp;
    case circIn:
        return &easeInCirc;
    case circOut:
        return &easeOutCirc;
    case circInOut:
        return &easeInOutCirc;
    case backIn:
        return &easeInBack;
    case backOut:
        return &easeOutBack;
    case backInOut:
        return &easeInOutBack;
    case elasticIn:
        return &easeInElastic;
    case elasticOut:
        return &easeOutElastic;
    case elasticInOut:
        return &easeInOutElastic;
    case bounceIn:
        return &easeInBounce;
    case bounceOut:
        return &easeOutBounce;
    case bounceInOut:
        return &easeInOutBounce;
    }
}

/// Linear 
float easeLinear(float t) {
    return t;
}

/// Sine
float easeInSine(float t) {
    return sin((t - 1f) * PI_2) + 1f;
}

float easeOutSine(float t) {
    return sin(t * PI_2);
}

float easeInOutSine(float t) {
    return (1f - cos(t * PI)) / 2f;
}

//Quad
float easeInQuad(float t) {
    return t * t;
}

float easeOutQuad(float t) {
    return -(t * (t - 2));
}

float easeInOutQuad(float t) {
    if (t < .5f)
        return 2f * t * t;
    else
        return (-2f * t * t) + (4f * t) - 1f;
}

//Cubic
float easeInCubic(float t) {
    return t * t * t;
}

float easeOutCubic(float t) {
    t = (t - 1f);
    t = (t * t * t + 1f);
    return t;
}

float easeInOutCubic(float t) {
    if (t < .5f)
        return 4f * t * t * t;
    else {
        float f = ((2f * t) - 2f);
        return .5f * f * f * f + 1f;
    }
}

//Quart
float easeInQuart(float t) {
    return t * t * t * t;
}

float easeOutQuart(float t) {
    float f = (t - 1f);
    return f * f * f * (1f - t) + 1f;
}

float easeInOutQuart(float t) {
    if (t < .5f)
        return 8f * t * t * t * t;
    else {
        float f = (t - 1f);
        return -8f * f * f * f * f + 1f;
    }
}

//Quint
float easeInQuint(float t) {
    return t * t * t * t * t;
}

float easeOutQuint(float t) {
    float f = (t - 1f);
    return f * f * f * f * f + 1f;
}

float easeInOutQuint(float t) {
    if (t < .5f)
        return 16f * t * t * t * t * t;
    else {
        float f = ((2f * t) - 2f);
        return .5f * f * f * f * f * f + 1f;
    }
}

//Exp
float easeInExp(float t) {
    return (t == 0f) ? t : pow(2f, 10f * (t - 1f));
}

float easeOutExp(float t) {
    return (t == 1f) ? t : 1f - pow(2f, -10f * t);
}

float easeInOutExp(float t) {
    if (t == 0f || t == 1f)
        return t;
    if (t < .5f)
        return .5f * pow(2f, (20f * t) - 10f);
    else
        return -.5f * pow(2f, (-20f * t) + 10f) + 1f;
}

//Circ
float easeInCirc(float t) {
    return 1f - sqrt(1f - (t * t));
}

float easeOutCirc(float t) {
    return sqrt((2f - t) * t);
}

float easeInOutCirc(float t) {
    if (t < .5f)
        return .5f * (1f - sqrt(1f - 4f * (t * t)));
    else
        return .5f * (sqrt(-((2f * t) - 3f) * ((2f * t) - 1f)) + 1f);
}

//Back
float easeInBack(float t) {
    return t * t * t - t * sin(t * PI);
}

float easeOutBack(float t) {
    float f = (1f - t);
    return 1f - (f * f * f - f * sin(f * PI));
}

float easeInOutBack(float t) {
    if (t < .5f) {
        t *= 2f;
        return (t * t * t - t * sin(t * PI)) / 2f;
    }
    t = (1f - (2f * t - 1f));
    return (1f - (t * t * t - t * sin(t * PI))) / 2f + .5f;
}

//Elastic
float easeInElastic(float t) {
    return sin(13f * PI_2 * t) * pow(2f, 10f * (t - 1f));
}

float easeOutElastic(float t) {
    return sin(-13f * PI_2 * (t + 1)) * pow(2f, -10f * t) + 1f;
}

float easeInOutElastic(float t) {
    if (t < .5f)
        return .5f * sin(13f * PI_2 * (2f * t)) * pow(2f, 10f * ((2f * t) - 1f));
    else
        return .5f * (sin(-13f * PI_2 * ((2f * t - 1f) + 1f)) * pow(2f, -10f * (2f * t - 1f)) + 2f);
}

//bounce
float easeInBounce(float t) {
    return 1f - easeOutBounce(1f - t);
}

float easeOutBounce(float t) {
    if (t < 4f / 11f)
        return (121f * t * t) / 16f;
    else if (t < 8f / 11f)
        return (363f / 40f * t * t) - (99f / 10f * t) + 17f / 5f;
    else if (t < 9f / 10f)
        return (4_356f / 361f * t * t) - (35_442f / 1_805f * t) + 16_061f / 1_805f;
    return (54f / 5f * t * t) - (513f / 25f * t) + 268f / 25f;
}

float easeInOutBounce(float t) {
    if (t < .5f)
        return easeInBounce(t * 2f) / 2f;
    else
        return easeOutBounce(t * 2f - 1f) / 2f + .5f;
}
