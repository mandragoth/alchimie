module sorcier.cli.cli_default;

import std.stdio;

import magia;

import sorcier.common;

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        writeln("Sorcier version " ~ Sorcier_Version_Display);
    } else if (cli.hasOption("help")) {
        if (cli.optionalParams.length >= 1)
            writeln(cli.getHelp(cli.optionalParams[0]));
        else
            writeln(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    writeln("Sorcier version " ~ Sorcier_Version_Display);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParams.length >= 1)
        writeln(cli.getHelp(cli.optionalParams[0]));
    else
        writeln(cli.getHelp());
}
