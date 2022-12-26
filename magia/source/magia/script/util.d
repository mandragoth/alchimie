module magia.script.util;

import magia, grimoire;
import std.stdio;

/// Print
void print(GrStringValue message) {
    writeln(message);
}

/// Color conversion
Color toColor(GrObject obj) {
    return Color(obj.getFloat("r"), obj.getFloat("g"), obj.getFloat("b"));
}
