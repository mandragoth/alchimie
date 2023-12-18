module alma.script.common.sutils;

import std.stdio;

import grimoire;
import alma.kernel;

void print(string message) {
    writeln(message);
}

Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}