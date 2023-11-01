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

    string resPath = buildNormalizedPath(dir, cli.requiredParams[0]);
    enforce(exists(resPath), "le dossier `" ~ resPath ~ "` n’existe pas");

    string archivePath = buildNormalizedPath(dir, setExtension(resPath, "arc"));

    if (cli.optionalParams.length) {
        archivePath = buildNormalizedPath(dir, cli.optionalParams[0]);
    }

    Archive archive = new Archive;

    archive.pack(resPath);
    archive.save(archivePath);

    writeln("Le dossier `" ~ resPath ~ "` a été archivé dans `" ~ archivePath ~ "`");
}
