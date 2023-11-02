module alma.cli.cli_build;

import std.array;
import std.path;
import std.stdio;

import magia, grimoire, config;

import alma.runtime;

version (AlmaRuntime) {
    void cliBuild(Cli.Result cli) {
        if (cli.hasOption("help")) {
            writeln(cli.getHelp(cli.name));
            return;
        }

        string inputFile = cli.getRequiredParam(0);
        string outputFile = withExtension(inputFile, Alchimie_Bytecode_Extension).array;

        if (cli.optionalParamCount() >= 1) {
            outputFile = cli.getOptionalParam(0);
        }

        if (inputFile == outputFile) {
            writeln("erreur: le fichier d’entrée et de sortie sont identique");
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
        writeln("compilation de `", inputFile, "`");

        try {
            long startTime = Clock.currStdTime();
            GrBytecode bytecode = compileSource(inputFile, options, GrLocale.fr_FR);
            double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
            writeln("compilation effectuée en ", to!string(loadDuration), "sec");
            bytecode.save(outputFile);
            writeln("génération du bytecode `", inputFile, "`");
        } catch (e) {
            writeln(e.msg);
            writeln("compilation échouée");
        }
    }
}
