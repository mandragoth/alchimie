module alchimie.cli_unpack;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;

void cliUnpack(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);

    string configFile = buildNormalizedPath(dir, "alchimie.json");
    enforce(exists(configFile),
        "aucun fichier de project `alchimie.json` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString("resources"));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `alchimie.json` n’existe pas");

    string archivePath = buildNormalizedPath(dir, setExtension(resPath, "arc"));
    Archive archive = new Archive;
    
    resPath = buildNormalizedPath(dir, "res_result");

    archive.load(archivePath);
    archive.unpack(resPath);

    writeln("L’archive `" ~ archivePath ~ "` a été restauré dans `" ~ resPath ~ "`");
}
