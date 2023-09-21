module sorcier.script.common.smathdef;

import magia;
import grimoire;

final class SVec2(T) {
    Vector!(T, 2) _vectorData;
    alias _vectorData this;
}

alias SVec2f = SVec2!GrFloat;
alias SVec2i = SVec2!GrInt;
alias SVec2u = SVec2!GrUInt;

final class SVec3(T) {
    Vector!(T, 3) _vectorData;
    alias _vectorData this;
}

alias SVec3f = SVec3!GrFloat;
alias SVec3i = SVec3!GrInt;
alias SVec3u = SVec3!GrUInt;

SVec3f toSVec3f(vec3 v_) {
    auto v = new SVec3f;
    v.x = v_.x;
    v.y = v_.y;
    v.z = v_.z;
    return v;
}

final class SVec4(T) {
    Vector!(T, 4) _vectorData;
    alias _vectorData this;
}

alias SVec4f = SVec4!GrFloat;
alias SVec4i = SVec4!GrInt;
alias SVec4u = SVec4!GrUInt;

final class SColor {
    Color _vectorData;
    alias _vectorData this;
}

final class SMat4(T) {
    Matrix!(T, 4, 4) _matrixData;
    alias _matrixData this;
}

alias SMat4f = SMat4!GrFloat;