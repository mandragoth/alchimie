import std.stdio;

void main() {
	try {
        writeln("Alchimie");
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}