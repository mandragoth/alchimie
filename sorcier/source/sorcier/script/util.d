module sorcier.script.util;

import magia, grimoire;
import std.stdio;

void print(GrStringValue message) {
    writeln(message);
}

Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}
