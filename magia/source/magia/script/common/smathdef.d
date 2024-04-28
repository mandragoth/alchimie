module magia.script.common.smathdef;

import magia.core;
import grimoire;

/// Vecteur 2 en grimoire
final class SVec2(T) {
    /// Données
    Vector!(T, 2) _vectorData;
    alias _vectorData this;
}

alias SVec2f = SVec2!GrFloat;
alias SVec2d = SVec2!GrDouble;
alias SVec2i = SVec2!GrInt;
alias SVec2u = SVec2!GrUInt;

/// Conversion vers grimoire
SVec2!T svec2(T)(Vector!(T, 2) vec) {
    SVec2!T result = new SVec2!T;
    result.x = vec.x;
    result.y = vec.y;
    return result;
}

/// Vecteur 3 en grimoire
final class SVec3(T) {
    /// Données
    Vector!(T, 3) _vectorData;
    alias _vectorData this;
}

alias SVec3f = SVec3!GrFloat;
alias SVec3d = SVec3!GrDouble;
alias SVec3i = SVec3!GrInt;
alias SVec3u = SVec3!GrUInt;

/// Conversion vers grimoire
SVec3!T svec3(T)(Vector!(T, 3) vec) {
    SVec3!T result = new SVec3!T;
    result.x = vec.x;
    result.y = vec.y;
    result.z = vec.z;
    return result;
}

/// Vecteur 4 en grimoire
final class SVec4(T) {
    /// Données
    Vector!(T, 4) _vectorData;
    alias _vectorData this;
}

alias SVec4f = SVec4!GrFloat;
alias SVec4d = SVec4!GrDouble;
alias SVec4i = SVec4!GrInt;
alias SVec4u = SVec4!GrUInt;

/// Conversion vers grimoire
SVec4!T svec4(T)(Vector!(T, 4) vec) {
    SVec4!T result = new SVec4!T;
    result.x = vec.x;
    result.y = vec.y;
    result.z = vec.z;
    result.w = vec.w;
    return result;
}

/// Couleur RVB en grimoire
final class SColor {
    /// Données
    Color _colorData;
    alias _colorData this;
}

/// Conversion vers grimoire
SColor scolor(Color color) {
    SColor result = new SColor;
    result = color;
    return result;
}

/// Couleur TSL en grimoire
final class SHSLColor {
    /// Données
    HSLColor _hslcolorData;
    alias _hslcolorData this;
}

/// Conversion vers grimoire
SHSLColor shslcolor(HSLColor hslcolor) {
    SHSLColor result = new SHSLColor;
    result = hslcolor;
    return result;
}

/// Matrice 4×4 en grimoire
final class SMat4(T) {
    /// Données
    Matrix!(T, 4, 4) _matrixData;
    alias _matrixData this;
}

alias SMat4f = SMat4!GrFloat;
