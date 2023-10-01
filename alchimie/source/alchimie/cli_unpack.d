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

    string configFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(configFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~ "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

    string archivePath = buildNormalizedPath(dir, setExtension(resPath, ResourceArchive.defaultExt));
    Archive archive = new Archive;
    
    resPath = buildNormalizedPath(dir, "res_result"); //Temp

    archive.load(archivePath);
    archive.unpack(resPath);

    writeln("L’archive `" ~ archivePath ~ "` a été restauré dans `" ~ resPath ~ "`");
}