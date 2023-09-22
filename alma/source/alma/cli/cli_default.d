module alma.cli.cli_default;

import std.exception : enforce;
import std.file : exists, thisExePath;
import std.path : setExtension;
import std.stdio : writeln;

import magia, grimoire;

import alma.common;
import alma.runtime;

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        writeln("alma version " ~ Alma_Version_Display);
        return;
    } else if (cli.hasOption("help")) {
        if (cli.optionalParams.length >= 1)
            writeln(cli.getHelp(cli.optionalParams[0]));
        else
            writeln(cli.getHelp());
        return;
    }

    string filePath = setExtension(thisExePath(), Alma_GrimoireCompiledExt);
    enforce(exists(filePath), "le fichier bytecode `" ~ filePath ~ "` n’existe pas");
    GrBytecode bytecode = new GrBytecode(filePath);

    Runtime rt = new Runtime(bytecode);
    rt.run();
}

void cliVersion(Cli.Result cli) {
    writeln("alma version " ~ Alma_Version_Display);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParams.length >= 1)
        writeln(cli.getHelp(cli.optionalParams[0]));
    else
        writeln(cli.getHelp());
}
