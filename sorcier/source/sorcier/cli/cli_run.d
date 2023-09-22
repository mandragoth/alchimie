module sorcier.cli.cli_run;

import std.stdio;

import magia, grimoire;

import sorcier.common;
import sorcier.runtime;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string inputFile = cli.requiredParams[0];

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

    GrBytecode bytecode = compileSource(inputFile, options, GrLocale.fr_FR);

    Runtime rt = new Runtime(bytecode);
    rt.run();
}