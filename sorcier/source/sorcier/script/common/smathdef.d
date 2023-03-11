module sorcier.script.common.smathdef;

import magia;
import grimoire;

final class GrVec2(T) {
    Vector!(T, 2) _vectorData;
    alias _vectorData this;
}

alias GrVec2f = GrVec2!GrFloat;
alias GrVec2i = GrVec2!GrInt;
alias GrVec2u = GrVec2!GrUInt;

final class GrVec3(T) {
    Vector!(T, 3) _vectorData;
    alias _vectorData this;
}

alias GrVec3f = GrVec3!GrFloat;
alias GrVec3i = GrVec3!GrInt;
alias GrVec3u = GrVec3!GrUInt;

GrVec3f grVec3(vec3 v_) {
    auto v = new GrVec3f;
    v.x = v_.x;
    v.y = v_.y;
    v.z = v_.z;
    return v;
}

final class GrVec4(T) {
    Vector!(T, 4) _vectorData;
    alias _vectorData this;
}

alias GrVec4f = GrVec4!GrFloat;
alias GrVec4i = GrVec4!GrInt;
alias GrVec4u = GrVec4!GrUInt;

final class GrColor {
    Color _vectorData;
    alias _vectorData this;
}
