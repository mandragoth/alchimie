module sorcier.script.scriptutils;

import std.stdio;

import magia;
import grimoire;

void print(GrStringValue message) {
    writeln(message);
}

Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}