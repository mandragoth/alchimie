module magia.script.common.sutils;

import std.stdio;

import magia.core;
import grimoire;

void print(string message) {
    writeln(message);
}

Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}