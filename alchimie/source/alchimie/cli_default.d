module alchimie.cli_default;

import std.stdio;

import magia, config;

enum Alchimie_Version = "0.1";

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        writeln("Alchimie version " ~ Alchimie_Version);
    } else if (cli.hasOption("help")) {
        if (cli.optionalParams.length >= 1)
            writeln(cli.getHelp(cli.optionalParams[0]));
        else
            writeln(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    writeln("Alchimie version " ~ Alchimie_Version);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParams.length >= 1)
        writeln(cli.getHelp(cli.optionalParams[0]));
    else
        writeln(cli.getHelp());
}
