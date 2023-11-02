module alchimie.cli_pack;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia, config;

void cliPack(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();

    string srcPath = buildNormalizedPath(dir, cli.getRequiredParam(0));
    enforce(exists(srcPath), "impossible d’ouvrir le dossier `" ~ srcPath ~ "`");

    string dstPath = buildNormalizedPath(dir, setExtension(srcPath, Alchimie_Archive_Extension));

    if (cli.optionalParamCount()) {
        dstPath = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }

    writeln("Génération de l’archive pour `", srcPath, "`");

    Archive archive = new Archive;

    archive.pack(srcPath);
    archive.save(dstPath);

    writeln("Dossier archivé dans `" ~ dstPath ~ "`");
}
