module alchimie.cmd_run;

import std.stdio, std.file, std.path;
import std.exception;

import magia;

void _cmdRun(Cli.Result result) {
    string dir = getcwd();
    string name = baseName(dir);

    if (result.optionalParams.length == 1) {
        enforce(isValidPath(result.optionalParams[0]), "chemin non valide");
        name = baseName(result.optionalParams[0]);
        dir = buildNormalizedPath(dir, result.optionalParams[0]);

        //enforce(exists(dir), "");
    }
}
