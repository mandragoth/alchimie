module alma.cli.cli_default;

import std.exception : enforce;
import std.file : exists, thisExePath;
import std.path : setExtension;
import std.stdio : writeln;

import magia, grimoire, config;
import alma.runtime;

version (AlmaRuntime) {
    void cliDefault(Cli.Result cli) {
        if (cli.hasOption("version")) {
            writeln("Alchimie Machine version " ~ Alchimie_Version_Display);
            return;
        } else if (cli.hasOption("help")) {
            if (cli.optionalParams.length >= 1)
                writeln(cli.getHelp(cli.optionalParams[0]));
            else
                writeln(cli.getHelp());
            return;
        }

        boot();
    }

    void cliVersion(Cli.Result cli) {
        writeln("Alchimie Machine version " ~ Alchimie_Version_Display);
    }

    void cliHelp(Cli.Result cli) {
        if (cli.optionalParams.length >= 1)
            writeln(cli.getHelp(cli.optionalParams[0]));
        else
            writeln(cli.getHelp());
    }
}
