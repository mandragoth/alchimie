module sorcier.script.common.smathdef;

import magia;
import grimoire;

final class SVec2(T) {
    Vector!(T, 2) data;
    alias data this;
}

alias SVec2f = SVec2!GrFloat;
alias SVec2i = SVec2!GrInt;
alias SVec2u = SVec2!GrUInt;

final class SVec3(T) {
    Vector!(T, 3) data;
    alias data this;
}

alias SVec3f = SVec3!GrFloat;
alias SVec3i = SVec3!GrInt;
alias SVec3u = SVec3!GrUInt;

final class SVec4(T) {
    Vector!(T, 4) data;
    alias data this;
}

alias SVec4f = SVec4!GrFloat;
alias SVec4i = SVec4!GrInt;
alias SVec4u = SVec4!GrUInt;

final class SColor {
    GrFloat r, g, b;
}
