module sorcier.script.sutils;

import std.stdio;

import magia;
import grimoire;

void print(string message) {
    writeln(message);
}

Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}