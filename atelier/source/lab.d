module lab;

import std.stdio;

import magia;

void main() {
	try {
        writeln("Editeur pas encore debute");
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}