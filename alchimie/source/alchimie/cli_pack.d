module alchimie.cli_pack;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;

void cliPack(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);

    string configFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(configFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~ "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

    string archivePath = buildNormalizedPath(dir, setExtension(resPath, "arc"));
    Archive archive = new Archive;

    archive.pack(resPath);
    archive.save(archivePath);

    writeln("Le dossier `" ~ resPath ~ "` a été archivé dans `" ~ archivePath ~ "`");
}
