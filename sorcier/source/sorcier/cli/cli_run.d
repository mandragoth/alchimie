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

    GrBytecode bytecode = compileSource(inputFile, GrLocale.fr_FR);

    Runtime rt = new Runtime(bytecode);
    rt.run();
}