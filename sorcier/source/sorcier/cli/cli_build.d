module sorcier.cli.cli_build;

import std.array;
import std.path;
import std.stdio;

import magia, grimoire;

import sorcier.common;
import sorcier.runtime;

void cliBuild(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string inputFile = cli.requiredParams[0];
    string outputFile = withExtension(inputFile, Sorcier_GrimoireCompiledExt).array;

    if (cli.optionalParams.length >= 1) {
        outputFile = cli.optionalParams[0];
    }

    if (inputFile == outputFile) {
        writeln("Erreur: le fichier d’entrée et de sortie sont identique");
        return;
    }

    compileSource(inputFile, outputFile, GrLocale.fr_FR);
}
