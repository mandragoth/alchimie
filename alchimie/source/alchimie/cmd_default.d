module alchimie.cmd_default;

import std.stdio;

import magia;

void _cmdDefault(Cli.Result result) {
    if (result.hasOption("version")) {
        writeln("alchimie version 0.1");
    } else if (result.hasOption("help")) {
        writeln("alchimie help");
    }
}
