module alma.cli.cli_run;

import std.conv : to;
import std.stdio;

import magia, grimoire, config;
import alma.runtime;

version (AlmaRuntime) {
    void cliRun(Cli.Result cli) {
        if (cli.hasOption("help")) {
            writeln(cli.getHelp(cli.name));
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

        string windowName = "Achimie Machine ~ v" ~ Alchimie_Version_Display;
        uint windowWidth = Alchimie_Window_Width_Default;
        uint windowHeight = Alchimie_Window_Height_Default;

        if (cli.hasOption("name")) {
            windowName = cli.getOption("name").requiredParams[0];
        }

        if (cli.hasOption("width")) {
            try {
                windowWidth = to!uint(cli.getOption("width").requiredParams[0]);
            } catch (Exception e) {
                windowWidth = Alchimie_Window_Width_Default;
            }
        }

        if (cli.hasOption("height")) {
            try {
                windowHeight = to!uint(cli.getOption("height").requiredParams[0]);
            } catch (Exception e) {
                windowHeight = Alchimie_Window_Height_Default;
            }
        }

        boot(cli.requiredParams[0], cli.requiredParams[1]);
    }
}
