module sorcier.cli.help;

import std.stdio : writeln;
import std.conv : to;

import sorcier.common;

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
