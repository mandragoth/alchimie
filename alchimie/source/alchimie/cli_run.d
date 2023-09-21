module alchimie.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);

    string sorcierPath = buildNormalizedPath(dirName(thisExePath()), "sorcierdev.exe");

    string configFile = buildNormalizedPath(dir, "alchimie.json");
    enforce(exists(configFile),
        "aucun fichier de project `alchimie.json` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    string sourceFile;
    string appName = "app";

    if (cli.optionalParams.length >= 1) {
        Json appNode = json.getObject("app");
        appName = cli.optionalParams[0];
        if (appNode.getString("name") == appName) {
            sourceFile = buildNormalizedPath(dir, appNode.getString("source"));
        } else {
            Json[] programNodes = json.getObjects("programs", []);
            bool found;
            foreach (node; programNodes) {
                if (node.getString("name") == appName) {
                    found = true;
                    sourceFile = buildNormalizedPath(dir, node.getString("source"));
                    break;
                }
            }

            enforce(found, "aucun programme `" ~ sourceFile ~ "` défini dans `alchimie.json`");
        }

    } else {
        Json appNode = json.getObject("app");
        appName = json.getString("name");
        sourceFile = buildNormalizedPath(dir, appNode.getString("source"));
    }

    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `alchimie.json` n’existe pas");

    string resFolder = buildNormalizedPath(dir, json.getString("resources"));
    enforce(exists(resFolder),
        "le dossier de ressources `" ~ resFolder ~
        "` référencé dans `alchimie.json` n’existe pas");

    string ret = execute([
        sorcierPath, "run", sourceFile, "––res", resFolder
    ]).output;

    writeln(ret);
}
