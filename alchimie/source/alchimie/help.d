module alchimie.help;

import std.stdio : writeln;
import std.conv : to;

enum Alchimie_Version = 0;

void displayHelp() {
    string txt = "Alchimie version " ~ to!string(Alchimie_Version) ~ "
    Liste des commandes:
    aide > affiche cette aide.
    ";
    writeln(txt);
}

void displayVersion() {
    string txt = "Alchimie version " ~ to!string(Alchimie_Version) ~ "";
    writeln(txt);
}
