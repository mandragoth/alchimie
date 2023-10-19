module alma.cli.cli_run;

import std.conv: to;
import std.stdio;

import magia, grimoire;
import alma.common;
import alma.runtime;

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

    string windowName = "Achimie Machine ~ v" ~ Alma_Version_Display;
    uint windowWidth = 800;
    uint windowHeight = 600;

    if (cli.hasOption("name")) {
        windowName = cli.getOption("name").requiredParams[0];
    }

    if (cli.hasOption("width")) {
        try {
            windowWidth = to!uint(cli.getOption("width").requiredParams[0]);
        } catch (Exception e) {
            windowWidth = 800;
        }
    }

    if (cli.hasOption("height")) {
        try {
            windowHeight = to!uint(cli.getOption("height").requiredParams[0]);
        } catch (Exception e) {
            windowHeight = 600;
        }
    }

    GrBytecode bytecode = compileSource(inputFile, options, GrLocale.fr_FR);

    Alma alma = new Alma(bytecode, windowWidth, windowHeight, windowName);
    alma.run();
}
