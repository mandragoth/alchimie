module alma.cli.cli_build;

import std.array;
import std.path;
import std.stdio;

import magia, grimoire, config;

import alma.runtime;

void cliBuild(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string inputFile = cli.requiredParams[0];
    string outputFile = withExtension(inputFile, Alchimie_Bytecode_Extension).array;

    if (cli.optionalParams.length >= 1) {
        outputFile = cli.optionalParams[0];
    }

    if (inputFile == outputFile) {
        writeln("Erreur: le fichier d’entrée et de sortie sont identique");
        return;
    }

    int options = GrOption.none;

    if (cli.hasOption("profile")) {
        options |= GrOption.profile;
    }
    if (cli.hasOption("safe")) {
        options |= GrOption.safe;
    }
    if (cli.hasOption("symbols")) {
        options |= GrOption.symbols;
    }
        writeln("BUILD: ", inputFile, " vers ", outputFile);

    GrBytecode bytecode = compileSource(inputFile, options, GrLocale.fr_FR);
    bytecode.save(outputFile);
}
