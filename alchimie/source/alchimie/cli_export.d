module alchimie.cli_export;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;
import alchimie.constants;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);
    string almaPath = buildNormalizedPath(dirName(thisExePath()), "almadev.exe");

    string configFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(configFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~ "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

    string exportPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources));
    if (!exists(exportPath))
        mkdir(exportPath);

    string archivePath = setExtension(exportPath, "arc");
    Archive archive = new Archive;

    archive.pack(resPath);
    archive.save(archivePath);

    writeln("Le dossier `" ~ resPath ~ "` a été archivé dans `" ~ archivePath ~ "`");

    Json appNode = json.getObject(Alchimie_Project_App);
    string appName = json.getString(Alchimie_Project_Name);
    string sourceFile = buildNormalizedPath(dir, appNode.getString(Alchimie_Project_Source));

    string ret = execute([
        almaPath, "build", sourceFile]).output;
    writeln(ret);

    writeln("Export terminé");
}
