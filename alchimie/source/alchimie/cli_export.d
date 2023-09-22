module alchimie.cli_export;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);
    string almaPath = buildNormalizedPath(dirName(thisExePath()), "almadev.exe");

    string configFile = buildNormalizedPath(dir, "alchimie.json");
    enforce(exists(configFile),
        "aucun fichier de project `alchimie.json` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString("resources"));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `alchimie.json` n’existe pas");

    string exportPath = buildNormalizedPath(dir, configNode.getString("resources"));
    if (!exists(exportPath))
        mkdir(exportPath);

    string archivePath = setExtension(exportPath, "arc");
    Archive archive = new Archive;

    archive.pack(resPath);
    archive.save(archivePath);

    writeln("Le dossier `" ~ resPath ~ "` a été archivé dans `" ~ archivePath ~ "`");

    Json appNode = json.getObject("app");
    string appName = json.getString("name");
    string sourceFile = buildNormalizedPath(dir, appNode.getString("source"));

    string ret = execute([
        almaPath, "build", sourceFile]).output;
    writeln(ret);

    writeln("Export terminé");
}
