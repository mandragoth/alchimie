module alchimie.cli_unpack;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia, config;

void cliUnpack(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();

    string srcPath = buildNormalizedPath(dir, cli.getRequiredParam(0));
    enforce(exists(srcPath), "impossible d’ouvrir l’archive  `" ~ srcPath ~ "`");

    string dstPath = stripExtension(srcPath);

    if (cli.optionalParamCount()) {
        dstPath = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }

    writeln("Extraction de l’archive `", srcPath, "`");

    Archive archive = new Archive;

    try {
        archive.load(srcPath);
    } catch (Exception e) {
        writeln(e.msg);
        writeln("erreur: le format de l’archive est invalide");
        return;
    }
    archive.unpack(dstPath);

    writeln("Archive extraite dans `" ~ dstPath ~ "`");
}
